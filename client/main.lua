lib.locale()

local nuiOpen = false
local isPlacing = false

local function setNuiState(state)
    if nuiOpen == state then return end
    nuiOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({
        action = 'setVisible',
        data = state
    })
end

local function openCraftingMenu()
    local playerJob = Framework.GetJob()
    local playerGang = Framework.GetGang()
    local filteredItems = {}

    for _, item in pairs(Config.CraftingItems) do
        local canSee = false
        
        if not item.jobs and not item.gangs then
            canSee = true
        else
            if item.jobs and playerJob then
                local requiredJobGrade = item.jobs[playerJob.name]
                if requiredJobGrade and playerJob.level >= requiredJobGrade then
                    canSee = true
                end
            end
            
            if not canSee and item.gangs and playerGang then
                local requiredGangGrade = item.gangs[playerGang.name]
                if requiredGangGrade and playerGang.level >= requiredGangGrade then
                    canSee = true
                end
            end
        end

        if canSee then
            local itemData = json.decode(json.encode(item))
            for _, ing in pairs(itemData.ingredients) do
                local count = exports.ox_inventory:Search('count', ing.name)
                if type(count) == 'table' then
                    ing.owned = count[ing.name] or 0
                else
                    ing.owned = count or 0
                end
            end
            table.insert(filteredItems, itemData)
        end
    end

    setNuiState(true)
    Wait(100) 
    SendNUIMessage({
        action = 'loadCrafting',
        data = {
            items = filteredItems,
            locales = {
                workbench = locale('ui_workbench'),
                subtitle = locale('ui_subtitle'),
                available = locale('ui_available'),
                required = locale('ui_required'),
                total_for = locale('ui_total_for'),
                quantity = locale('ui_quantity'),
                time_left = locale('ui_time_left'),
                total_time = locale('ui_total_time'),
                crafting = locale('ui_crafting'),
                start = locale('ui_start'),
                select = locale('ui_select')
            }
        }
    })
end

RegisterNetEvent('krs_crafting:client:refreshUI', function()
    if not nuiOpen then return end 
    
    local playerJob = Framework.GetJob()
    local playerGang = Framework.GetGang()
    local filteredItems = {}

    for _, item in pairs(Config.CraftingItems) do
        local canSee = false
        
        if not item.jobs and not item.gangs then
            canSee = true
        else
            if item.jobs and playerJob then
                local requiredJobGrade = item.jobs[playerJob.name]
                if requiredJobGrade and playerJob.level >= requiredJobGrade then
                    canSee = true
                end
            end
            
            if not canSee and item.gangs and playerGang then
                local requiredGangGrade = item.gangs[playerGang.name]
                if requiredGangGrade and playerGang.level >= requiredGangGrade then
                    canSee = true
                end
            end
        end

        if canSee then
            local itemData = json.decode(json.encode(item))
            for _, ing in pairs(itemData.ingredients) do
                local count = exports.ox_inventory:Search('count', ing.name)
                if type(count) == 'table' then
                    ing.owned = count[ing.name] or 0
                else
                    ing.owned = count or 0
                end
            end
            table.insert(filteredItems, itemData)
        end
    end

    SendNUIMessage({
        action = 'updateItems',
        data = {
            items = filteredItems,
            locales = {
                workbench = locale('ui_workbench'),
                subtitle = locale('ui_subtitle'),
                available = locale('ui_available'),
                required = locale('ui_required'),
                total_for = locale('ui_total_for'),
                quantity = locale('ui_quantity'),
                time_left = locale('ui_time_left'),
                total_time = locale('ui_total_time'),
                crafting = locale('ui_crafting'),
                start = locale('ui_start'),
                select = locale('ui_select')
            }
        }
    })
end)

RegisterNUICallback('hide-ui', function(_, cb)
    setNuiState(false)
    cb('ok')
end)

RegisterNUICallback('startCrafting', function(data, cb)
    local itemName = data.item
    local amount = data.amount or 1 
    
    lib.callback('krs_crafting:server:canCraft', false, function(canCraft)
        if canCraft then
            TriggerServerEvent('krs_crafting:server:finishCraft', itemName, amount)
            cb(true)
        else
            Framework.Notify(locale('missing_materials_perms'), 'error')
            cb(false)
        end
    end, itemName, amount) 
end)

local function spawnBench()
    local model = joaat(Config.WorkbenchModel)
    lib.requestModel(model, 10000)
    
    local playerPed = cache.ped
    local coords = GetEntityCoords(playerPed)
    local distance = 2.0  
    local heading = GetEntityHeading(playerPed)
    
    local obj = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityAlpha(obj, 150, false)
    SetEntityCollision(obj, false, false)
    SetEntityInvincible(obj, true)

    Framework.Notify(locale('placement_mode_desc'), 'info', 5000)

    local placed = false
    while not placed do
        Wait(0)
        
        local forward = GetEntityForwardVector(playerPed)
        local pos = GetEntityCoords(playerPed) + (forward * distance)
        local _, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 2.0, 0)
        
        SetEntityCoords(obj, pos.x, pos.y, groundZ)
        SetEntityHeading(obj, heading)

        DisableControlAction(0, 24, true) 
        DisableControlAction(0, 25, true) 

        if IsControlPressed(0, 172) then 
            distance = math.min(distance + 0.05, 5.0) 
        elseif IsControlPressed(0, 173) then 
            distance = math.max(distance - 0.05, 1.5) 
        end

        if IsControlPressed(0, 174) then 
            heading = heading + 2.0
        elseif IsControlPressed(0, 175) then 
            heading = heading - 2.0
        end

        -- [E] Confirm your placement
        if IsControlJustPressed(0, 38) then
            placed = true
            if Config.UseItem then
                TriggerServerEvent('krs_crafting:server:removeBenchItem') 
            end
        end
        
        -- [ESC] Cancel
        if IsControlJustPressed(0, 177) then
            DeleteEntity(obj)
            Framework.Notify(locale('placement_cancelled'), 'error')
            return
        end
    end

    SetEntityAlpha(obj, 255, false)
    ResetEntityAlpha(obj)
    SetEntityCollision(obj, true, true)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)

    exports.ox_target:addLocalEntity(obj, {
        {
            name = 'crafting_bench_open',
            label = locale('use_workbench'),
            icon = 'fa-solid fa-hammer',
            onSelect = function()
                openCraftingMenu()
            end
        },
        {
            name = 'crafting_bench_remove',
            label = locale('remove_workbench'),
            icon = 'fa-solid fa-trash-can',
            distance = 2.0,
            onSelect = function(data)
                exports.scully_emotemenu:playEmoteByCommand('mechanic')
                if lib.progressBar({
                    duration = math.random(5000, 10000),
                    label = locale('dismantling_bench'),
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true, mouse = false }
                }) then
                    DeleteEntity(data.entity)
                    exports.scully_emotemenu:cancelEmote()
                    
                    if Config.UseItem then
                        TriggerServerEvent('krs_crafting:server:giveBenchItem')
                        Framework.Notify(locale('bench_returned'), 'success')
                    else
                        Framework.Notify(locale('bench_removed_success'), 'success')
                    end
                end
            end
        }
    })
end

if Config.UseItem then
    exports(Config.WorkbenchItem, function(data, slot)
        if isPlacing then return end
        
        local ped = cache.ped
        if IsEntityDead(ped) or IsPedInAnyVehicle(ped, false) or IsPedFalling(ped) then 
            Framework.Notify(locale('cannot_do_now'), 'error')
            return 
        end

        exports.ox_inventory:closeInventory()

        isPlacing = true
        spawnBench()
        isPlacing = false
    end)
else
    RegisterCommand(Config.WorkbenchCommand, function()
        if isPlacing then return end
        
        local ped = cache.ped
        if IsEntityDead(ped) or IsPedInAnyVehicle(ped, false) or IsPedFalling(ped) then 
            Framework.Notify(locale('cannot_do_now'), 'error')
            return 
        end

        isPlacing = true
        spawnBench()
        isPlacing = false
    end, false)
end
lib.locale()

local activeBenches = {}

local function SendDiscordLog(title, message, color)
    if not Config.Webhook or Config.Webhook == "" or Config.Webhook == "DISCORD_WEBHOOK_LINK" then 
        return 
    end

    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color,
            ["footer"] = {
                ["text"] = "krs_crafting Logs - " .. os.date("%d/%m/%Y %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "Crafting System", 
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

local function DropCheater(source, reason)
    local src = source
    local playerName = GetPlayerName(src) or "Unknown"
    local identifier = GetPlayerIdentifierByType(src, 'license') or "N/A"
    
    SendDiscordLog(locale('ac_triggered_title'), locale('ac_triggered_desc', playerName, src, identifier, reason), 16711680)
    print(locale('ac_console_log', playerName, src, reason))
    DropPlayer(src, locale('ac_kick_reason'))
end

lib.callback.register('krs_crafting:server:canCraft', function(source, itemName, amount)
    local src = source
    amount = tonumber(amount) or 1 
    
    local playerJob = Framework.GetJob(src)
    local playerGang = Framework.GetGang(src)
    local recipe = nil

    for _, v in pairs(Config.CraftingItems) do
        if v.name == itemName then
            recipe = v
            break
        end
    end

    if not recipe then return false end

    local hasPermission = false
    
    if not recipe.jobs and not recipe.gangs then
        hasPermission = true
    else
        if recipe.jobs and playerJob then
            local requiredJobGrade = recipe.jobs[playerJob.name]
            if requiredJobGrade and playerJob.level >= requiredJobGrade then
                hasPermission = true
            end
        end

        if not hasPermission and recipe.gangs and playerGang then
            local requiredGangGrade = recipe.gangs[playerGang.name]
            if requiredGangGrade and playerGang.level >= requiredGangGrade then
                hasPermission = true
            end
        end
    end

    if not hasPermission then return false end

    for _, ingredient in pairs(recipe.ingredients) do
        local count = exports.ox_inventory:Search(src, 'count', ingredient.name)
        if count < (ingredient.amount * amount) then
            return false
        end
    end

    return true
end)

RegisterNetEvent('krs_crafting:server:finishCraft', function(itemName, amount)
    local src = source
    amount = tonumber(amount) or 1
    
    if amount <= 0 or amount > 100 then
        DropCheater(src, locale('ac_invalid_quantity', amount, tostring(itemName)))
        return
    end

    local recipe = nil
    for _, v in pairs(Config.CraftingItems) do
        if v.name == itemName then
            recipe = v
            break
        end
    end

    if not recipe then 
        DropCheater(src, locale('ac_invalid_item', tostring(itemName)))
        return 
    end

    local playerJob = Framework.GetJob(src)
    local playerGang = Framework.GetGang(src)
    local hasPermission = false
    
    if not recipe.jobs and not recipe.gangs then
        hasPermission = true
    else
        if recipe.jobs and playerJob then
            local requiredJobGrade = recipe.jobs[playerJob.name]
            if requiredJobGrade and playerJob.level >= requiredJobGrade then
                hasPermission = true
            end
        end

        if not hasPermission and recipe.gangs and playerGang then
            local requiredGangGrade = recipe.gangs[playerGang.name]
            if requiredGangGrade and playerGang.level >= requiredGangGrade then
                hasPermission = true
            end
        end
    end

    if not hasPermission then
        DropCheater(src, locale('ac_no_permissions', tostring(itemName)))
        return
    end

    local totalDuration = recipe.duration * amount
    if totalDuration and totalDuration > 0 then
        Wait(totalDuration)
    end

    local hasItems = true
    for _, ingredient in pairs(recipe.ingredients) do
        local count = exports.ox_inventory:Search(src, 'count', ingredient.name)
        if count < (ingredient.amount * amount) then
            hasItems = false
            break
        end
    end

    if hasItems then
        for _, ingredient in pairs(recipe.ingredients) do
            exports.ox_inventory:RemoveItem(src, ingredient.name, (ingredient.amount * amount))
        end

        if exports.ox_inventory:CanCarryItem(src, itemName, amount) then
            exports.ox_inventory:AddItem(src, itemName, amount)
            
            Framework.Notify(src, locale('notify_crafted_success', amount, recipe.label), 'success')

            local playerName = GetPlayerName(src)
            local identifier = GetPlayerIdentifierByType(src, 'license') or "N/A"
            SendDiscordLog(locale('log_craft_title'), locale('log_craft_desc', playerName, src, identifier, amount, recipe.label), 3066993)
        else
            Framework.Notify(src, locale('notify_inventory_full'), 'error')
        end
        
        TriggerClientEvent('krs_crafting:client:refreshUI', src)
    else
        Framework.Notify(src, locale('notify_missing_ingredients'), 'error')
    end
end)

RegisterNetEvent('krs_crafting:server:removeBenchItem', function()
    if not Config.UseItem then return end
    
    local src = source
    local count = exports.ox_inventory:Search(src, 'count', Config.WorkbenchItem)
    
    if count and count > 0 then
        exports.ox_inventory:RemoveItem(src, Config.WorkbenchItem, 1)
        activeBenches[src] = (activeBenches[src] or 0) + 1
    else
        DropCheater(src, locale('ac_place_without_item'))
    end
end)

RegisterNetEvent('krs_crafting:server:giveBenchItem', function()
    if not Config.UseItem then return end
    
    local src = source
    
    if not activeBenches[src] or activeBenches[src] <= 0 then
        DropCheater(src, locale('ac_exploit_give_bench'))
        return
    end

    activeBenches[src] = activeBenches[src] - 1

    if exports.ox_inventory:CanCarryItem(src, Config.WorkbenchItem, 1) then
        exports.ox_inventory:AddItem(src, Config.WorkbenchItem, 1)
    else
        exports.ox_inventory:AddItem(src, Config.WorkbenchItem, 1)
    end
end)

AddEventHandler('playerDropped', function (reason)
    local src = source
    if activeBenches[src] then
        activeBenches[src] = nil
    end
end)
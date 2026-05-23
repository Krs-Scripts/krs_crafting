Framework = {}
QBCore, ESX = nil, nil
Config = Config or {}

if GetResourceState("qbx_core") == "started" then
    Config.Framework = "Qbox"
elseif GetResourceState("qb-core") == "started" then
    QBCore = exports['qb-core']:GetCoreObject()
    Config.Framework = "QBCore"
elseif GetResourceState("es_extended") == "started" then
    ESX = exports["es_extended"]:getSharedObject()
    Config.Framework = "ESX"
else
    Config.Framework = "none"
end

print("[krs_crafting] Framework detected and started: " .. Config.Framework)

if not IsDuplicityVersion() then
    -- ================= CLIENT SIDE =================
    Framework.PlayerLoggedIn = false

    function Framework.GetPlayerData()
        if Config.Framework == "QBCore" then
            return QBCore.Functions.GetPlayerData()
        elseif Config.Framework == "Qbox" then
            return exports.qbx_core:GetPlayerData()
        elseif Config.Framework == "ESX" then
            return ESX.GetPlayerData()
        end
        return nil
    end

    function Framework.GetJob()
        local player = Framework.GetPlayerData()
        if not player or not player.job then return nil end

        if Config.Framework == "QBCore" or Config.Framework == "Qbox" then
            return { name = player.job.name, level = player.job.grade.level }
        elseif Config.Framework == "ESX" then
            return { name = player.job.name, level = player.job.grade }
        end
        return nil
    end

    function Framework.GetGang()
        local player = Framework.GetPlayerData()
        if not player or not player.gang then return nil end

        if Config.Framework == "QBCore" or Config.Framework == "Qbox" then
            return { name = player.gang.name, level = player.gang.grade.level }
        elseif Config.Framework == "ESX" then
            return nil 
        end
        return nil
    end

    function Framework.Notify(text, type, length)
        type = type or "info"
        length = length or 5000

        if Config.Framework == "QBCore" then
            if type == "info" then type = "primary" end
            QBCore.Functions.Notify(text, type, length)
        elseif Config.Framework == "Qbox" then
            exports.qbx_core:Notify(text, type, length)
        elseif Config.Framework == "ESX" then
            ESX.ShowNotification(text, type, length)
        else
            lib.notify({
                title = 'Notification',
                description = text,
                type = type,
                duration = length
            })
        end
    end

    function Framework.PlayerLoginListeners()
        if Config.Framework == "QBCore" then
            RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
                Framework.PlayerLoggedIn = true
            end)

            RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
                Framework.PlayerLoggedIn = false
            end)

        elseif Config.Framework == "Qbox" then
            AddStateBagChangeHandler("isLoggedIn", ("player:%s"):format(cache.serverId), function(_, _, loggedIn)
                Framework.PlayerLoggedIn = loggedIn
            end)

        elseif Config.Framework == "ESX" then
            RegisterNetEvent("esx:playerLoaded", function()
                lib.waitFor(function()
                    if Framework.GetPlayerData() and cache.ped then return true end
                end, "Ped has not loaded or GetPlayerData returned false (waited 30 seconds)", 30000)
                Framework.PlayerLoggedIn = true
            end)

            RegisterNetEvent("esx:onPlayerSpawn", function()
                lib.waitFor(function()
                    if Framework.GetPlayerData() and cache.ped then return true end
                end, "Ped has not loaded or GetPlayerData returned false (waited 30 seconds)", 30000)
                Framework.PlayerLoggedIn = true
            end)

            RegisterNetEvent("esx:onPlayerLogout", function()
                Framework.PlayerLoggedIn = false
            end)

        else
            lib.waitFor(function()
                if cache.ped then
                    Framework.PlayerLoggedIn = true
                    return true
                end
            end, "[Standalone] Ped never loaded in; could not login (waited 500 seconds)", 500000)
        end
    end

    CreateThread(function()
        Framework.PlayerLoginListeners()
    end)
else
    -- ================= SERVER SIDE =================
    function Framework.GetPlayer(source)
        if Config.Framework == "QBCore" then
            return QBCore.Functions.GetPlayer(source)
        elseif Config.Framework == "Qbox" then
            return exports.qbx_core:GetPlayer(source)
        elseif Config.Framework == "ESX" then
            return ESX.GetPlayerFromId(source)
        end
        return nil
    end

    function Framework.GetJob(source)
        local player = Framework.GetPlayer(source)
        if not player then return nil end

        if Config.Framework == "QBCore" or Config.Framework == "Qbox" then
            return { name = player.PlayerData.job.name, level = player.PlayerData.job.grade.level }
        elseif Config.Framework == "ESX" then
            return { name = player.job.name, level = player.job.grade }
        end
        return nil
    end

    function Framework.GetGang(source)
        local player = Framework.GetPlayer(source)
        if not player then return nil end

        if Config.Framework == "QBCore" or Config.Framework == "Qbox" then
            if player.PlayerData.gang then
                return { name = player.PlayerData.gang.name, level = player.PlayerData.gang.grade.level }
            end
        elseif Config.Framework == "ESX" then
            return nil
        end
        return nil
    end

    function Framework.Notify(source, text, type, length)
        type = type or "info"
        length = length or 5000

        if Config.Framework == "QBCore" then
            if type == "info" then type = "primary" end
            TriggerClientEvent('QBCore:Notify', source, text, type, length)
        elseif Config.Framework == "Qbox" then
            exports.qbx_core:Notify(source, text, type, length)
        elseif Config.Framework == "ESX" then
            TriggerClientEvent('esx:showNotification', source, text, type, length)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Notification',
                description = text,
                type = type,
                duration = length
            })
        end
    end
end
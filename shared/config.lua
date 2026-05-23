Config = {}

Config.UseItem = true -- Set to 'true' to use the item, to 'false' to use the command
Config.WorkbenchItem = "workbench" -- Item name (used only if UseItem = true)
Config.WorkbenchCommand = "placebench" -- Command name (used only if UseItem = false)
Config.WorkbenchModel = "prop_tool_bench02" -- 3D model of the workbench

Config.Webhook = "DISCORD_WEBHOOK_LINK"

-- Leave blank or set to "auto" to automatically detect Qbox, QBCore or ESX
-- You can also force it by typing "QBCore", "Qbox" or "ESX"
Config.Framework = "auto"

Config.ImagesPath = "nui://ox_inventory/web/images/"

Config.CraftingItems = {
    -- Generic Items (No jobs or gangs specified = craftable by EVERYONE, including the unemployed)
    {
        name = "lockpick",
        label = "Lockpick",
        description = "Useful for opening locked doors and containers.",
        image = Config.ImagesPath .. "lockpick.png",
        duration = 30000,
        ingredients = {
            { name = "iron", label = "Iron", amount = 5 },
        }
    },

    -- Medical Items (Ambulance only)
    {
        name = "bandage",
        label = "Bandage",
        description = "Sterilized gauze roll with adhesive medical tape.",
        image = Config.ImagesPath .. "bandage.png",
        duration = 30000,
        jobs = { ambulance = 0 },
        ingredients = {
            { name = "fabric", label = "Fabric", amount = 5 }, 
            { name = "medical_tape", label = "Medical Tape", amount = 1 }, 
        }
    },
    {
        name = "medikit",
        label = "Medikit",
        description = "A professional trauma kit containing sutures, saline and bandages.",
        image = Config.ImagesPath .. "medikit.png",
        duration = 45000,
        jobs = { ambulance = 2 },
        ingredients = {
            { name = "bandage", label = "Bandages", amount = 5 }, 
            { name = "plastic", label = "Plastic", amount = 3 },     
            { name = "saline_solution", label = "Saline Solution", amount = 2 }, 
            { name = "suture_kit", label = "Suture Kit", amount = 1 }, 
        }
    },

    -- Police Equipment (Only Police)
    {
        name = "radio",
        label = "Radio",
        description = "Encrypted communication device for police officers.",
        image = Config.ImagesPath .. "radio.png",
        duration = 15000,
        jobs = { police = 0 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 5 },
            { name = "electronics", label = "Electronics", amount = 3 },
        }
    },
    {
        name = "handcuffs",
        label = "Handcuffs",
        description = "Steel handcuffs for detaining suspects.",
        image = Config.ImagesPath .. "handcuffs.png",
        duration = 20000,
        jobs = { police = 0 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 10 },
        }
    },
    {
        name = "WEAPON_FLASHLIGHT",
        label = "Flashlight",
        description = "High-intensity tactical flashlight.",
        image = Config.ImagesPath .. "WEAPON_FLASHLIGHT.png",
        duration = 10000,
        jobs = { police = 0 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 3 },
            { name = "electronics", label = "Electronics", amount = 1 },
        }
    },
    {
        name = "WEAPON_NIGHTSTICK",
        label = "Nightstick",
        description = "Standard issue police baton.",
        image = Config.ImagesPath .. "WEAPON_NIGHTSTICK.png",
        duration = 25000,
        jobs = { police = 0 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 15 },
        }
    },
    {
        name = "armour",
        label = "Bulletproof Vest",
        description = "Heavy duty tactical vest for maximum protection.",
        image = Config.ImagesPath .. "armour.png",
        duration = 40000,
        jobs = { police = 0 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 10 },
            { name = "steel", label = "Steel", amount = 10 },
        }
    },

    -- Weapons (Mix of Police and Gangs)
    {
        name = "WEAPON_PISTOL", 
        label = "Pistol",
        description = "Standard 9mm semi-automatic handgun.",
        image = Config.ImagesPath .. "WEAPON_PISTOL.png",
        duration = 60000,
        jobs = { police = 0 },
        gangs = { ballas = 1, families = 1 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 20 },
            { name = "steel", label = "Steel", amount = 10 },
            { name = "weapon_parts", label = "Weapon Parts", amount = 5 },
        }
    },
    {
        name = "WEAPON_PISTOL50", 
        label = "Pistol .50",
        description = "High-caliber handgun with massive stopping power.",
        image = Config.ImagesPath .. "WEAPON_PISTOL50.png",
        duration = 90000,
        jobs = { police = 2 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 30 },
            { name = "steel", label = "Steel", amount = 20 },
            { name = "weapon_parts", label = "Weapon Parts", amount = 10 },
        }
    },

    -- Gang Specific Example (Gang only)
    {
        name = "WEAPON_MOLOTOV",
        label = "Molotov Cocktail",
        description = "Improvised incendiary weapon.",
        image = Config.ImagesPath .. "WEAPON_MOLOTOV.png",
        duration = 20000,
        gangs = { ballas = 0, families = 0, vagos = 0 }, 
        ingredients = {
            { name = "glass_bottle", label = "Glass Bottle", amount = 1 },
            { name = "fuel", label = "Fuel", amount = 2 },
            { name = "fabric", label = "Fabric", amount = 1 },
        }
    },

    -- Ammunition
    {
        name = "ammo-9",
        label = "Ammo - 9mm",
        description = "Standard 9mm rounds for pistols and SMGs.",
        image = Config.ImagesPath .. "ammo-9.png",
        duration = 30000,
        jobs = { police = 2 },
        gangs = { ballas = 1, families = 1 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 5 },
            { name = "copper", label = "Copper", amount = 2 },
        }
    },
    {
        name = "ammo-45",
        label = "Ammo - .45 ACP",
        description = "Heavy caliber rounds for handguns and submachine guns.",
        image = Config.ImagesPath .. "ammo-45.png",
        duration = 30000,
        jobs = { police = 2 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 7 },
            { name = "copper", label = "Copper", amount = 3 },
        }
    },
    {
        name = "ammo-rifle",
        label = "Ammo - Rifle",
        description = "High velocity rifle rounds for assault weapons.",
        image = Config.ImagesPath .. "ammo-rifle.png",
        duration = 45000,
        jobs = { police = 2 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 10 },
            { name = "copper", label = "Copper", amount = 5 },
            { name = "gunpowder", label = "Gunpowder", amount = 2 },
        }
    },

    -- Items (Mechanic only)
    {
        name = "repairkit",
        label = "Repair Kit",
        description = "A kit used to repair vehicle engines and mechanical parts.",
        image = Config.ImagesPath .. "repairkit.png",
        duration = 30000,
        jobs = { mechanic = 0 },
        ingredients = {
            { name = "iron", label = "Iron", amount = 8 },
            { name = "electronics", label = "Electronics", amount = 2 },
        }
    }
}

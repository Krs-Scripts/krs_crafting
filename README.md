# krs_crafting

An advanced, secure, and highly customizable crafting system for FiveM. Build items and weapons using a deployable workbench with a modern, responsive React UI.

## Features

* **Deployable Workbench:** Players can place a physical workbench in the world using a specific item or a command.
* **Modern React UI:** A beautiful, responsive, and animated user interface built with React and Mantine.
* **Job & Gang Permissions:** Restrict specific crafting blueprints to certain jobs, gangs, or grade levels.
* **Multi-Framework:** Built-in compatibility with **QBCore**, **ESX**, and **Qbox**.
* **Robust Anti-Cheat:** Server-side validation for everything. Tracks placed workbenches, validates item quantities, checks permissions, and kicks/logs cheaters via Discord Webhooks.
* **Multi-language:** Built-in support for multiple languages using `ox_lib` locales (EN and IT included).
* **Fully Configurable:** Easily change the workbench prop, item requirements, crafting times, and toggle between Item or Command placement modes.

## Dependencies

Ensure you have the following resources installed and running on your server:

* [ox_lib](https://github.com/overextended/ox_lib)
* [ox_inventory](https://github.com/overextended/ox_inventory)
* [ox_target](https://github.com/overextended/ox_target)
* [scully_emotemenu](https://github.com/Scullyy/scully_emotemenu) *(Used for dismantling animations)*

---

## Installation

1. **Download** the resource and place it in your `resources` folder.
2. **Rename** the folder to `krs_crafting` (if it isn't already).
3. **Configure** your Discord Webhook, crafting recipes, and preferences in `config.lua`.

### Adding the Workbench Item (ox_inventory)

If you set `Config.UseItem = true` in your configuration, you must add the workbench item to `ox_inventory`.

Navigate to `ox_inventory/data/items.lua` and add the following snippet:

```lua
    ['workbench'] = {
        label = 'Workbench',
        weight = 5000,
        stack = false,
        close = true,
        description = 'A portable workbench used for crafting items and weapons.',
        client = {
            export = 'krs_crafting.workbench'
        }
    },

```

> **Note:** Don't forget to add a `workbench.png` image (100x100px recommended) inside `ox_inventory/web/images/`.

### Language Setup

This script uses `ox_lib` for localization. To set your server's language, add the following convar to your `server.cfg` **before** starting the resources:

```cfg
setr ox:locale en # Use 'en' for English or 'it' for Italian

```

### Start the Resource

Finally, add the resource to your `server.cfg`:

```cfg
ensure ox_lib
ensure ox_inventory
ensure ox_target
ensure scully_emotemenu
ensure krs_crafting

```

```

```

<img width="1919" height="1079" alt="Screenshot 2026-05-23 131744" src="https://github.com/user-attachments/assets/66d48768-bd06-4728-8bdf-3f81917be1ba" />

<img width="1919" height="1079" alt="Screenshot 2026-05-23 132513" src="https://github.com/user-attachments/assets/d8fcb4e1-6fa5-4aa3-9357-796f158649d5" />

# 🔥 v42-hathair [FiveM Hat → Hair System]

A lightweight, framework-agnostic system that automatically adjusts player hair based on the hat they are wearing.  
Designed for seamless integration with QBCore, Qbox, ESX, and standalone setups.

---

**💬 Support Discord**: [Join the Community](https://discord.com/invite/ackuWrBVV3)  
**🎥 Showcase Video**: [Watch on YouTube](-)

---

## 🎥 Features

- 🎩 **Dynamic Hat Detection**
  - Detects hat (prop 0) changes in real-time
  - Supports drawable + texture variations

- 💇 **Automatic Hair Switching**
  - Applies configured hair per hat
  - Keeps original hair texture & color

- 🔄 **Smart Restore System**
  - Restores original hair when:
    - Hat is removed
    - Hat has no configuration

- 💾 **Persistence Support**
  - Saves original hair during session
  - Supports metadata for:
    - QBCore
    - Qbox
  - ESX / standalone supported (session-based)

- 🔌 **Framework Agnostic**
  - Auto-detects framework:
    - QBCore
    - Qbox
    - ESX
    - Standalone

- ⚡ **Performance Friendly**
  - Configurable check interval
  - Lightweight polling system

- 🔁 **Manual Refresh Support**
  - Event to force re-check after clothing changes

---

## 📦 Installation

### 1. Download Resource

Place the folder inside your `resources` directory:

```
resources/[local]/v42-hathair
```

---

### 2. Add to server.cfg

```
ensure v42-hathair
```

---

### 3. Restart your server

```
refresh
ensure v42-hathair
```

---

## ⚙️ Configuration

All settings are located in:

```
config.lua
```

---

## 🧠 General Settings

```lua
Config.Framework = 'auto'       -- auto | qbcore | qbox | esx | standalone
Config.CheckInterval = 1000     -- How often (ms) hats are checked
Config.RestoreWhenNoMatch = true
Config.Debug = false

Config.UsePersistence = true    -- Save original hair (QB/Qbox metadata)
```

---

## 🎩 Hat → Hair Mapping

```lua
Config.HatHair = {
    male = {
        [12] = {
            default = 12,
            textures = {
                [0] = 12,
                [1] = 18,
                [2] = 6
            }
        }
    },

    female = {
        [10] = {
            default = 14,
            textures = {
                [0] = 14,
                [1] = 20
            }
        }
    }
}
```

---

## 📖 How It Works

1. Script detects the current hat:
   - `drawable` (hat ID)
   - `texture` (variation)

2. Looks up matching config:
   - `Config.HatHair[gender][drawable]`

3. Applies hair:
   - If texture match → use that hair
   - Else → use `default`

4. If no match:
   - Restores original player hair

---

## 🔁 Refresh Event

```
TriggerEvent('hathair:client:refresh')
```

Use this after:

- Clothing changes
- Skin reloads
- Barber menus

---

## 📂 File Structure

```
v42-hathair/
├── client/
│   ├── cl_main.lua
│   └── cl_bridge.lua
├── server/
│   ├── sv_main.lua
│   └── sv_bridge.lua
├── shared/
│   ├── config.lua
├── fxmanifest.lua
```

---

## ⚠️ Notes

- Only affects **hats (prop index 0)**
- Hair **texture & color remain unchanged**
- Make sure your hat drawable exists in config
- Use debug mode to identify hat values

---

## 💬 Support

Join our [Discord Community](https://discord.com/invite/ackuWrBVV3) for support or to showcase your setup.

Made with ❤️ by [v42-Josh](https://github.com/v42-Josh).

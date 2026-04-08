Config = {}

-- auto | qbcore | qbox | esx | standalone
Config.Framework = 'auto'

Config.CheckInterval = 1000
Config.RestoreWhenNoMatch = true
Config.Debug = false

-- Persist original hair across relog/restart when framework supports metadata
Config.UsePersistence = true

--[[
    Hat → Hair Mapping Configuration

    This section defines which hair style is automatically applied when a player
    wears a specific hat (prop index 0).

    Structure:
        Config.HatHair = {
            male / female = {
                [hatDrawable] = {
                    default = hairDrawable,
                    textures = {
                        [hatTexture] = hairDrawable
                    }
                }
            }
        }

    Explanation:
    • hatDrawable  → Hat ID (prop 0)
    • hatTexture   → Variation / color of the hat
    • hairDrawable → Hair style ID (component 2)

    Behavior:
    • If a texture match exists → that hair is applied
    • If no texture match → "default" is used
    • If no configuration exists → original hair is restored

    Notes:
    • Hair texture and color remain unchanged
    • Works separately for male and female peds
]]
Config.HatHair = {
    male = { -- Applies to male peds

        [12] = {
            default = 12,
            textures = {
                [0] = 12,
                [1] = 18,
                [2] = 6
            }
        },

        [15] = {
            default = 7,
            textures = {
                [0] = 7,
                [1] = 9
            }
        }
    },

    female = { -- Applies to female peds

        [10] = {
            default = 14,
            textures = {
                [0] = 14,
                [1] = 20
            }
        }
    }
}

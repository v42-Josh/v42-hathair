Config = {}

-- auto | qbcore | qbox | esx | standalone
Config.Framework = 'auto'

Config.CheckInterval = 1000
Config.RestoreWhenNoMatch = true
Config.Debug = false

-- Persist original hair across relog/restart when framework supports metadata
Config.UsePersistence = true

-- Prevent hats from falling off when the player gets hit / pushed
Config.KeepHatOnHit = true

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
    male = {              -- Settings that apply to male characters (peds)

        [12] = {          -- Hat/prop ID (e.g. hat index 12)
            default = 12, -- Default hair style used when no specific texture match is found
            textures = {
                [0] = 12, -- If hat texture 0 is used → apply hair style 12
            }
        },

        [15] = {         -- Hat/prop ID (e.g. hat index 15)
            default = 7, -- Default hair style for this hat if texture isn't listed below
            textures = {
                [0] = 7, -- If hat texture 0 → use hair style 7
                [1] = 9  -- If hat texture 1 → use hair style 9
            }
        },

        [234] = {         -- Hat/prop ID (e.g. hat index 15)
            default = 93, -- Default hair style for this hat if texture isn't listed below
            textures = {
                [0] = 93, -- If hat texture 0 → use hair style 7
            }
        }
    },

    female = {            -- Settings that apply to female characters (peds)

        [10] = {          -- Hat/prop ID (e.g. hat index 10)
            default = 14, -- Default hair style if no texture-specific override exists
            textures = {
                [0] = 14, -- If hat texture 0 → use hair style 14
                [1] = 20  -- If hat texture 1 → use hair style 20
            }
        }
    }
}

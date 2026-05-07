local PLUGIN = PLUGIN
-- Example breakable lootable 
PLUGIN:RegisterBreakableLootable("supply_crate", { -- key to the breakable lootable
    Name = "SUPPLY CRATE", -- Visible name shown in the UI when damaging the entity
    Model = "models/Items/item_item_crate.mdl", -- Model of the spawned breakable lootable
    Health = 20, -- Amount of health
    RespawnTime = 90, -- Time in seconds until the breakable lootable respawns

    SpawnsLocations = { -- Spawn position(s) and angle(s) of the breakable prop(s)
        { pos = Vector(732.072, -872.208, -143.636), ang = Angle(0.002, -26.993, 0.001) },
        { pos = Vector(707.184, -976.277, -143.566), ang = Angle(0.165, 14.606, 0.087) },
        { pos = Vector(719.040, -1082.407, -143.583), ang = Angle(-0.135, 40.847, 0.066) },
        { pos = Vector(581.705, -986.773, -143.546), ang = Angle(0.096, 18.462, -0.071) }
    },

    SoundOnBreak = "physics/wood/wood_crate_break3.wav", -- sound which will play upon destroying the prop

    ItemDrops = { -- Items that have a chance to spawn (if you want it to always drop just set chance to 100)
        { item = "pistolammo", chance = 100 },
        { item = "pistolammo", chance = 100 },
        { item = "smg1ammo", chance = 50 },
        { item = "health_vial", chance = 20 },
        { item = "pistol", chance = 5 },
        { item = "smg1", chance = 40 },
    }
})
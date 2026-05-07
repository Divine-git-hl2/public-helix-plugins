local PLUGIN = PLUGIN

PLUGIN.name = "Destructible Lootables"
PLUGIN.author = "Heawi"
PLUGIN.description = "Adds customizable lootables, which upon destruction have a chance to drop your predefined items."

PLUGIN.BreakableLootableTypes = PLUGIN.BreakableLootableTypes or {}

function PLUGIN:RegisterBreakableLootable(lootableType, lootableData)
    assert(lootableData.Name, lootableType .. " is missing name")
    assert(lootableData.Model, lootableType .. " is missing model")
    assert(lootableData.Health, lootableType .. " is missing health")
    assert(lootableData.RespawnTime, lootableType .. " is missing respawn time")
    assert(lootableData.SpawnsLocations, lootableType .. " is missing spawn location(s)")
    assert(lootableData.ItemDrops, lootableType .. " is missing item(s) to drop")

    self.BreakableLootableTypes[lootableType] = lootableData
end

function PLUGIN:SpawnBreakableLootable(lootableType)
    local data = self.BreakableLootableTypes[lootableType]
    if not data then return end

    for _, ent in ipairs(ents.FindByClass("heawi_breakable_lootable")) do
        if ent:GetNetVar("lootableName") == data.Name then
            ent:Remove()
        end
    end

    for _, spawn in ipairs(data.SpawnsLocations) do
        local ent = ents.Create("heawi_breakable_lootable")

        ent:SetPos(spawn.pos)
        ent:SetAngles(spawn.ang)

        ent.ModelOverride = data.Model
        ent.HealthOverride = data.Health
        ent.RespawnTime = data.RespawnTime
        ent.SoundOnBreak = data.SoundOnBreak
        ent.ItemDrops = data.ItemDrops

        ent:Spawn()
        ent:Activate()

        ent:SetNetVar("lootableName", data.Name)
    end
end

ix.util.Include("sh_config.lua")
ix.util.Include("sv_hooks.lua")
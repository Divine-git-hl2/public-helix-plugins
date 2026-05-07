local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
    for lootableType, _ in pairs(self.BreakableLootableTypes) do
        self:SpawnBreakableLootable(lootableType)
    end
end
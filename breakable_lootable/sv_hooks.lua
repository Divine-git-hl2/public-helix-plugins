local PLUGIN = PLUGIN

function PLUGIN:LoadData()
    for lootableType, _ in pairs(self.BreakableLootableTypes) do
        self:SpawnBreakableLootable(lootableType)
    end
end
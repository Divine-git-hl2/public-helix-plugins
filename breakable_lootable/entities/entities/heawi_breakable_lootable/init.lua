include( "shared.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

function ENT:Initialize()
    self:SetModel(self.ModelOverride or "models/props_junk/wood_crate001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMaxHealth(self.HealthOverride or 80)
    self:SetHealth(self.HealthOverride or 80)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

function ENT:OnTakeDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())

    if self:Health() <= 0 then
        self:Die()
    end
end

function ENT:Die()
    local soundOnBreak = self.SoundOnBreak
    local lootableName = self:GetNWString("LootableName", "Lootable")

    for _, drop in ipairs(self.ItemDrops or {}) do
        if math.random(100) <= drop.chance then
            ix.item.Spawn(drop.item, self:GetPos(), function(item, ent)
                if IsValid(ent) then
                    timer.Simple(90, function()
                        if IsValid(ent) then
                            ent:Remove()
                        end
                    end)
                end
            end)
        end
    end

    local spawnPos = self:GetPos()
    local spawnAng = self:GetAngles()
    local model = self:GetModel()
    local health = self:GetMaxHealth()
    local respawnTime = self.RespawnTime or 300
    local itemDrops = self.ItemDrops

    local lootableName = self:GetNetVar("lootableName", "Lootable")

    timer.Simple(respawnTime, function()
        local ent = ents.Create("heawi_breakable_lootable")
        if not IsValid(ent) then return end

        ent:SetPos(spawnPos)
        ent:SetAngles(spawnAng)

        ent.ModelOverride = model
        ent.HealthOverride = health
        ent.RespawnTime = respawnTime
        ent.SoundOnBreak = soundOnBreak
        ent.ItemDrops = itemDrops

        ent:Spawn()
        ent:Activate()

        ent:SetNetVar("lootableName", lootableName)
    end)

    if soundOnBreak then
        self:EmitSound(soundOnBreak)
    end

    self:Remove()
end
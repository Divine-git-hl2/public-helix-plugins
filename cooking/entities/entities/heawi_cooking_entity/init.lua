AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/FurnitureStove001a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

function ENT:Use(activator)
    if not activator:IsPlayer() then return end
    if activator:GetPos():Distance(self:GetPos()) > 70 then return end

    net.Start("heawi_cooking_open")
    net.Send(activator)
end
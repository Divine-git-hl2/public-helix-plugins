include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()

    if trace.Entity == self and ply:GetPos():Distance(self:GetPos()) < 120 then
        local ang = ply:EyeAngles()
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), -90)

        local health = self:Health()
        local name = self:GetNetVar("lootableName", "Lootable")
        local maxHealth = self:GetMaxHealth()
        local fraction = math.Clamp(health / maxHealth, 0, 1)

        cam.Start3D2D(self:GetPos() + Vector(0, 0, 30), ang, 0.1)
            draw.SimpleText(name,"HudDefault", -95, -30, Color(0, 0, 0,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(name,"HudDefault", -97, -32, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.RoundedBox(4, -100, -20, 200, 15, Color(50, 50, 50, 220))
            draw.RoundedBox(4, -100, -20, 200 * fraction, 15, Color(50, 150, 50, 200))
        cam.End3D2D()
    end
end
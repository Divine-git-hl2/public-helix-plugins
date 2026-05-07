include( "shared.lua" )

local font = "HudDefault"
local colorBlack = Color(0, 0, 0, 255)
local colorWhite = Color(255, 255, 255, 255)
local barBackgroundColor = Color(50, 50, 50, 220)
local barColor = Color(50, 150, 50, 200)
local offsetVector = Vector(0, 0, 30)

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

        cam.Start3D2D(self:GetPos() + offsetVector, ang, 0.1)
            draw.SimpleText(name, font, -95, -30, colorBlack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(name, font, -97, -32, colorWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.RoundedBox(4, -100, -20, 200, 15, barBackgroundColor)
            draw.RoundedBox(4, -100, -20, 200 * fraction, 15, barColor)
        cam.End3D2D()
    end
end
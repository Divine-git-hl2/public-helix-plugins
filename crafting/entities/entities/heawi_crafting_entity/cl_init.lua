include("shared.lua")

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

        cam.Start3D2D(self:GetPos() + offsetVector, ang, 0.1)
            draw.SimpleText("CRAFTING BENCH", font, -78, -30, colorBlack, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("CRAFTING BENCH", font, -80, -32, colorWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end
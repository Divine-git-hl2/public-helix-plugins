local PLUGIN = PLUGIN

local frameColor = Color(20, 20, 20, 250)
local frameTopBarColor = Color(20, 20, 20, 255)
local accentColor = Color(180, 140, 80, 255)
local buttonColor = Color(30, 30, 30, 240)
local menuBGColor = Color(25, 25, 25, 235)
local modelBGColor = Color(25, 25, 25, 255)
local closeHoverColor = Color(200, 60, 60, 255)

local modelCamPos = Vector(90, 90, 60)
local modelLookAt = Vector(0, 0, 0)
local modelAngle = Angle(0, 35, 0)

local color_white = Color(255, 255, 255, 255)
local color_black = Color(0, 0, 0, 255)

local frame

function createHeawiCraftingFonts()
    local scale = ScrH() / 1080

    surface.CreateFont("Crafting_Title", {
        font = "Roboto Bold",
        size = math.Round(28 * scale),
        weight = 700,
    })

    surface.CreateFont("Crafting_Body", {
        font = "Roboto",
        size = math.Round(20 * scale),
        weight = 400,
    })
end

createHeawiCraftingFonts()

net.Receive("heawi_crafting_open", function()
    if IsValid(frame) then
        frame:Remove()
    end

    local bench = net.ReadEntity()
    local recipes = ix.plugin.Get("crafting").CraftingRecipes

    local scrW, scrH = ScrW(), ScrH()

    frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(scrW, scrH)
    frame:Center()
    frame:SetDraggable(false)
    frame:SetSizable(false)
    frame:ParentToHUD()
    frame:ShowCloseButton(false)
    frame:SetDeleteOnClose(true)
    frame:MakePopup()

    local topBarH = scrH * 0.05
    local offset = scrW * 0.0025
    local iconPad = scrH * 0.007
    local iconCellSize = scrH * 0.06 - iconPad * 2
    local textOffsetX = iconPad + iconCellSize + scrW * 0.01

    frame.Paint = function(self, w, h)
        surface.SetDrawColor(frameColor)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(frameTopBarColor)
        surface.DrawRect(0, 0, w, topBarH)

        draw.SimpleText("CRAFTING", "Crafting_Title", 12, topBarH / 2, accentColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local closeButtonW = scrW * 0.03
    local closeButton = vgui.Create("DButton", frame)
    closeButton:SetSize(closeButtonW, topBarH)
    closeButton:SetPos(frame:GetWide() - closeButtonW, 0)
    closeButton:SetText("")

    closeButton.Paint = function(self, w, h)
        draw.SimpleText("X", "Crafting_Title", w / 2, h / 2, self:IsHovered() and closeHoverColor or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    closeButton.DoClick = function()
        if IsValid(frame) then
            frame:Remove()
        end
    end

    local body = vgui.Create("DPanel", frame)
    body:Dock(FILL)
    body:DockMargin(offset, topBarH / 1.5, 0, 0)
    body:SetPaintBackground(false)

    local left = vgui.Create("DScrollPanel", body)
    left:Dock(LEFT)
    left:SetWide(frame:GetWide() * 0.35)
    left:DockMargin(scrW * 0.01, scrH * 0.01, scrW * 0.005, scrH * 0.01)
    left:GetCanvas():DockPadding(8, 8, 8, 8)

    local right = vgui.Create("DPanel", body)
    right:Dock(FILL)
    right:SetPaintBackground(false)
    right:DockMargin(scrW * 0.005, scrH * 0.01, scrW * 0.01, scrH * 0.01)

    left.Paint = function(self, w, h)
        surface.SetDrawColor(menuBGColor)
        surface.DrawRect(0, 0, w, h)
    end

    right.Paint = function(self, w, h)
        surface.SetDrawColor(menuBGColor)
        surface.DrawRect(0, 0, w, h)
    end

    local function updateRight(recipeID, recipe)
        right:Clear()

        local pad = scrW * 0.02
        local previewSize = scrH * 0.15
        local rowH = scrH * 0.030
        local rowW = right:GetWide() - pad * 2
        local infoX = pad + previewSize + pad

        local previewBG = vgui.Create("DPanel", right)
        previewBG:SetSize(previewSize, previewSize)
        previewBG:SetPos(pad, pad)
        previewBG.Paint = function(self, w, h)
            surface.SetDrawColor(modelBGColor)
            surface.DrawRect(0, 0, w, h)
        end

        local preview = vgui.Create("DModelPanel", previewBG)
        preview:SetSize(previewSize, previewSize)
        preview:SetPos(0, 0)
        preview:SetModel(recipe.Model or "models/error.mdl")
        preview:SetPaintBackground(false)
        preview:SetFOV(8)
        preview:SetCamPos(modelCamPos)
        preview:SetLookAt(modelLookAt)
        preview.LayoutEntity = function() end
        function preview:PostDrawModel(ent) ent:SetAngles(modelAngle) end

        local nameLabel = vgui.Create("DLabel", right)
        nameLabel:SetFont("Crafting_Title")
        nameLabel:SetTextColor(color_white)
        nameLabel:SetText(recipe.Name)
        nameLabel:SizeToContents()
        nameLabel:SetPos(infoX, pad)

        local descLabel = vgui.Create("DLabel", right)
        descLabel:SetFont("Crafting_Body")
        descLabel:SetTextColor(color_white)
        descLabel:SetText(recipe.Description)
        descLabel:SetWide(right:GetWide() - infoX - pad)
        descLabel:SetTall(previewSize * 0.4)
        descLabel:SetPos(infoX, pad + scrH * 0.025)
        descLabel:SetWrap(true)

        local prepLabel = vgui.Create("DLabel", right)
        prepLabel:SetFont("Crafting_Body")
        prepLabel:SetTextColor(color_white)
        prepLabel:SetText("Preparation time: " .. recipe.CraftingTime .. "s")
        prepLabel:SizeToContents()
        prepLabel:SetPos(infoX, pad + scrH * 0.04 + previewSize * 0.4 + scrH * 0.01)

        local expLabel = vgui.Create("DLabel", right)
        expLabel:SetFont("Crafting_Body")
        expLabel:SetTextColor(accentColor)
        expLabel:SetText("Required crafting experience: " .. (recipe.MinExpToCraft or 0))
        expLabel:SetPos(infoX, prepLabel.y + prepLabel:GetTall() + 6)
        expLabel:SetWide(right:GetWide() - infoX - pad)
        expLabel:SetWrap(true)

        local ingredientsY = pad + previewSize + pad
        local ingredientsLabel = vgui.Create("DLabel", right)
        ingredientsLabel:SetFont("Crafting_Title")
        ingredientsLabel:SetTextColor(color_white)
        ingredientsLabel:SetText("MATERIALS NEEDED")
        ingredientsLabel:SizeToContents()
        ingredientsLabel:SetPos(pad, ingredientsY)

        local rowY = ingredientsY + scrH * 0.035
        for _, NeededItems in ipairs(recipe.ItemsToCraft) do
            local row = vgui.Create("DPanel", right)

            row:SetSize(rowW, rowH)
            row:SetPos(pad, rowY)

            local text = NeededItems.amount .. " " .. (NeededItems.displayName or NeededItems.item)

            row.Paint = function(self, w, h)
                surface.SetDrawColor(buttonColor)
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText(text, "Crafting_Body", pad / 2, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            rowY = rowY + rowH + 4
        end

        local givesY = rowY + pad
        local givesLabel = vgui.Create("DLabel", right)
        givesLabel:SetFont("Crafting_Title")
        givesLabel:SetTextColor(color_white)
        givesLabel:SetText("GIVES")
        givesLabel:SizeToContents()
        givesLabel:SetPos(pad, givesY)

        rowY = givesY + scrH * 0.035
        for _, item in ipairs(recipe.ItemsToGive) do
            local row = vgui.Create("DPanel", right)

            row:SetSize(rowW, rowH)
            row:SetPos(pad, rowY)

            local text = item.amount .. " " .. (item.displayName or item.item)

            row.Paint = function(self, w, h)

                surface.SetDrawColor(buttonColor)
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText(text, "Crafting_Body", pad / 2, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            rowY = rowY + rowH + 4
        end

        local craftBtn = vgui.Create("DButton", right)
        craftBtn:SetSize(rowW, scrH * 0.06)
        craftBtn:SetPos(pad, right:GetTall() - scrH * 0.06 - pad)
        craftBtn:SetText("")

        craftBtn.Paint = function(self, w, h)
            surface.SetDrawColor(self:IsHovered() and color_white or buttonColor)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("CRAFT", "Crafting_Title", w / 2, h / 2, self:IsHovered() and color_black or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        craftBtn.DoClick = function()
            net.Start("heawi_crafting_start")
                net.WriteString(recipeID)
                net.WriteEntity(bench)
            net.SendToServer()
            if IsValid(frame) then
                frame:Remove()
            end
        end
    end

    for recipeID, recipe in pairs(recipes) do

        local btn = left:Add("DButton")
        btn:Dock(TOP)
        btn:SetTall(scrH * 0.06)
        btn:DockMargin(0, 0, 0, 8)
        btn:SetText("")

        local icon = vgui.Create("DModelPanel", btn)
        icon:SetSize(iconCellSize, iconCellSize)
        icon:SetPos(iconPad, iconPad)
        icon:SetModel(recipe.Model or "models/error.mdl")
        icon:SetPaintBackground(false)
        icon:SetFOV(8)
        icon:SetCamPos(modelCamPos)
        icon:SetLookAt(modelLookAt)
        icon.LayoutEntity = function() end

        function icon:PostDrawModel(ent)
            ent:SetAngles(modelAngle)
        end

        btn.Paint = function(self, w, h)
            surface.SetDrawColor(buttonColor)
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(modelBGColor)
            surface.DrawRect(iconPad, iconPad, iconCellSize, iconCellSize)

            draw.SimpleText(
                recipe.Name,
                "Crafting_Body",
                textOffsetX,
                h / 2,
                color_white,
                TEXT_ALIGN_LEFT,
                TEXT_ALIGN_CENTER
            )
        end

        btn.DoClick = function()
            updateRight(recipeID, recipe)
        end
    end
end)
util.AddNetworkString("heawi_cooking_start")
util.AddNetworkString("heawi_cooking_open")

local PLUGIN = PLUGIN
PLUGIN.activeCooking = PLUGIN.activeCooking or {}
PLUGIN._cookingCounter = PLUGIN._cookingCounter or 0

function PLUGIN:RefundIngredients(inv, ingredients, client, pos)
    local refundPos = pos or (IsValid(client) and client:GetPos()) or Vector(0, 0, 0)
    for _, ing in ipairs(ingredients) do
        for i = 1, ing.amount do
            if not inv:Add(ing.item) then
                ix.item.Spawn(ing.item, refundPos)
            end
        end
    end
end

function PLUGIN:StopCooking(client, reason)
    local data = self.activeCooking[client]
    if not data then return end

    data.cancelled = true
    self.activeCooking[client] = nil

    client.IsCooking = nil

    if IsValid(client) then
        client:SetAction()
        client:SetMoveType(MOVETYPE_WALK)
    end

    if data.timerID then
        timer.Remove(data.timerID)
    end

    if reason == "cancel" then
        local pos = IsValid(data.stove) and data.stove:GetPos() or (IsValid(client) and client:GetPos() or nil)
        self:RefundIngredients(data.inventory, data.ingredients, client, pos)
        if IsValid(client) then
            client:Notify("You have stopped cooking")
        end
    end
end

function PLUGIN:FinishCooking(client)
    local data = self.activeCooking[client]
    if not data or data.cancelled then return end
    if not IsValid(client) or not IsValid(data.stove) then return end

    local char = client:GetCharacter()
    if not char then return end

    local inv = char:GetInventory()
    if not inv then return end

    self.activeCooking[client] = nil
    client.IsCooking = nil
    client:SetAction()
    client:SetMoveType(MOVETYPE_WALK)

    for _, out in ipairs(data.recipe.ItemsToGive or {}) do
        for i = 1, out.amount do
            if not inv:Add(out.item) then
                ix.item.Spawn(out.item, data.stove:GetPos())
            end
        end
    end

    if data.recipe.ExperienceToGive then
        char:UpdateAttrib("cook", data.recipe.ExperienceToGive)
    end

    client:Notify("You cooked " .. (data.recipe.Name or "something") .. "!")
end

function PLUGIN:CookRecipe(client, id, stove)
    if type(id) ~= "string" or #id > 64 then return false, "invalid recipe" end

    local recipe = self.CookingRecipes[id]
    if not recipe then return false, "invalid recipe" end
    if self.activeCooking[client] then return false, "You are already cooking" end

    local char = client:GetCharacter()
    if not char then return false, "no character" end

    local attribs = char:GetData("attribs", {})
    local skill = attribs["cook"] or 0
    if skill < (recipe.MinExpToCook or 0) then
        return false, "You lack the experience to cook this"
    end

    local inv = char:GetInventory()
    if not inv then return false, "no inventory" end

    if not IsValid(stove) or stove:GetClass() ~= "heawi_cooking_entity" then
        return false, "invalid stove"
    end

    if client:GetPos():DistToSqr(stove:GetPos()) > (70 * 70) then
        return false, "You are not near a stove"
    end

    local removed = {}

    for _, ing in ipairs(recipe.Ingredients) do
        local items = inv:GetItemsByUniqueID(ing.item) or {}
        local count = 0

        for _, item in ipairs(items) do
            if count >= ing.amount then break end
            if item and inv:Remove(item:GetID()) then
                table.insert(removed, {item = ing.item, amount = 1})
                count = count + 1
            end
        end

        if count < ing.amount then
            self:RefundIngredients(inv, removed, client, stove:GetPos())
            return false, "You are missing ingredients"
        end
    end

    client.IsCooking = true
    client:SetMoveType(MOVETYPE_NONE)

    PLUGIN._cookingCounter = PLUGIN._cookingCounter + 1
    local timerID = "heawi_cooking_" .. client:SteamID64() .. "_" .. PLUGIN._cookingCounter

    self.activeCooking[client] = {
        recipe = recipe,
        stove = stove,
        inventory = inv,
        ingredients = recipe.Ingredients,
        timerID = timerID,
        cancelled = false
    }

    client:SetAction("Cooking " .. recipe.Name .. "...", recipe.PreparationTime)

    timer.Create(timerID, recipe.PreparationTime, 1, function()
        if IsValid(client) then
            PLUGIN:FinishCooking(client)
        end
    end)

    return true
end

net.Receive("heawi_cooking_start", function(len, client)
    if client.heawi_cookingCooldown and client.heawi_cookingCooldown > CurTime() then return end
    client.heawi_cookingCooldown = CurTime() + 1

    if client.IsCooking then return end

    local recipeID = net.ReadString()
    if type(recipeID) ~= "string" or #recipeID > 64 then return end

    local stove
    for _, ent in ipairs(ents.FindInSphere(client:GetPos(), 70)) do
        if ent:GetClass() == "heawi_cooking_entity" then
            stove = ent
            break
        end
    end

    if not IsValid(stove) then
        client:Notify("You are not near a stove")
        return
    end

    local ok, err = PLUGIN:CookRecipe(client, recipeID, stove)
    if not ok then
        client:Notify(err)
    end
end)
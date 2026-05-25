util.AddNetworkString("heawi_cooking_start")
util.AddNetworkString("heawi_cooking_open")

local PLUGIN = PLUGIN
PLUGIN.activeCooking = PLUGIN.activeCooking or {}

function PLUGIN:RefundIngredients(inv, ingredients, client, pos)
    for _, ing in ipairs(ingredients) do
        for i = 1, ing.amount do
            if not inv:Add(ing.item) then
                ix.item.Spawn(ing.item, pos or client:GetPos())
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
    client:SetAction()

    if data.timerID then
        timer.Remove(data.timerID)
    end

    if reason == "cancel" then
        self:RefundIngredients(data.inventory, data.ingredients, client, data.stove:GetPos())
        client:Notify("You have stopped Cooking")
    end
end

function PLUGIN:FinishCooking(client)
    local data = self.activeCooking[client]
    if not data or data.cancelled then return end
    if not IsValid(client) or not IsValid(data.stove) then return end

    self.activeCooking[client] = nil
    client.IsCooking = nil
    client:SetAction()

    for _, out in ipairs(data.recipe.ItemsToGive or {}) do
        for i = 1, out.amount do
            if not data.inventory:Add(out.item) then
                ix.item.Spawn(out.item, data.stove:GetPos())
            end
        end
    end

    local char = client:GetCharacter()
    if char and data.recipe.ExperienceToGive then
        char:UpdateAttrib("cook", data.recipe.ExperienceToGive)
    end

    client:Notify("You cooked " .. (data.recipe.Name or "something") .. "!")
end

function PLUGIN:CookRecipe(client, id, stove)
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
        return false, "You have left the stove"
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

    local timerID = "Cooking_" .. client:SteamID64() .. "_" .. CurTime()

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
    local recipeID = net.ReadString()
    local stove = net.ReadEntity()

    if not IsValid(stove) or stove:GetClass() ~= "heawi_cooking_entity" then return end

    local ok, err = PLUGIN:CookRecipe(client, recipeID, stove)

    if not ok then
        client:Notify(err)
    end
end)

timer.Create("heawi_cooking_distance", 1, 0, function()
    for client, data in pairs(PLUGIN.activeCooking) do
        if not IsValid(client) or not IsValid(data.stove) then
            PLUGIN:StopCooking(client, "cancel")
        elseif client:GetPos():DistToSqr(data.stove:GetPos()) > (70 * 70) then
            PLUGIN:StopCooking(client, "cancel")
        end
    end
end)
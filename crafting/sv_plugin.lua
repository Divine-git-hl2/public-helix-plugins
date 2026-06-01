util.AddNetworkString("heawi_crafting_start")
util.AddNetworkString("heawi_crafting_open")

local PLUGIN = PLUGIN
PLUGIN.activeCrafting = PLUGIN.activeCrafting or {}

function PLUGIN:StopCrafting(client, reason)
    local data = self.activeCrafting[client]
    if not data then return end

    self.activeCrafting[client] = nil
    client.IsCrafting = nil

    if IsValid(client) then
        client:SetAction()
        client:SetMoveType(MOVETYPE_WALK)
    end

    if data.timerID then
        timer.Remove(data.timerID)
    end

    if reason == "cancel" and IsValid(client) then
        client:Notify("You have stopped crafting")
    elseif reason == "bench_removed" and IsValid(client) then
        client:Notify("The bench was removed while you were crafting")
    end
end

function PLUGIN:FinishCrafting(client)
    local data = self.activeCrafting[client]
    if not data then return end

    if not IsValid(client) then
        self.activeCrafting[client] = nil
        return
    end

    if not IsValid(data.bench) then
        self:StopCrafting(client, "bench_removed")
        return
    end

    local char = client:GetCharacter()
    if not char then return end

    local inv = char:GetInventory()
    if not inv then return end

    local toRemove = {}
    for _, ing in ipairs(data.recipe.ItemsToCraft) do
        local items = inv:GetItemsByUniqueID(ing.item) or {}
        local collected = {}
        for _, item in ipairs(items) do
            if #collected >= ing.amount then break end
            table.insert(collected, item)
        end

        if #collected < ing.amount then
            self:StopCooking(client, "cancel")
            client:Notify("You are missing items, crafting cancelled")
            return
        end

        table.insert(toRemove, collected)
    end

    for _, items in ipairs(toRemove) do
        for _, item in ipairs(items) do
            inv:Remove(item:GetID())
        end
    end

    self.activeCrafting[client] = nil
    client.IsCrafting = nil
    client:SetAction()
    client:SetMoveType(MOVETYPE_WALK)

    for _, out in ipairs(data.recipe.ItemsToGive or {}) do
        for i = 1, out.amount do
            if not inv:Add(out.item) then
                ix.item.Spawn(out.item, data.bench:GetPos())
            end
        end
    end

    if data.recipe.ExperienceToGive then
        char:UpdateAttrib("craft", data.recipe.ExperienceToGive)
    end

    client:Notify("You crafted " .. (data.recipe.Name or "something") .. "!")
end

function PLUGIN:Craft(client, id, bench)
    if type(id) ~= "string" or #id > 64 then return false, "invalid recipe" end

    local recipe = self.CraftingRecipes[id]
    if not recipe then return false, "invalid recipe" end
    if self.activeCooking[client] then return false, "You are already crafting" end

    local char = client:GetCharacter()
    if not char then return false, "no character" end

    local attribs = char:GetData("attribs", {})
    local skill = attribs["craft"] or 0
    if skill < (recipe.MinExpToCraft or 0) then
        return false, "You lack the experience to craft this"
    end

    local inv = char:GetInventory()
    if not inv then return false, "no inventory" end

    if not IsValid(bench) or bench:GetClass() ~= "heawi_crafing_entity" then
        return false, "invalid bench"
    end

    if client:GetPos():DistToSqr(bench:GetPos()) > (70 * 70) then
        return false, "You are not near a bench"
    end

    for _, ing in ipairs(recipe.ItemsToCraft) do
        local items = inv:GetItemsByUniqueID(ing.item) or {}
        local count = 0
        for _ in pairs(items) do count = count + 1 end
        if count < ing.amount then
            return false, "You are missing items"
        end
    end

    client.IsCrafting = true
    client:SetMoveType(MOVETYPE_NONE)

    local timerID = "heawi_crafting_" .. client:SteamID64()

    self.activeCrafting[client] = {
        recipe = recipe,
        bench = bench,
        timerID = timerID,
    }

    client:SetAction("Crafting " .. recipe.Name .. "...", recipe.CraftingTime)

    timer.Create(timerID, recipe.CraftingTime, 1, function()
        if IsValid(client) then
            PLUGIN:FinishCrafting(client)
        end
    end)

    return true
end

net.Receive("heawi_crafting_start", function(len, client)
    local recipeID = net.ReadString()

    if client.heawi_craftingCooldown and client.heawi_craftingCooldown > CurTime() then return end
    client.heawi_craftingCooldown = CurTime() + 1

    if client.IsCrafting then return end

    if type(recipeID) ~= "string" or #recipeID > 64 then return end

    local bench
    for _, ent in ipairs(ents.FindInSphere(client:GetPos(), 70)) do
        if ent:GetClass() == "heawi_cooking_entity" then
            bench = ent
            break
        end
    end

    if not IsValid(bench) then
        client:Notify("You are not near a bench")
        return
    end

    local ok, err = PLUGIN:Craft(client, recipeID, bench)
    if not ok then
        client:Notify(err)
    end
end)
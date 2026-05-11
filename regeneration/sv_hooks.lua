local PLUGIN = PLUGIN

local cachedRegenEnabled
local cachedMaxRegenHealth
local cachedRegenAmount
local cachedRegenTime
local cachedDamageResetsTimer

local function RefreshRegenConfigCache()
    cachedRegenEnabled = ix.config.Get("regenerationEnabled", false)
    cachedMaxRegenHealth = ix.config.Get("maxRegenerableHealth", 20)
    cachedRegenAmount = ix.config.Get("amountOfHealthRegeneration", 5)
    cachedRegenTime = ix.config.Get("amountOfTimeUntilRegeneration", 180)
    cachedDamageResetsTimer = ix.config.Get("regenerationDamageCancelEnabled", true)
end

RefreshRegenConfigCache()

local function GetRegenTimerName(client)
    return "Regen_" .. client:SteamID64()
end

local function StartRegenTimer(client)
    if (!IsValid(client)) then return end
    if (!cachedRegenEnabled) then return end

    local timerName = GetRegenTimerName(client)

    timer.Remove(timerName)

    timer.Create(timerName, cachedRegenTime, 0, function()
        if (!IsValid(client)) then
            timer.Remove(timerName)
            return
        end

        local currentHealth = client:Health()
        local regenCap = math.min(cachedMaxRegenHealth, client:GetMaxHealth())

        if (currentHealth >= regenCap) then
            timer.Remove(timerName)
            return
        end

        client:SetHealth(math.min(currentHealth + cachedRegenAmount, regenCap))
    end)
end

function PLUGIN:PlayerDisconnected(client)
    timer.Remove(GetRegenTimerName(client))
end

function PLUGIN:EntityTakeDamage(entity, dmgInfo)
    if (!entity:IsPlayer()) then return end
    if (!cachedRegenEnabled) then return end

    timer.Remove(GetRegenTimerName(entity))

    if (!cachedDamageResetsTimer) then return end

    StartRegenTimer(entity)
end

function PLUGIN:RegenerationEnabled()
    RefreshRegenConfigCache()
end

function PLUGIN:RegenerationDisabled()
    RefreshRegenConfigCache()

    for _, client in ipairs(player.GetAll()) do
        timer.Remove(GetRegenTimerName(client))
    end
end

function PLUGIN:RegenerationConfigUpdated()
    RefreshRegenConfigCache()

    for _, client in ipairs(player.GetAll()) do
        timer.Remove(GetRegenTimerName(client))
        StartRegenTimer(client)
    end
end
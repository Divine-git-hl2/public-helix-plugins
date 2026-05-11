local PLUGIN = PLUGIN

PLUGIN.name = "Regeneration"
PLUGIN.author = "Heawi"
PLUGIN.description = "Adds passive regeneration of health for players"

ix.config.Add("regenerationEnabled", false, "Whether regeneration is enabled or not.", function()
    if (ix.config.Get("regenerationEnabled")) then
        hook.Run("RegenerationEnabled")
    else
        hook.Run("RegenerationDisabled")
    end
end, {category = "Regeneration"})

ix.config.Add("maxRegenerableHealth", 20, "To how much health can player regenerate.", function()
    hook.Run("RegenerationConfigUpdated")
end, {
    data = {min = 0, max = 100},
    category = "Regeneration"
})

ix.config.Add("amountOfHealthRegeneration", 5, "how much health person regenerates per cycle.", function()
    hook.Run("RegenerationConfigUpdated")
end, {
    data = {min = 0, max = 100},
    category = "Regeneration"
})

ix.config.Add("amountOfTimeUntilRegeneration", 180, "how many seconds until player starts to regenerate.", function()
    hook.Run("RegenerationConfigUpdated")
end, {
    data = {min = 0, max = 900},
    category = "Regeneration"
})

ix.config.Add("regenerationDamageCancelEnabled", true, "Whether regeneration should be reseted if player takes damage.", function()
    hook.Run("RegenerationConfigUpdated")
end, {category = "Regeneration"})

function PLUGIN:InitializedConfig()
    if (ix.config.Get("regenerationEnabled")) then
        hook.Run("RegenerationEnabled")
    else
        hook.Run("RegenerationDisabled")
    end
end

ix.util.Include("sv_hooks.lua")
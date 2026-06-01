local PLUGIN = PLUGIN

function PLUGIN:PlayerDisconnected(client)
    if PLUGIN.activeCrafting[client] then
        PLUGIN:StopCrafting(client, "cancel")
    end
end
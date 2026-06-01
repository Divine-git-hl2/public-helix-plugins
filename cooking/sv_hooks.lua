local PLUGIN = PLUGIN

function PLUGIN:PlayerDisconnected(client)
    if PLUGIN.activeCooking[client] then
        PLUGIN:StopCooking(client, "cancel")
    end
end
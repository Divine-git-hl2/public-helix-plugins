local PLUGIN = PLUGIN

function PLUGIN:PlayerDisconnected(client)
    client.IsCrafting = nil
end
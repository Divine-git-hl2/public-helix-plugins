local PLUGIN = PLUGIN

function PLUGIN:PlayerDisconnected(client)
    client.IsCooking = nil
end
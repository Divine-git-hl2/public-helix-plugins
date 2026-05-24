local PLUGIN = PLUGIN

function PLUGIN:PlayerDisconnected(client)
    client.ixIsCooking = nil
end
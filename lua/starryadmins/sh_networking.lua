if SERVER then

    util.AddNetworkString("starry_fully_loaded")
    util.AddNetworkString("starry_netsync")

    -- SV Hook: Starry.ClientNetworkReady(Player ply)
    -- Called when a player is fully networked and ready to receive messages.
    net.Receive("starry_fully_loaded", function(len, ply)
        hook.Run("Starry.ClientNetworkReady", ply)
    end)

else

    hook.Add( "InitPostEntity", "Starry.ClientReady", function()
        net.Start( "starry_fully_loaded" )
        net.SendToServer()
    end )

end

-- NetSync Helper
do
    local netsync = {}
    StarryAdmins.netsync = netsync
    StarryAdmins.netsync.registered = {}

    --- Registers a netsynced variable.
    function StarryAdmins.netsync.register(id, tableName, isPlayerData)
        netsync.registered[id] = {
            tableName = tableName,
            isPlayerData = isPlayerData
        }
    end

    if SERVER then

        local function sendNetSync(id, sendTo, dataOwner)
            local syncData = netsync.registered[id]
            local value = syncData.isPlayerData and player[syncData.tableName] or StarryAdmins[syncData.tableName]
            local compressedValue = util.TableToJSON(value or {})  --TODO: Will Player be serialized properly?
            compressedValue = util.Compress(compressedValue)

            net.Start("starry_netsync")
                net.WriteString(id)
                net.WriteEntity(dataOwner) -- nullable
                net.WriteUInt(#compressedValue, 32)
                net.WriteData(compressedValue)
            if sendTo then
                net.Send(sendTo)
            else
                net.Broadcast()
            end
        end

        hook.Add("Starry.ClientNetworkReady", "Starry.ClientNetSync", function(ply)
            for id, syncData in pairs(netsync.registered) do
                if syncData.isPlayerData then
                    for _, ply2 in pairs(player.GetAll()) do
                        sendNetSync(id, ply, ply2)
                    end
                else
                    sendNetSync(id, ply, nil)
                end
            end
        end)

        --- [SV] Updates a netsynced variable.
        function StarryAdmins.netsync.update(id, dataOwner)
            local syncData = netsync.registered[id]
            if not syncData then error("Tried to update unknown netsync id '" .. id .. "'") end

            sendNetSync(id, nil, dataOwner)
        end

    else

        net.Receive("starry_netsync", function(len)
            local id = net.ReadString()
            local dataOwner = net.ReadEntity() -- nullable
            local compressedSize = net.ReadUInt(32)
            local compressedValue = net.ReadData(compressedSize)

            local syncData = netsync.registered[id]
            local value = util.Decompress(compressedValue)
            value = util.JSONToTable(value)

            if dataOwner ~= Entity(0) then
                if not dataOwner:IsValid() then return end
                dataOwner[syncData.tableName] = value
            else
                StarryAdmins[syncData.tableName] = value
            end
        end)

    end
end
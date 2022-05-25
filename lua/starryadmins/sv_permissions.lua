-- SQL table initializing
sql.Query([[
    CREATE TABLE IF NOT EXISTS "starry_user_info" (
        "steamid" STRING PRIMARY KEY,
        "name" STRING,
        "usergroup" STRING NOT NULL,
    );

    CREATE TABLE IF NOT EXISTS "starry_user_tags" (
        "steamid" STRING PRIMARY KEY,
        "tag" STRING,
    );
]])

-- PlayerInitialSpawn hook
hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
hook.Add("PlayerInitialSpawn", "Starry.PermissionsAuth", function(ply)
    local steamid = ply:SteamID()

    -- Group setting
    if game.SinglePlayer() or ply:IsListenServerHost() then
        ply:SetUserGroup("superadmin")
    else
        -- Load up the group
        local info = sql.QueryRow("SELECT * FROM starry_user_info WHERE steamid = " .. sql.SQLStr(steamid) .. ";")
        if info then
            ply:SetUserGroup(info.usergroup)
        else
            ply:SetUserGroup("user")
        end
    end

    -- Tag setting
    ply.starryTags = {}
    local tags = sql.Query("SELECT * FROM starry_user_tags WHERE steamid = " .. sql.SQLStr(steamid) .. ";")
    for _, tag in pairs(tags or {}) do
        ply.starryTags[tag.tag] = true
    end

    StarryAdmins.netsync.update("starryTags", ply)

end)

-- ! Testing data
do
    StarryAdmins.authorityData = {
        ["superadmin"] = {
            ["starry.ban"] = true,
            ["starry.kick"] = true,
        },
        ["admin"] = {
            ["starry.ban"] = true,
            ["starry.kick"] = true,
        },
        ["user"] = {},

        ["#developer"] = {
            ["starry.kick"] = true,
        },
        ["#leadadmin"] = {
            ["starry.ban"] = true,
            ["starry.kick"] = true,
        },
    }
end
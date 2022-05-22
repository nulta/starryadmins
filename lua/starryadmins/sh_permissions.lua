local perm = {}
StarryAdmins.perm = perm
StarryAdmins.authorityData = StarryAdmins.authorityData or {}
--[[
    StarryAdmins.authorityData contains tag and usergroup informations.
    StarryAdmins.authorityData structure
    {
        [tagName or usergroupName] = {
            displayName = string,
            perm = {
                [perm] = (true or false or nil)
            },
        },
    }
]]--

--[[
    Player.starryTags structure
    {
        [tagName] = true,
    }
]]--

StarryAdmins.netsync.register("authorityData", "authorityData", false)
StarryAdmins.netsync.register("starryTags", "starryTags", true)
--[[
    == Permission System ==
    A user's permissions are union of their group's permissions and their tags' permissions.
    A user can only have one usergroup, but can have multiple tags.
]]--

-- Player permission system
do
    local meta = FindMetaTable("Player")

    function meta:starryHasPerm(permName)
        -- Check usergroup permissions
        local usergroup = self:GetUserGroup()
        if StarryAdmins.authorityData[usergroup] and StarryAdmins.authorityData[usergroup][permName] then
            return true
        end

        -- Check tag permissions
        local tags = self.starryTags
        if not tags then return false end

        for tag, _ in pairs(tags) do
            if StarryAdmins.authorityData[tag] and StarryAdmins.authorityData[tag][permName] then
                return true
            end
        end
    end
end
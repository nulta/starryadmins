local perm = {}
StarryAdmins.perm = perm
StarryAdmins.authorityData = StarryAdmins.authorityData or {}

StarryAdmins.netsync.register("authorityData", "authorityData", false)
StarryAdmins.netsync.register("starryTags", "starryTags", true)

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
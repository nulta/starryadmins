
local function load(filename)
    filename = "starryadmins/" .. filename .. "lua"

    if string.StartWith(filename, "sv_") and SERVER then
        include(filename)

    elseif string.StartWith(filename, "cl_") then
        if CLIENT then
            include(filename)
        else
            AddCSLuaFile(filename)
        end

    else -- Shared
        AddCSLuaFile(filename)
        include(filename)
    end
end


load "sh_init"


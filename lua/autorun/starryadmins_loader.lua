local THEME_COLOR = Color(41, 255, 180)
local SUCCESS_COLOR = Color(0, 200, 100)

local loadCount = 0


-- Unprotected load function
local function load(filename)
    local startingTime = SysTime()
    MsgC(THEME_COLOR, "[Starry] ", color_white, "Loading ", THEME_COLOR, filename, color_white, "... ")

    filename = "starryadmins/" .. filename .. ".lua"

    if string.StartWith(filename, "sv_") and SERVER then
        -- Serverside file
        include(filename)
    elseif string.StartWith(filename, "cl_") then
        -- Clientside file
        if CLIENT then
            include(filename)
        else
            AddCSLuaFile(filename)
        end
    else
        -- Shared file (no prefix)
        AddCSLuaFile(filename)
        include(filename)
    end

    MsgC(SUCCESS_COLOR, math.Round((SysTime() - startingTime) * 1000, 1), "ms\n")
    loadCount = loadCount + 1
end

-- Load modules (protected call)
local function loadModules()
    local modules = file.Find("starryadmins/modules/*.lua", "LUA")

    for _, filename in pairs(modules) do
        filename = string.gsub(filename, "%.lua$", "")
        filename = "modules/" .. filename
        load(filename)
    end
end


MsgC(THEME_COLOR, "StarryAdmins ", color_white, "- Starting ", SERVER and "server" or "client", "\n")
load "sh_init"

MsgC(THEME_COLOR, "[      ] \n")
MsgC(THEME_COLOR, "[Starry] ", color_white, "Now loading ", THEME_COLOR, "External Modules", color_white, "..! \n")
loadModules()

MsgC(THEME_COLOR, "[      ] \n")
MsgC(THEME_COLOR, "[Starry] ", color_white, "Done! loaded ", THEME_COLOR, loadCount, color_white, " files\n")
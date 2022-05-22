local MINT = Color(41, 255, 180)
local GREEN = Color(0, 200, 100)
local WHITE = color_white

local loadCount = 0


-- Load the file
local function load(name)
    local startingTime = SysTime()
    local filename = "starryadmins/" .. name .. ".lua"

    -- Serverside file (sv)
    if string.StartWith(name, "sv_") then
        if SERVER then
            MsgC(MINT, "[Starry] ", WHITE, "Loading ", MINT, name, WHITE, "... ")
            include(filename)
        end
    -- Clientside file (cl)
    elseif string.StartWith(name, "cl_") then
        if CLIENT then
            MsgC(MINT, "[Starry] ", WHITE, "Loading ", MINT, name, WHITE, "... ")
            include(filename)
        else
            MsgC(MINT, "[Starry] ", WHITE, "Sending ", MINT, name, WHITE, "... ")
            AddCSLuaFile(filename)
        end

    -- Shared file (sh, no prefix)
    else
        MsgC(MINT, "[Starry] ", WHITE, "Loading ", MINT, name, WHITE, "... ")
        AddCSLuaFile(filename)
        include(filename)
    end

    MsgC(GREEN, math.Round((SysTime() - startingTime) * 1000, 1), "ms\n")
    loadCount = loadCount + 1
end

-- Load modules
local function loadModules()
    local modules = file.Find("starryadmins/modules/*.lua", "LUA")

    for _, filename in pairs(modules) do
        filename = string.gsub(filename, "%.lua$", "")
        filename = "modules/" .. filename
        load(filename)
    end
end

-- AddCSLuaFile for all the directory
local function addCSDirectory(directory)
    if CLIENT then return end
    local startingTime = SysTime()

    MsgC(MINT, "[Starry] ", WHITE, "Sending ", MINT, directory .. "/*", WHITE, "... ")
    local files = file.Find("starryadmins/" .. directory .. "/*.lua", "LUA")

    for _, filename in pairs(files) do
        AddCSLuaFile("starryadmins/" .. directory .. "/" .. filename)
    end

    MsgC(GREEN, math.Round((SysTime() - startingTime) * 1000, 1), "ms\n")
    loadCount = loadCount + 1
end



local totalTime = SysTime()
MsgC(MINT, "StarryAdmins ", WHITE, "- Starting ", SERVER and "server" or "client", "\n")

load "sh_init"
addCSDirectory "langs"
load "cl_i18n"
load "sh_networking"
load "sh_permissions"
load "sv_permissions"

MsgC(MINT, "[      ] \n")
MsgC(MINT, "[Starry] ", WHITE, "Now loading ", MINT, "External Modules", WHITE, "..! \n")
loadModules()
MsgC(MINT, "[      ] \n")
totalTime = math.Round((SysTime() - totalTime) * 1000, 1)
MsgC(MINT, "[Starry] ", WHITE, "Done! Processed ", MINT, loadCount, WHITE, " files in ", MINT, totalTime, "ms\n")
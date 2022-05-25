local command = {}
StarryAdmins.command = command
StarryAdmins.command.registered = {}
StarryAdmins.command.spellTable = {}

function StarryAdmins.command.add(info)
    local name = info.name                          -- Command name
    local func = info.func                          -- function to call (SERVERSIDE)
    local args = info.args or {}                    -- arguments' structure
    local desc = info.desc or "command.nodesc"      -- description text (i18n)
    local icon = info.icon                          -- icon texture (16x16)
    local spell = info.spell                        -- Say command
    if spell == nil then
        spell = name
    end

    assert(name, "Command name is required")
    assert(func, "Command function is required")

    command.registered[name] = {
        name = name,
        func = func,
        args = args,
        desc = desc,
        icon = icon,
        spell = spell
    }

    if spell then
        command.spellTable[spell] = name
    end
end

function StarryAdmins.command.addAlias(name, alias)
    assert(name, "Command name is required")
    assert(alias, "Command alias is required")

    command.spellTable[alias] = name
end


-- Command processing
if SERVER then

    -- TODO: logging, proper argument processing, error messages to issued player, permissions
    local function processCommand(player, cmdName, argstr)
        local cmd = command.registered[cmdName]
        if not cmd then return end

        local args = string.Split(argstr, " ")
        local success, err = pcall(cmd.func, player, unpack(args))
        if not success then
            print(err)
        end

        return success
    end


    hook.Add("PlayerSay", "StarryAdmins.command.PlayerSay", function(ply, text)
        local spell = string.match(text, "^%!([^%s]+)")
        if not spell then return end

        local cmd = command.spellTable[spell]
        if not cmd then return end

        processCommand(ply, cmd, string.sub(text, #spell + 3))
    end)


    -- TODO: Autocomplete for concommand (client side)
    concommand.Add("starry", function(ply, _, args)
        local spell = args[1]
        if not spell then return end  -- TODO: error message

        local cmd = command.spellTable[spell]
        if not cmd then return end

        table.remove(args, 1)
        processCommand(ply, cmd, table.concat(args))
    end)

end


-- ! Testing commands
do
    StarryAdmins.command.add {
        name = "kick",
        func = function(caller, target, reason)
            PrintMessage(
                HUD_PRINTTALK,
                ("%s kicked %s - %s"):format(caller:Nick(), tostring(target), reason)
            )
        end,
        args = {"player", "string"},
    }
end
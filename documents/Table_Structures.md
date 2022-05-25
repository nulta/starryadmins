# Table structures

## StarryAdmins.authorityData
Contains tag and usergroup informations.

    {
        [tagName or usergroupName] = {
            displayName = string,
            perm = {
                [perm] = (true or false or nil)
            },
        },
    }

## (Player).starryTags
Regular Key-indexed table.

    {
        [tagName] = true,
    }

## StarryAdmins.command.registered
    {
        name = string,    -- command name
        func = function(ply, args...),
        args = {
            argument,
        },
        desc? = string,   -- i18n enabled
        icon? = string,   -- 16x16
        spell? = string   -- say command
    }

### Argument
- `number`
    - `number.int`
    - `number.time`
- `string`
- `player`
- `players`

## StarryAdmins.command.spellTable
    {
        [spell] = commandName,  --> StarryAdmins.command.registered
    }

local DEFAULT_LANGUAGE = "en"
local overrideLanguage = CreateClientConVar("starry_language", "", true, false, "Override the display language for StarryAdmins.")
local gmodLanguage = GetConVar("gmod_language")
local i18n = setmetatable({}, {__call = function(self, ...) return self.translate(...) end})


-- Usage: StarryAdmins.i18n("translation_key", parameters...)
StarryAdmins.i18n = i18n
StarryAdmins.i18n.dictionary = {}
StarryAdmins.i18n.validLanguages = i18n.validLanguages or {}


--- Load the list of valid languages.
local function loadValidLanguages()
    local languageFiles = file.Find("starryadmins/langs/*.lua", "LUA")
    for _, languageFile in pairs(languageFiles) do
        local id = string.gsub(languageFile, "%.lua$", "")
        i18n.validLanguages[id] = true
    end
end
loadValidLanguages()


--- Load the language file for the given language and replace the current dictionary.
local function setLanguage(lang)
    -- Check if the language is valid
    if not i18n.validLanguages[lang] then
        lang = DEFAULT_LANGUAGE
    end

    -- At first, load the default language dictionary as base
    i18n.dictionary = include("starryadmins/langs/" .. DEFAULT_LANGUAGE .. ".lua")

    -- Load the desired language file and merge it with the default language
    -- This way, the default language will always be available as fallback for missing translations
    if lang ~= DEFAULT_LANGUAGE then
        local desiredLanguageDictionary = include("starryadmins/langs/" .. lang .. ".lua")
        table.Merge(i18n.dictionary, desiredLanguageDictionary)
    end
end
cvars.AddChangeCallback("starry_language", function(cvarName, oldValue, newValue)
    setLanguage(newValue)
end)


--- Get the current language.
function StarryAdmins.i18n.getCurrentLanguage()
    -- Use starry_language cvar if set
    local lang = overrideLanguage:GetString():Trim()
    if i18n.validLanguages[lang] then
        return lang
    end

    -- Use gmod_language cvar if set
    lang = gmodLanguage:GetString():Trim()
    if i18n.validLanguages[lang] then
        return lang
    end

    -- Fallback to default language
    return DEFAULT_LANGUAGE
end
setLanguage(i18n.getCurrentLanguage())


--- Format a string with certain template, like "Hello {1} with {2}".
function StarryAdmins.i18n.format(template, ...)
    local args = {...}
    for i = 1, #args do
        template = string.gsub(template, "{" .. i .. "}", args[i])
    end
    return template
end


--- Get the translation data for the given key. Replace {1}, {2}, etc. with the given arguments.
function StarryAdmins.i18n.translate(id, ...)
    local translation = i18n.dictionary[id]
    if not translation then
        -- No translation data
        return id
    end

    return i18n.format(translation, ...)
end

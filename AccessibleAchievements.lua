local ENABLED = "enabled"
local ENABLE = "enable"
local DISABLED = "disabled"
local DISABLE = "disable"
local VOICE = "voice"
local NOVOICE = "novoice"
local REPLAY = "replay"

AccessibleAchievements = LibStub("AceAddon-3.0"):NewAddon("AccessibleAchievements", "AceConsole-3.0", "AceEvent-3.0")
AA = AccessibleAchievements

--- Our custom print function.  Will print to screen and check the addon voice setting before concatenating the strings to text-to-speech.
---@param printString1 string First string to print/read
---@param ... string Additional strings to print/read
local function AccessiblePrint(printString1, ...)
    AA:Print(printString1, ...)
    if AADB ~= nil and AADB.voice == true then
        TextToSpeech_Speak("AccessibleAchievements " .. printString1.. ..., TextToSpeech_GetSelectedVoice(0))
    end
end

--- Determine if our settings allow printing
---@return boolean
local function IsPrintEnabled()
    local enablement = AADB ~= nil and AADB.enabled == true
    return enablement
end

---Determine if our setting allow text to speech
---@return boolean
local function IsVoiceEnabled()
    local vocal = AADB ~= nil and AADB.voice == true
    return vocal
end

local function PrintAddonStatus()
    local enabledString = ENABLED
    local voiceString = ENABLED

    if not IsPrintEnabled() then
        enabledString = DISABLED
    end

    if not IsVoiceEnabled() then
        voiceString = DISABLED
    end

    AccessiblePrint(enabledString, "")
    AccessiblePrint("voice "..voiceString, "")
end

--- Determine if we should be printing, then get the achievement info and call our print function.
---@param event any
local function PrintAchievement(event, achievementId)
    if IsPrintEnabled() then    
        local _, name, _, _, _, _, _, description, _, _, _, _, _, _, _ = GetAchievementInfo(achievementId)
        if AADB ~= nil then
            AADB.lastAchievement = "Achievement: "..name.." - "..description
        end
        AccessiblePrint("Achievement: "..name, description)
    end
end

function AA:OnInitialize()
    AA:Print("OnInitialize")
    AADB = AADB or {}
    if AADB.enabled == nil then
        AADB.enabled = true
    end

    if AADB.voice == nil then
        AADB.voice = true
    end

    AADB.replay = (AADB.replay or "")

    AA:RegisterChatCommand("aa", "SlashCommand")
    AA:RegisterChatCommand("accessibleachievements", "SlashCommand")
end

function AA:OnEnable()
    AA:Print("OnEnable")
    AA:RegisterEvent("ACHIEVEMENT_EARNED")

    PrintAddonStatus()
end

--- Handler for ACHIEVEMENT_EARNED event.
function AA:ACHIEVEMENT_EARNED(event, achievementId, alreadyEarned)
    PrintAchievement(event, achievementId)
end

-- Configure slash commands for enable and disable of the printing
function AA:SlashCommand(msg)
    local cmd1 = strsplit(" ", msg)
    
    if #cmd1 > 0 then
        cmd1 = strlower(cmd1)

        if cmd1 == ENABLED or cmd1 == ENABLE then
            AADB.enabled = true
            PrintAddonStatus()
        elseif cmd1 == DISABLED or cmd1 == DISABLE then
            AADB.enabled = false
            PrintAddonStatus()
        elseif cmd1 == VOICE then
            AADB.voice = true
            PrintAddonStatus()
        elseif cmd1 == NOVOICE then
            AADB.voice = false
            PrintAddonStatus()
        elseif cmd1 == REPLAY then
            AccessiblePrint(AADB.lastAchievement, "")
        end
    else
        AccessiblePrint("Enter a command: /aa "..ENABLE.." or /aa "..DISABLE, " or /aa "..VOICE.." or /aa "..NOVOICE.." or /aa "..REPLAY)
    end
end

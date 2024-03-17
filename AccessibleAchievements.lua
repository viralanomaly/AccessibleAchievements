local f = CreateFrame("Frame")

local ENABLED = "enabled"
local ENABLE = "enable"
local DISABLED = "disabled"
local DISABLE = "disable"
local VOICE = "voice"
local NOVOICE = "novoice"
local REPLAY = "replay"

--- Main even handling function
---@param event any
---@param ... unknown
function f:OnEvent(event, ...)
    self[event](self, event, ...) 
end

--- Our custom print function.  Will print to screen and check the addon voice setting before concatenating the strings to text-to-speech.
---@param printString1 string First string to print/read
---@param ... string Additional strings to print/read
local function AccessiblePrint(printString1, ...)
    print(printString1, ...)
    if AADB ~= nil and AADB.voice == true then
        TextToSpeech_Speak(printString1.. ..., TextToSpeech_GetSelectedVoice(0))
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

    AccessiblePrint("AccessibleAchievements is "..enabledString, "")
    AccessiblePrint("AccessibleAchievements voice is "..voiceString, "")
end

--- Determine if we should be printing, then get the achievement info and call our print function.
---@param self any
---@param event any
local function PrintAchievement(self, event)
    if IsPrintEnabled() then   
        if self == "ACHIEVEMENT_EARNED" then   
            local _, name, _, _, _, _, _, description, _, _, _, _, _, _, _ = GetAchievementInfo(event)
            if AADB ~= nil then
                AADB.lastAchievement = "Achievement: "..name.." - "..description
            end
            AccessiblePrint("Achievement: "..name, description)
        end
    end
end

--- Handler for PLAYER_LOGIN event. Setups up or reads our saved variables.
---@param self any
---@param event any
---@param ... unknown
function f:PLAYER_LOGIN(self, event, ...)
    AADB = AADB or {}
    if AADB.enabled == nil then
        AADB.enabled = true
    end

    if AADB.voice == nil then
        AADB.voice = true
    end

    AADB.replay = (AADB.replay or "")

    PrintAddonStatus()
end

--- Handler for ACHIEVEMENT_EARNED event.
---@param self any
---@param event any
---@param ... unknown
function f:ACHIEVEMENT_EARNED(self, event, ...)
    C_Timer.After(1, function() PrintAchievement(self, event) end)
end

function f:AUTOFOLLOW_BEGIN(self, event, name)
    C_Timer.After(1, function() AccessiblePrint("Autofollowing ", name) end)
end

function f:AUTOFOLLOW_END(self, event, name)
    C_Timer.After(1, function() AccessiblePrint("No longer Autofollowing ", name) end)
end



f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ACHIEVEMENT_EARNED")
-- f:RegisterEvent("AUTOFOLLOW_BEGIN")
-- f:RegisterEvent("AUTOFOLLOW_END")

f:SetScript("OnEvent", f.OnEvent)

SLASH_AA1 = "/aa"
SLASH_AA2 = "/accessibleachievements"

-- Configure slash commands for enable and disable of the printing

local function HandleSlashCmds(msg, editBox)
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

SlashCmdList.AA = HandleSlashCmds

LAM2 = LibAddonMenu2
LWM = {}

LWM.name = "LeonardosWardrobeManager"
LWM.allOutfits = { "No Outfit"}

LWM.LibFeedbackInstalled = false

LWM.variableVersion = 6
LWM.default = {
    defaultOutfit = "No Outfit",
    defaultOutfitIndex = 0,

    combatOutfit = "No Outfit",
    combatOutfitIndex = 0,

    stealthOutfit = "No Outfit",
    stealthOutfitIndex = 0
}

panelData = {
    type = "panel",
    name = "Leonardo's Wardrobe Manager",
    registerForRefresh = true
}



OUTFIT_OFFSET = 1

function LWM.SetStateOutfit(state, name)
    local index

    if name == "No Outfit" then
        index = 0
    else
        for i=1,GetNumUnlockedOutfits() do
            if GetOutfitName(0, i) == name then
                index = i
                break
            end
        end
    end

    if state == "DEFAULT" then
        LWM.ChangeOutfit(index)
    end

    local state_d = string.lower(state) .. "Outfit"

    LWM.savedVariables[state_d] = name
    LWM.savedVariables[state_d .. "Index"] = index
end

optionsData = {
    [1] = {
        type = "description",
        title = nil,
        text = "Use command /lwmfeedback to leave feedback.",
        width = "full",
    },
    [2] = {
        type = "dropdown",
        name = "Default Outfit",
        tooltip = "The outfit to be worn by default",
        choices = LWM.allOutfits,
        getFunc = function() return LWM.savedVariables.defaultOutfit end,
        setFunc = function(var) LWM.SetStateOutfit("DEFAULT", var) end,
        reference = "LeonardosWardrobeManager_Default_Dropdown"
    },
    [3] = {
        type = "submenu",
        name = "Combat",
        tooltip = "Options related to combat and stealth", --(optional)
        reference = "LeonardosWardrobeManager_Feedback",
        controls = {
            [1] = {
                type = "dropdown",
                name = "Combat Outfit",
                tooltip = "The outfit to be switched to upon entering combat",
                choices = LWM.allOutfits,
                getFunc = function() return LWM.savedVariables.combatOutfit end,
                setFunc = function(var) LWM.SetStateOutfit("COMBAT", var) end,
                reference = "LeonardosWardrobeManager_Combat_Dropdown"
            },
            [2] = {
                type = "dropdown",
                name = "Stealth Outfit",
                tooltip = "The outfit to be switched to upon entering stealth",
                choices = LWM.allOutfits,
                getFunc = function() return LWM.savedVariables.stealthOutfit end,
                setFunc = function(var) LWM.SetStateOutfit("STEALTH", var) end,
                reference = "LeonardosWardrobeManager_Stealth_Dropdown"
            },
        }
    }
}

function LWM.ChangeOutfit(index)
    if index == 0 then
        UnequipOutfit()
    else
        EquipOutfit(0, index)
    end
end

function LWM.OnOutfitRenamed(event, response, index)
    for i=1,GetNumUnlockedOutfits() do
        LWM.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(0, i)
    end

    LeonardosWardrobeManager_Default_Dropdown:UpdateChoices()
    LeonardosWardrobeManager_Combat_Dropdown:UpdateChoices()
    LeonardosWardrobeManager_Stealth_Dropdown:UpdateChoices()
end

isFirstTimePlayerActivated = true

function LWM.OnPlayerActivated(_, initial)
    if initial then
        if isFirstTimePlayerActivated == false then
            -- After fast travel
            LWM.ChangeOutfit(LWM.savedVariables.defaultOutfitIndex)
        else
            -- --------------------------------- after login
            isFirstTimePlayerActivated = false
        end
    else
        -- ------------------------------------- after reloadui
        isFirstTimePlayerActivated = false
    end
end

function LWM.OnPlayerCombatState(_, inCombat)
    if inCombat ~= LWM.inCombat then
        LWM.inCombat = inCombat
        if LWM.inCombat then
            LWM.ChangeOutfit(LWM.savedVariables.combatOutfitIndex)
        else
            if LWM.inStealth > 0 then
                LWM.ChangeOutfit(LWM.savedVariables.stealthOutfitIndex)
            else
                LWM.ChangeOutfit(LWM.savedVariables.defaultOutfitIndex)
            end
        end
    end
end

function LWM.OnPlayerStealthState(_, unitTag, StealthState)
    d(LWM.LibFeedbackInstalled)
    if StealthState ~= LWM.inStealth and unitTag == "player" then
        LWM.inStealth = StealthState
        if LWM.inStealth > 0 then
            LWM.ChangeOutfit(LWM.savedVariables.stealthOutfitIndex)
        else
            if LWM.inCombat then
                LWM.ChangeOutfit(LWM.savedVariables.combatOutfitIndex)
            else
                LWM.ChangeOutfit(LWM.savedVariables.defaultOutfitIndex)
            end
        end
    end
end

function LWM.OnPlayerRes(_)
    LWM.ChangeOutfit(LWM.savedVariables.defaultOutfitIndex)
end

function LWM:Initialize()
    LWM.savedVariables = ZO_SavedVars:NewCharacterIdSettings(
            "LeonardosWardrobeManagerVars",
            LWM.variableVersion, nil, LWM.default, GetWorldName())

    self.inCombat = IsUnitInCombat("player")
    self.inStealth = GetUnitStealthState("player")

    for i=1,GetNumUnlockedOutfits() do
        name = GetOutfitName(0, i)
        -- TODO: This throws an error the first time it runs, fix it
        --if name == '' then
        --    RenameOutfit(0, i, "Outfit " .. tostring(i))
        --end
        d("Outfit renamed")
        self.allOutfits[i + OUTFIT_OFFSET] = name
    end

    if LWM.LibFeedbackInstalled then
        button, LWM.feedback = LibFeedback:initializeFeedbackWindow(
                LWM,
                "Leonardo's Wardrobe Manager",
                WINDOW_MANAGER:CreateTopLevelWindow("LeonardosWardrobeDummyControl"),
                "@Leonardo1123",
                {CENTER , GuiRoot , CENTER , 10, 10},
                {0,5000,50000},
                "Send feedback or a tip! Please consider reporting any bugs to ESOUI or GitHub as well.")
        button:SetHidden(true)

        SLASH_COMMANDS['/lwmfeedback'] = function(_)
            LWM.feedback:SetHidden(false)
        end
    end

    LAM2:RegisterAddonPanel("LeonardosWardrobeManagerOptions", panelData)
    LAM2:RegisterOptionControls("LeonardosWardrobeManagerOptions", optionsData)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OUTFIT_RENAME_RESPONSE, self.OnOutfitRenamed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_REINCARNATED, self.OnPlayerRes)
end

function LWM.OnAddOnLoaded(_, addonName)
    if addonName == "LibFeedback" then
        LWM.LibFeedbackInstalled = true
    elseif addonName == LWM.name then
        LWM:Initialize()
        EVENT_MANAGER:UnregisterForEvent(LWM.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(LWM.name, EVENT_ADD_ON_LOADED, LWM.OnAddOnLoaded)
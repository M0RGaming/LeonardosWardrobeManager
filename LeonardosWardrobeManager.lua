LeonardosWardrobeManager = {}

LeonardosWardrobeManager.name = "LeonardosWardrobeManager"
LeonardosWardrobeManager.allOutfits = {"No Outfit"}

LeonardosWardrobeManager.variableVersion = 3
LeonardosWardrobeManager.default = {
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
}

LAM2 = LibAddonMenu2

-- TODO: Make this work / not crash ui
SLASH_COMMANDS['/lwmfeedback'] = function(_)
    LeonardosWardrobeManager.feedback:SetHidden(false)
end

OUTFIT_OFFSET = 1

function LeonardosWardrobeManager.UpdateOutfit(state, name, index)
    local state_d = string.lower(state) .. "Outfit"

    LeonardosWardrobeManager.savedVariables[state_d] = name
    LeonardosWardrobeManager.savedVariables[state_d .. "Index"] = index
end

function LeonardosWardrobeManager.SetStateOutfit(state, name)
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
        LeonardosWardrobeManager.ChangeOutfit(index)
    end

    LeonardosWardrobeManager.UpdateOutfit(state, name, index)
end

optionsData = {
    [1] = {
        type = "description",
        title = nil,
        text = "Warning: If you rename an outfit, you will need to reload the UI for those changes to take effect here",
        width = "full",
    },
    [2] = {
        type = "dropdown",
        name = "Default Outfit",
        tooltip = "The outfit to be worn by default",
        choices = LeonardosWardrobeManager.allOutfits,
        getFunc = function() return LeonardosWardrobeManager.savedVariables.defaultOutfit end,
        setFunc = function(var) LeonardosWardrobeManager.SetStateOutfit("DEFAULT", var) end,
    },
    [3] = {
        type = "submenu",
        name = "Combat",
        tooltip = "Options related to combat and stealth", --(optional)
        controls = {
            [1] = {
                type = "dropdown",
                name = "Combat Outfit",
                tooltip = "The outfit to be switched to upon entering combat",
                choices = LeonardosWardrobeManager.allOutfits,
                getFunc = function() return LeonardosWardrobeManager.savedVariables.combatOutfit end,
                setFunc = function(var) LeonardosWardrobeManager.SetStateOutfit("COMBAT", var) end,
            },
            [2] = {
                type = "dropdown",
                name = "Stealth Outfit",
                tooltip = "The outfit to be switched to upon entering stealth",
                choices = LeonardosWardrobeManager.allOutfits,
                getFunc = function() return LeonardosWardrobeManager.savedVariables.stealthOutfit end,
                setFunc = function(var) LeonardosWardrobeManager.SetStateOutfit("STEALTH", var) end,
            },
        }
    }
}

function LeonardosWardrobeManager.ChangeOutfit(index)
    if index == 0 then
        UnequipOutfit()
    else
        EquipOutfit(0, index)
    end
end

function LeonardosWardrobeManager.OnOutfitRenamed(_, _, index) -- TODO: Still not working
    LeonardosWardrobeManager.allOutfits[index + OUTFIT_OFFSET] = GetOutfitName(index + OUTFIT_OFFSET)
    optionsData[3].controls[1].choices = LeonardosWardrobeManager.allOutfits
    optionsData[3].controls[2].choices = LeonardosWardrobeManager.allOutfits
end

isFirstTimePlayerActivated = true

function LeonardosWardrobeManager.OnPlayerActivated(_, initial)
    if initial then
        if isFirstTimePlayerActivated == false then
            -- After fast travel
            LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.savedVariables.defaultOutfitIndex)
        else
            -- --------------------------------- after login
            isFirstTimePlayerActivated = false
        end
    else
        -- ------------------------------------- after reloadui
        isFirstTimePlayerActivated = false
    end
end

function LeonardosWardrobeManager.OnPlayerCombatState(_, inCombat)
    if inCombat ~= LeonardosWardrobeManager.inCombat then
        LeonardosWardrobeManager.inCombat = inCombat
        if LeonardosWardrobeManager.inCombat then
            LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.savedVariables.combatOutfitIndex)
        else
            if LeonardosWardrobeManager.inStealth > 0 then
                LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.savedVariables.stealthOutfitIndex)
            else
                LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.savedVariables.defaultOutfitIndex)
            end
        end
    end
end

function LeonardosWardrobeManager.OnPlayerStealthState(_, _, StealthState)
    if StealthState ~= LeonardosWardrobeManager.inStealth then
        LeonardosWardrobeManager.inStealth = StealthState
        if LeonardosWardrobeManager.inStealth > 0 then
            LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.savedVariables.stealthOutfitIndex)
        else
            if LeonardosWardrobeManager.inCombat then
                LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.savedVariables.combatOutfitIndex)
            else
                LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.savedVariables.defaultOutfitIndex)
            end
        end
    end
end

function LeonardosWardrobeManager:Initialize()
    LeonardosWardrobeManager.savedVariables = ZO_SavedVars:NewCharacterIdSettings(
            "LeonardosWardrobeManagerVars",
            LeonardosWardrobeManager.variableVersion, nil, LeonardosWardrobeManager.Default, GetWorldName())

    self.inCombat = IsUnitInCombat("player")
    self.inStealth = GetUnitStealthState("player")

    for i=1,GetNumUnlockedOutfits() do
        self.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(0, i)
    end

    -- TODO: Make this work / not crash ui
    _, LeonardosWardrobeManager.feedback = LibFeedback:initializeFeedbackWindow(
            LeonardosWardrobeManager, "LWM",GuiRoot, "@Leonardo1123",
            {CENTER , GuiRoot , CENTER , 10, 10},  {0,5000,50000},
            "Send Feedback (or a tip)!")
    LeonardosWardrobeManager.feedback:SetHidden(true)

    LAM2:RegisterAddonPanel("LeonardosWardrobeManagerOptions", panelData)
    LAM2:RegisterOptionControls("LeonardosWardrobeManagerOptions", optionsData)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OUTFIT_RENAME_RESPONSE, self.OnOutfitRenamed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
end

function LeonardosWardrobeManager.OnAddOnLoaded(_, addonName)
    if addonName == LeonardosWardrobeManager.name then
        LeonardosWardrobeManager:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(
        LeonardosWardrobeManager.name,EVENT_ADD_ON_LOADED, LeonardosWardrobeManager.OnAddOnLoaded)
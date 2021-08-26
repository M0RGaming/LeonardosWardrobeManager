LeonardosWardrobeManager = {}

LeonardosWardrobeManager.name = "LeonardosWardrobeManager"
LeonardosWardrobeManager.allOutfits = {"No Outfit"}

LeonardosWardrobeManager.defaultOutfit = nil
LeonardosWardrobeManager.defaultOutfitIndex = nil

LeonardosWardrobeManager.combatOutfit = nil
LeonardosWardrobeManager.combatOutfitIndex = nil

LeonardosWardrobeManager.stealthOutfit = nil
LeonardosWardrobeManager.stealthOutfitIndex = nil

LeonardosWardrobeManager.variableVersion = 3
LeonardosWardrobeManager.default = {
    defaultOutfit = "No Outfit",
    defaultOutfitIndex = 0,

    combatOutfit = "No Outfit",
    combatOutfitIndex = 0,

    stealthOutfit = "No Outfit",
    stealthOutfitIndex = 0
}

local panelData = {
    type = "panel",
    name = "Leonardo's Wardrobe Manager",
}

local LAM2 = LibAddonMenu2

local OUTFIT_OFFSET = 1

function LeonardosWardrobeManager.UpdateOutfit(state, name, index)
    local state_d = string.lower(state) .. "Outfit"

    LeonardosWardrobeManager[state_d] = name
    LeonardosWardrobeManager[state_d .. "Index"] = index
    LeonardosWardrobeManager.savedVariables[state_d] = LeonardosWardrobeManager[state_d]
    LeonardosWardrobeManager.savedVariables[state_d .. "Index"] = LeonardosWardrobeManager[state_d .. "Index"]
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

local optionsData = {
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
        choices = {},
        getFunc = function() return LeonardosWardrobeManager.savedVariables.defaultOutfit end,
        setFunc = function(var) LeonardosWardrobeManager.SetStateOutfit("DEFAULT", var) end,
    },
    [3] = {
        type = "dropdown",
        name = "Combat Outfit",
        tooltip = "The outfit to be switched to upon entering combat",
        choices = {},
        getFunc = function() return LeonardosWardrobeManager.savedVariables.combatOutfit end,
        setFunc = function(var) LeonardosWardrobeManager.SetStateOutfit("COMBAT", var) end,
    },
    [4] = {
        type = "dropdown",
        name = "Stealth Outfit",
        tooltip = "The outfit to be switched to upon entering stealth",
        choices = {},
        getFunc = function() return LeonardosWardrobeManager.savedVariables.stealthOutfit end,
        setFunc = function(var) LeonardosWardrobeManager.SetStateOutfit("STEALTH", var) end,
    },
}

function LeonardosWardrobeManager.ChangeOutfit(index)
    if index == 0 then
        UnequipOutfit()
    else
        EquipOutfit(0, index)
    end
end

function LeonardosWardrobeManager.OnPlayerCombatState(event, inCombat)
    if inCombat ~= LeonardosWardrobeManager.inCombat then
        LeonardosWardrobeManager.inCombat = inCombat
        if inCombat then
            LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.combatOutfitIndex)
        else
            if LeonardosWardrobeManager.inStealth then
                LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.stealthOutfitIndex)
            else
                LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.defaultOutfitIndex)
            end
        end
    end
end

function LeonardosWardrobeManager.OnPlayerStealthState(event, unitTag, StealthState)
    if StealthState ~= LeonardosWardrobeManager.inStealth then
        LeonardosWardrobeManager.inStealth = StealthState
        if StealthState > 0 then
            LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.stealthOutfitIndex)
        else
            LeonardosWardrobeManager.ChangeOutfit(LeonardosWardrobeManager.defaultOutfitIndex)
        end
    end
end

function LeonardosWardrobeManager:Initialize()
    LeonardosWardrobeManager.savedVariables = ZO_SavedVars:NewCharacterIdSettings("LeonardosWardrobeManagerVars", LeonardosWardrobeManager.variableVersion, nil, LeonardosWardrobeManager.Default, GetWorldName())

    self.defaultOutfit = LeonardosWardrobeManager.savedVariables.defaultOutfit
    self.defaultOutfitIndex = LeonardosWardrobeManager.savedVariables.defaultOutfitIndex

    self.combatOutfit = LeonardosWardrobeManager.savedVariables.combatOutfit
    self.combatOutfitIndex = LeonardosWardrobeManager.savedVariables.combatOutfitIndex

    self.stealthOutfit = LeonardosWardrobeManager.savedVariables.stealthOutfit
    self.stealthOutfitIndex = LeonardosWardrobeManager.savedVariables.stealthOutfitIndex

    self.inCombat = IsUnitInCombat("player")
    self.inStealth = GetUnitStealthState("player")

    for i=1,GetNumUnlockedOutfits() do
        self.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(0, i)
    end

    optionsData[2].choices = self.allOutfits
    optionsData[3].choices = self.allOutfits
    optionsData[4].choices = self.allOutfits

    LAM2:RegisterAddonPanel("LeonardosWardrobeManagerOptions", panelData)
    LAM2:RegisterOptionControls("LeonardosWardrobeManagerOptions", optionsData)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
end

function LeonardosWardrobeManager.OnAddOnLoaded(event, addonName)
    if addonName == LeonardosWardrobeManager.name then
        LeonardosWardrobeManager:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(LeonardosWardrobeManager.name, EVENT_ADD_ON_LOADED, LeonardosWardrobeManager.OnAddOnLoaded)
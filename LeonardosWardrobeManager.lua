-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
LeonardosWardrobeManager = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
LeonardosWardrobeManager.name = "LeonardosWardrobeManager"
LeonardosWardrobeManager.allOutfits = {"No Outfit"}

LeonardosWardrobeManager.defaultOutfit = nil
LeonardosWardrobeManager.defaultOutfitIndex = nil

LeonardosWardrobeManager.combatOutfit = nil
LeonardosWardrobeManager.combatOutfitIndex = nil

LeonardosWardrobeManager.variableVersion = 2
LeonardosWardrobeManager.default = {
    defaultOutfit = "No Outfit",
    defaultOutfitIndex = 0,

    combatOutfit = "No Outfit",
    combatOutfitIndex = 0
}

local panelData = {
    type = "panel",
    name = "Leonardo's Wardrobe Manager",
}

local LAM2 = LibAddonMenu2

local OUTFIT_OFFSET = 1

function LeonardosWardrobeManager.SetDefaultOutfit(name)
    LeonardosWardrobeManager.defaultOutfit = name
    if LeonardosWardrobeManager.defaultOutfit == "No Outfit" then
        LeonardosWardrobeManager.defaultOutfitIndex = 0
    else
        for i=1,GetNumUnlockedOutfits() do
            if GetOutfitName(0, i) == LeonardosWardrobeManager.defaultOutfit then
                LeonardosWardrobeManager.defaultOutfitIndex = i
                break
            end
        end
    end

    if LeonardosWardrobeManager.defaultOutfitIndex == 0 and GetEquippedOutfitIndex() ~= nil then
        UnequipOutfit()
    else if LeonardosWardrobeManager.defaultOutfitIndex ~= GetEquippedOutfitIndex() then
        EquipOutfit(0, LeonardosWardrobeManager.defaultOutfitIndex)
    end
    end

    LeonardosWardrobeManager.savedVariables.defaultOutfit = LeonardosWardrobeManager.defaultOutfit
    LeonardosWardrobeManager.savedVariables.defaultOutfitIndex = LeonardosWardrobeManager.defaultOutfitIndex
end

function LeonardosWardrobeManager.SetCombatOutfit(name)
    LeonardosWardrobeManager.combatOutfit = name
    if LeonardosWardrobeManager.combatOutfit == "No Outfit" then
        LeonardosWardrobeManager.combatOutfitIndex = 0
    else
        for i=1,GetNumUnlockedOutfits() do
            if GetOutfitName(0, i) == LeonardosWardrobeManager.combatOutfit then
                LeonardosWardrobeManager.combatOutfitIndex = i
                break
            end
        end
    end

    LeonardosWardrobeManager.savedVariables.combatOutfit = LeonardosWardrobeManager.combatOutfit
    LeonardosWardrobeManager.savedVariables.combatOutfitIndex = LeonardosWardrobeManager.combatOutfitIndex
end

local optionsData = {
    [1] = {
        type = "dropdown",
        name = "Default Outfit",
        tooltip = "The outfit to be worn by default",
        choices = {},
        getFunc = function() return LeonardosWardrobeManager.savedVariables.defaultOutfit end,
        setFunc = function(var) LeonardosWardrobeManager.SetDefaultOutfit(var) end,
    },
    [2] = {
        type = "dropdown",
        name = "Combat Outfit",
        tooltip = "The outfit to be switched to upon entering combat",
        choices = {},
        getFunc = function() return LeonardosWardrobeManager.savedVariables.combatOutfit end,
        setFunc = function(var) LeonardosWardrobeManager.SetCombatOutfit(var) end,
    },
}

function LeonardosWardrobeManager.OnPlayerCombatState(event, inCombat)
    -- The ~= operator is "not equal to" in Lua.
    if inCombat ~= LeonardosWardrobeManager.inCombat then
        -- The player's state has changed. Update the stored state...
        LeonardosWardrobeManager.inCombat = inCombat

        -- ...and then announce the change.
        if inCombat then
            if LeonardosWardrobeManager.combatOutfitIndex == 0 then
                UnequipOutfit()
            else
                EquipOutfit(0, LeonardosWardrobeManager.combatOutfitIndex)
            end
        else
            if LeonardosWardrobeManager.defaultOutfitIndex == 0 then
                UnequipOutfit()
            else
                EquipOutfit(0, LeonardosWardrobeManager.defaultOutfitIndex)
            end
        end

    end
end

function LeonardosWardrobeManager:Initialize()
    LeonardosWardrobeManager.savedVariables = ZO_SavedVars:NewCharacterIdSettings("LeonardosWardrobeManagerVars", LeonardosWardrobeManager.variableVersion, nil, LeonardosWardrobeManager.Default, GetWorldName())

    self.combatOutfit = LeonardosWardrobeManager.savedVariables.combatOutfit
    self.combatOutfitIndex = LeonardosWardrobeManager.savedVariables.combatOutfitIndex

    self.defaultOutfit = LeonardosWardrobeManager.savedVariables.defaultOutfit
    self.defaultOutfitIndex = LeonardosWardrobeManager.savedVariables.defaultOutfitIndex

    self.inCombat = IsUnitInCombat("player")

    for i=1,GetNumUnlockedOutfits() do
        self.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(0, i)
    end

    optionsData[1].choices = self.allOutfits
    optionsData[2].choices = self.allOutfits

    LAM2:RegisterAddonPanel("LeonardosWardrobeManagerOptions", panelData)
    LAM2:RegisterOptionControls("LeonardosWardrobeManagerOptions", optionsData)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function LeonardosWardrobeManager.OnAddOnLoaded(event, addonName)
    -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
    if addonName == LeonardosWardrobeManager.name then
        LeonardosWardrobeManager:Initialize()
    end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(LeonardosWardrobeManager.name, EVENT_ADD_ON_LOADED, LeonardosWardrobeManager.OnAddOnLoaded)
-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
LeonardosWardrobeManager = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
LeonardosWardrobeManager.name = "LeonardosWardrobeManager"
LeonardosWardrobeManager.allOutfits = {"No Outfit"}
LeonardosWardrobeManager.combatOutfit = nil
LeonardosWardrobeManager.combatOutfitIndex = nil

local panelData = {
    type = "panel",
    name = "Leonardo's Wardrobe Manager",
}

local LAM2 = LibAddonMenu2

local OUTFIT_OFFSET = 1

local optionsData = {
    [1] = {
        type = "dropdown",
        name = "Combat Outfit",
        tooltip = "The outfit to be switched to upon entering combat",
        choices = {},
        getFunc = function() return "No Outfit" end,
        setFunc = function(var) print(var) end,
    },
}

function LeonardosWardrobeManager.OnPlayerCombatState(event, inCombat)
    -- The ~= operator is "not equal to" in Lua.
    if inCombat ~= LeonardosWardrobeManager.inCombat then
        -- The player's state has changed. Update the stored state...
        LeonardosWardrobeManager.inCombat = inCombat

        -- ...and then announce the change.
        if inCombat then
            d("Entering combat.")
            EquipOutfit(0, 1)
        else
            d("Exiting combat.")
            UnequipOutfit()
        end

    end
end

function LeonardosWardrobeManager:Initialize()
    self.inCombat = IsUnitInCombat("player")

    for i=1,GetNumUnlockedOutfits() do
        self.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(0, i)
    end

    optionsData[1].choices = self.allOutfits

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
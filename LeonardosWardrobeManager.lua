-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
LeonardosWardrobeManager = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
LeonardosWardrobeManager.name = "LeonardosWardrobeManager"

function LeonardosWardrobeManager.OnPlayerCombatState(event, inCombat)
    -- The ~= operator is "not equal to" in Lua.
    if inCombat ~= LeonardosWardrobeManager.inCombat then
        -- The player's state has changed. Update the stored state...
        LeonardosWardrobeManager.inCombat = inCombat

        -- ...and then announce the change.
        if inCombat then
            d("Entering combat.")
        else
            d("Exiting combat.")
        end

    end
end

function LeonardosWardrobeManager:Initialize()
    self.inCombat = IsUnitInCombat("player")

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
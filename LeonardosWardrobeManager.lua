-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
LeonardosWardrobeManager = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
LeonardosWardrobeManager.name = "LeonardosWardrobeManager"

-- Next we create a function that will initialize our addon
function LeonardosWardrobeManager:Initialize()
    -- ...but we don't have anything to initialize yet. We'll come back to this.
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function LeonardosWardrobeManager:Initialize()
    self.inCombat = IsUnitInCombat("player")

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)

    self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("LeonardosWardrobeManagerSavedVariables", 1, nil, {})
end

function LeonardosWardrobeManager.OnIndicatorMoveStop()
    LeonardosWardrobeManager.savedVariables.left = LeonardosWardrobeManagerIndicator:GetLeft()
    LeonardosWardrobeManager.savedVariables.top = LeonardosWardrobeManagerIndicator:GetTop()
end

function LeonardosWardrobeManager:RestorePosition()
    local left = self.savedVariables.left
    local top = self.savedVariables.top

    LeonardosWardrobeManagerIndicator:ClearAnchors()
    LeonardosWardrobeManagerIndicator:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function LeonardosWardrobeManager:Initialize()
    self.inCombat = IsUnitInCombat("player")

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)

    self.savedVariables = ZO_SavedVars:NewCharacterIdSettings("LeonardosWardrobeManagerSavedVariables", 1, nil, {})

    self:RestorePosition()
end

function LeonardosWardrobeManager.OnPlayerCombatState(event, inCombat)
    -- The ~= operator is "not equal to" in Lua.
    if inCombat ~= LeonardosWardrobeManager.inCombat then
        -- The player's state has changed. Update the stored state...
        LeonardosWardrobeManager.inCombat = inCombat

        -- ...and then update the control.
        LeonardosWardrobeManagerIndicator:SetHidden(not inCombat)
    end
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(LeonardosWardrobeManager.name, EVENT_ADD_ON_LOADED, LeonardosWardrobeManager.OnAddOnLoaded)
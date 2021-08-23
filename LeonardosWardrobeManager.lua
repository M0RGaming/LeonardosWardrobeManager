-- Define Table
WardrobeManager = {}
 
-- Save nickname
WardrobeManager.name = "WardrobeManager"
 
-- Init
function WardrobeManager:Initialize()
  self.inCombat = IsUnitInCombat("player")
  
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)

end

-- Combat State-Change Handler
function WardrobeManager.OnPlayerCombatState(event, inCombat)
  -- The ~= operator is "not equal to" in Lua.
  if inCombat ~= WardrobeManager.inCombat then
    -- The player's state has changed. Update the stored state...
    WardrobeManager.inCombat = inCombat
 
    -- ...and then update the control.
    WardrobeManagerIndicator:SetHidden(not inCombat)
  end
end
 
-- Event Handler
function WardrobeManager.OnAddOnLoaded(event, addonName)
  -- Only init when loading this addon
  if addonName == WardrobeManager.name then
    WardrobeManager:Initialize()
  end
end
 
-- Register the event handler
EVENT_MANAGER:RegisterForEvent(WardrobeManager.name, EVENT_ADD_ON_LOADED, WardrobeManager.OnAddOnLoaded)
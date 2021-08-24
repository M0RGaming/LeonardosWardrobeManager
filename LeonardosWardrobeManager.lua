LeonardosWardrobeManager = {}

-------------------------------------------------------------------------------------------------
--  Initialize Variables --
-------------------------------------------------------------------------------------------------
LeonardosWardrobeManager.name = "LeonardosWardrobeManager"
LeonardosWardrobeManager.version = 1

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function LeonardosWardrobeManager.OnAddOnLoaded(event, addonName)
    if addonName ~= LeonardosWardrobeManager.name then return end

    LeonardosWardrobeManager:Initialize()
end

-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function LeonardosWardrobeManager:Initialize()

    -- Gets our characters name
    local ourName = GetUnitName("player")

    -- Sets the text for our label to ourName
    LeonardosWardrobeManagerWindowLabel:SetText(ourName)

    EVENT_MANAGER:UnregisterForEvent(LeonardosWardrobeManager.name, EVENT_ADD_ON_LOADED)
end

-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(LeonardosWardrobeManager.name, EVENT_ADD_ON_LOADED, LeonardosWardrobeManager.OnAddOnLoaded)
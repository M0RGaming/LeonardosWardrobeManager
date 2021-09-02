-- Main Table
LeonardosWardrobeManager = LeonardosWardrobeManager or {}

-- Aliases
local LWM = LeonardosWardrobeManager

-- Misc.
local NO_OUTFIT         = 0
local ALLIANCE_DEFAULT  = -1

-- Main Table Details
LWM.name = "LeonardosWardrobeManager"
LWM.fullName = "Leonardo's Wardrobe Manager"
LWM.allOutfits = {"No Outfit"}
LWM.allOutfitChoices = {0}
LWM.allAlliedOutfits = {"Alliance Default", "No Outfit"}
LWM.allAlliedOutfitChoices = {ALLIANCE_DEFAULT, NO_OUTFIT}
LWM.author = "@Leonardo1123"

LWM.variableVersion = 11

LWM.default = {
    defaultOutfitIndex      = NO_OUTFIT,
    combatOutfitIndex       = NO_OUTFIT,
    mainbarOutfitIndex      = NO_OUTFIT,
    backbarOutfitIndex      = NO_OUTFIT,
    stealthOutfitIndex      = NO_OUTFIT,

    perBarToggle = false,

    houseOutfitIndex        = NO_OUTFIT,
    dungeonOutfitIndex      = NO_OUTFIT,

    cyrodilOutfitIndex      = NO_OUTFIT,
    cyrodil_dOutfitIndex    = NO_OUTFIT,
    imperialOutfitIndex     = NO_OUTFIT,
    sewersOutfitIndex       = NO_OUTFIT,
    battlegroundOutfitIndex = NO_OUTFIT,

    dominionOutfitIndex     = NO_OUTFIT,
    auridonOutfitIndex      = ALLIANCE_DEFAULT,
    grahtwoodOutfitIndex    = ALLIANCE_DEFAULT,
    greenshadeOutfitIndex   = ALLIANCE_DEFAULT,
    khenarthiOutfitIndex    = ALLIANCE_DEFAULT,
    malabalOutfitIndex      = ALLIANCE_DEFAULT,
    reapersOutfitIndex      = ALLIANCE_DEFAULT,

    covenantOutfitIndex     = NO_OUTFIT,
    alikrOutfitIndex        = ALLIANCE_DEFAULT,
    bangkoraiOutfitIndex    = ALLIANCE_DEFAULT,
    betnikhOutfitIndex      = ALLIANCE_DEFAULT,
    glenumbraOutfitIndex    = ALLIANCE_DEFAULT,
    rivenspireOutfitIndex   = ALLIANCE_DEFAULT,
    stormhavenOutfitIndex   = ALLIANCE_DEFAULT,
    strosOutfitIndex        = ALLIANCE_DEFAULT,

    pactOutfitIndex         = NO_OUTFIT,
    balOutfitIndex          = ALLIANCE_DEFAULT,
    bleakrockOutfitIndex    = ALLIANCE_DEFAULT,
    deshaanOutfitIndex      = ALLIANCE_DEFAULT,
    eastmarchOutfitIndex    = ALLIANCE_DEFAULT,
    riftOutfitIndex         = ALLIANCE_DEFAULT,
    shadowfenOutfitIndex    = ALLIANCE_DEFAULT,
    stonefallsOutfitIndex   = ALLIANCE_DEFAULT,

    coldharbourOutfitIndex  = NO_OUTFIT,
    craglornOutfitIndex     = NO_OUTFIT,

    artaeumOutfitIndex      = NO_OUTFIT,
    greymoorOutfitIndex     = NO_OUTFIT,
    blackwoodOutfitIndex    = NO_OUTFIT,
    nelsweyrOutfitIndex     = NO_OUTFIT,
    summersetOutfitIndex    = NO_OUTFIT,
    vvardenfellOutfitIndex  = NO_OUTFIT,
    skyrimOutfitIndex       = NO_OUTFIT,

    arkthzandOutfitIndex    = NO_OUTFIT,
    clockworkOutfitIndex    = NO_OUTFIT,
    goldOutfitIndex         = NO_OUTFIT,
    hewOutfitIndex          = NO_OUTFIT,
    murkmireOutfitIndex     = NO_OUTFIT,
    reachOutfitIndex        = NO_OUTFIT,
    selsweyrOutfitIndex     = NO_OUTFIT,
    wrothgarOutfitIndex     = NO_OUTFIT,
}

-- Check for optional dependencies
LWM.LibFeedbackInstalled = nil ~= LibFeedback

-- Misc. declarations
local OUTFIT_OFFSET = 1
local isFirstTimePlayerActivated = true

-- Helper functions
function LWM.isDominion(zoneId)
    local res = false
    for _,v in pairs({381, 383, 108, 537, 58, 382}) do
        if zoneId == v then
            res = true
        end
    end
    return res
end

function LWM.isCovenant(zoneId)
    local res = false
    for _,v in pairs({104, 92, 535, 3, 20, 19, 534}) do
        if zoneId == v then
            res = true
        end
    end
    return res
end

function LWM.isPact(zoneId)
    local res = false
    for _,v in pairs({281, 280, 57, 101, 103, 117, 41}) do
        if zoneId == v then
            res = true
        end
    end
    return res
end

function LWM.SetStateOutfitChoice(state, index)
    if state == "DEFAULT" then
        LWM.ChangeOutfit(index)
    end

    LWM.vars[string.lower(state) .. "OutfitIndex"] = index
end

function LWM.ChangeOutfit(index)
    if index == 0 then
        UnequipOutfit()
    else
        EquipOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, index)
    end
end

function LWM.ChangeToCombatOutfit()
    if LWM.inCombat then
        if LWM.vars.perBarToggle then
            local weaponPair, _ = GetActiveWeaponPairInfo()
            local mainBar = (weaponPair == 1)

            if mainBar then
                LWM.ChangeOutfit(LWM.vars.mainbarOutfitIndex)
            else
                LWM.ChangeOutfit(LWM.vars.backbarOutfitIndex)
            end
        else
            LWM.ChangeOutfit(LWM.vars.combatOutfitIndex)
        end
    end
end

function LWM.ChangeToZoneOutfit()
    local allZoneIds = {
        [104]   = LWM.vars.alikrOutfitIndex,
        [381]   = LWM.vars.auridonOutfitIndex,
        [281]   = LWM.vars.balOutfitIndex,
        [92]    = LWM.vars.bangkoraiOutfitIndex,
        [535]   = LWM.vars.betnikhOutfitIndex,
        [1208]  = LWM.vars.arkthzandOutfitIndex,
        [1161]  = LWM.vars.greymoorOutfitIndex,
        [1261]  = LWM.vars.blackwoodOutfitIndex,
        [280]   = LWM.vars.bleakrockOutfitIndex,
        [980]   = LWM.vars.clockworkOutfitIndex,
        [347]   = LWM.vars.coldharbourOutfitIndex,
        [888]   = LWM.vars.craglornOutfitIndex,
        [57]    = LWM.vars.deshaanOutfitIndex,
        [3]     = LWM.vars.glenumbraOutfitIndex,
        [823]   = LWM.vars.goldOutfitIndex,
        [383]   = LWM.vars.grahtwoodOutfitIndex,
        [108]   = LWM.vars.greenshadeOutfitIndex,
        [101]   = LWM.vars.eastmarchOutfitIndex,
        [816]   = LWM.vars.hewOutfitIndex,
        [537]   = LWM.vars.khenarthiOutfitIndex,
        [58]    = LWM.vars.malabalOutfitIndex,
        [726]   = LWM.vars.murkmireOutfitIndex,
        [1086]  = LWM.vars.nelsweyrOutfitIndex,
        [382]   = LWM.vars.reapersOutfitIndex,
        [20]    = LWM.vars.rivenspireOutfitIndex,
        [117]   = LWM.vars.shadowfenOutfitIndex,
        [1133]  = LWM.vars.selsweyrOutfitIndex,
        [41]    = LWM.vars.stonefallsOutfitIndex,
        [19]    = LWM.vars.stormhavenOutfitIndex,
        [534]   = LWM.vars.strosOutfitIndex,
        [1011]  = LWM.vars.summersetOutfitIndex,
        [1207]  = LWM.vars.reachOutfitIndex,
        [103]   = LWM.vars.riftOutfitIndex,
        [849]   = LWM.vars.vvardenfellOutfitIndex,
        [1160]  = LWM.vars.skyrimOutfitIndex,
        [684]   = LWM.vars.wrothgarOutfitIndex,
    }

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if zoneId ~= GetParentZoneId(zoneId) then
        zoneId = GetParentZoneId(zoneId)
    end

    local index = allZoneIds[zoneId]

    if index ~= -1 then
        LWM.ChangeOutfit(index)
    else
        if LWM.isDominion(zoneId) then
            LWM.ChangeOutfit(LWM.vars.dominionOutfitIndex)
        elseif LWM.isCovenant(zoneId) then
            LWM.ChangeOutfit(LWM.vars.covenantOutfitIndex)
        elseif LWM.isPact(zoneId) then
            LWM.ChangeOutfit(LWM.vars.pactOutfitIndex)
        end
    end

    end

function LWM.ChangeToLocationOutfit()
    if GetCurrentZoneHouseId() ~= 0 then
        LWM.ChangeOutfit(LWM.vars.houseOutfitIndex)
    elseif IsActiveWorldBattleground() then
        LWM.ChangeOutfit(LWM.vars.battlegroundOutfitIndex)
    elseif IsPlayerInAvAWorld() then
        if IsInCyrodiil() then
            LWM.ChangeOutfit(LWM.vars.cyrodilOutfitIndex)
        elseif IsInImperialCity() then
            if GetCurrentMapIndex() then
                LWM.ChangeOutfit(LWM.vars.imperialOutfitIndex)
            else
                LWM.ChangeOutfit(LWM.vars.sewersOutfitIndex)
            end
        else
            LWM.ChangeOutfit(LWM.vars.cyrodil_dOutfitIndex)
        end
    elseif IsUnitInDungeon("player") then
        LWM.ChangeOutfit(LWM.vars.dungeonOutfitIndex)
    else
        LWM.ChangeToZoneOutfit()
    end
end

-- Event functions

function LWM.OnOutfitRenamed(_, _, _)
    for i=1,GetNumUnlockedOutfits() do
        LWM.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
    end
end

function LWM.OnPlayerActivated(_, initial)
    if initial then
        if isFirstTimePlayerActivated == false then -- After fast travel
            LWM.ChangeToLocationOutfit()
        else -- --------------------------------- after login
            isFirstTimePlayerActivated = false
        end
    else -- ------------------------------------- after reloadui
        isFirstTimePlayerActivated = false
    end
end

function LWM.OnPlayerCombatState(_, inCombat)
    if inCombat ~= LWM.inCombat then
        LWM.inCombat = inCombat
        if LWM.inCombat then
            LWM.ChangeToCombatOutfit()
        else
            if LWM.inStealth > 0 then
                LWM.ChangeOutfit(LWM.vars.stealthOutfitIndex)
            else
                LWM.ChangeToLocationOutfit()
            end
        end
    end
end

function LWM.OnPlayerStealthState(_, unitTag, StealthState)
    if StealthState ~= LWM.inStealth and unitTag == "player" then
        LWM.inStealth = StealthState
        if LWM.inStealth > 0 then
            LWM.ChangeOutfit(LWM.vars.stealthOutfitIndex)
        else
            if LWM.inCombat then
                LWM.ChangeToCombatOutfit()
            else
                LWM.ChangeToLocationOutfit()
            end
        end
    end
end

function LWM.OnPlayerRes(_)
    LWM.ChangeToLocationOutfit()
end

function LWM.OnPlayerUseOutfitStation(_)
    for i=1,GetNumUnlockedOutfits() do
        local name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
        if name == "" then
            name = "Outfit " .. tostring(i)

            LWM.allOutfits[i + OUTFIT_OFFSET] = name
            LWM.allOutfitChoices[i + OUTFIT_OFFSET] = i
            LWM.allAlliedOutfits[i + 2*OUTFIT_OFFSET] = name
            LWM.allAlliedOutfitChoices[i + 2*OUTFIT_OFFSET] = i
            RenameOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i, name)
        end
    end
end

-- "Main" functions

function LWM:Initialize()
    LWM.vars = ZO_SavedVars:NewCharacterIdSettings("LWMVars", LWM.variableVersion, nil, LWM.default, GetWorldName())

    local handlers = ZO_AlertText_GetHandlers() -- TODO: Make this safer
    handlers[EVENT_OUTFIT_EQUIP_RESPONSE] = function() end

    self.inCombat = IsUnitInCombat("player")
    self.inStealth = GetUnitStealthState("player")

    for i=1,GetNumUnlockedOutfits() do
        local name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)

        self.allOutfits[i + OUTFIT_OFFSET] = name
        self.allOutfitChoices[i + OUTFIT_OFFSET] = i
        self.allAlliedOutfits[i + 2*OUTFIT_OFFSET] = name
        self.allAlliedOutfitChoices[i + 2*OUTFIT_OFFSET] = i
    end

    if LWM.LibFeedbackInstalled then
        button, LWM.feedback = LibFeedback:initializeFeedbackWindow(
                LWM,
                LWM.fullName,
                WINDOW_MANAGER:CreateTopLevelWindow("LWMDummyControl"),
                LWM.author,
                {CENTER , GuiRoot , CENTER , 10, 10},
                {0,5000,50000},
                "Send feedback or a tip! Please consider reporting any bugs to ESOUI or GitHub as well."
        )
        button:SetHidden(true)

        SLASH_COMMANDS['/lwmfeedback'] = function(_)
            LWM.feedback:SetHidden(false)
        end
    else
        SLASH_COMMANDS['/lwmfeedback'] = function(_)
            d("Install LibFeedback to use this function.")
        end
    end

    LWM.initSettings()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OUTFIT_RENAME_RESPONSE, self.OnOutfitRenamed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_REINCARNATED, self.OnPlayerRes)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DYEING_STATION_INTERACT_START , self.OnPlayerUseOutfitStation)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED , self.ChangeToCombatOutfit)
end

function LWM.OnAddOnLoaded(_, addonName)
    if addonName == LWM.name then
        LWM:Initialize()
        EVENT_MANAGER:UnregisterForEvent(LWM.name, EVENT_ADD_ON_LOADED)
    end
end

EVENT_MANAGER:RegisterForEvent(LWM.name, EVENT_ADD_ON_LOADED, LWM.OnAddOnLoaded)

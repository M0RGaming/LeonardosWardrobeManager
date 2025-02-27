-- Main Table
LeonardosWardrobeManager = {}

-- Aliases
local LAM2 = LibAddonMenu2
local LWM = LeonardosWardrobeManager

-- Main Table Details
LWM.name = "LeonardosWardrobeManager"
LWM.fullName = "Leonardo's Wardrobe Manager"
LWM.allOutfits = {"No Outfit"}
LWM.allOutfitChoices = {0}
LWM.username = "@Leonardo1123"

LWM.variableVersion = 9
LWM.default = {
    defaultOutfitIndex = 0,
    combatOutfitIndex = 0,
    mainbarOutfitIndex = 0,
    backbarOutfitIndex = 0,
    stealthOutfitIndex = 0,

    perBarToggle = false,
    --perAbilityToggle = false,

    --abilitymain1OutfitIndex = 0,
    --abilitymain2OutfitIndex = 0,
    --abilitymain3OutfitIndex = 0,
    --abilitymain4OutfitIndex = 0,
    --abilitymain5OutfitIndex = 0,
    --abilitymain6OutfitIndex = 0,
    --
    --abilityback1OutfitIndex = 0,
    --abilityback2OutfitIndex = 0,
    --abilityback3OutfitIndex = 0,
    --abilityback4OutfitIndex = 0,
    --abilityback5OutfitIndex = 0,
    --abilityback6OutfitIndex = 0,

    houseOutfitIndex = 0,
    dungeonOutfitIndex = 0,

    cyrodiil_overworldOutfitIndex = 0,
    cyrodiil_delveOutfitIndex = 0,
    imperialOutfitIndex = 0,
    sewersOutfitIndex = 0,
    battlegroundOutfitIndex = 0,
}

-- Check for optional dependencies
LWM.LibFeedbackInstalled = false

-- Misc. declarations
OUTFIT_OFFSET = 1
isFirstTimePlayerActivated = true

-- LAM data

panelData = {
    type = "panel",
    name = LWM.fullName,
    registerForRefresh = true
}

function LWM.GetAbilityName(rawSlot, bar)
    bar = bar or HOTBAR_CATEGORY_PRIMARY
    local slot = rawSlot + 2

    id = GetSlotBoundId(slot, bar)
    name = GetAbilityName(id)

    return name
end

function LWM.CheckForNoDuration(slot, bar)
    bar = bar or HOTBAR_CATEGORY_PRIMARY
    slot = slot + 2

    id = GetSlotBoundId(slot, bar)
    duration = GetAbilityDuration(id)

    return duration == 0
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
        choicesValues = LWM.allOutfitChoices,
        getFunc = function() return LWM.vars.defaultOutfitIndex end,
        setFunc = function(var) LWM.SetStateOutfitChoice("DEFAULT", var) end,
        reference = "LWM_Default_Dropdown"
    },
    [3] = {
        type = "submenu",
        name = "Combat",
        tooltip = "Options related to combat and stealth",
        controls = {
            [1] = {
                type = "dropdown",
                name = "Stealth Outfit",
                tooltip = "The outfit to be switched to upon entering stealth",
                choices = LWM.allOutfits,
                choicesValues = LWM.allOutfitChoices,
                getFunc = function() return LWM.vars.stealthOutfitIndex end,
                setFunc = function(var) LWM.SetStateOutfitChoice("STEALTH", var) end,
                reference = "LWM_Stealth_Dropdown"
            },
            [2] = {
                type = "divider",
            },
            [3] = {
                type = "checkbox",
                name = "Ability Bar Outfits",
                tooltip = "Have separate outfits for your Main and Backup ability bars?",
                choices = LWM.allOutfits,
                getFunc = function() return LWM.vars.perBarToggle end,
                setFunc = function() LWM.vars.perBarToggle = not LWM.vars.perBarToggle end,
                reference = "LWM_Per_Bar_Checkbox"
            },
            [4] = {
                type = "dropdown",
                name = "Combat Outfit",
                tooltip = "The outfit to be switched to upon entering combat",
                choices = LWM.allOutfits,
                choicesValues = LWM.allOutfitChoices,
                getFunc = function() return LWM.vars.combatOutfitIndex end,
                setFunc = function(var) LWM.SetStateOutfitChoice("COMBAT", var) end,
                reference = "LWM_Combat_Dropdown",
                disabled = function() return LWM.vars.perBarToggle end
            },
            [5] = {
                type = "dropdown",
                name = "Main Bar Outfit",
                tooltip = "The outfit to be switched to when using your main ability bar",
                choices = LWM.allOutfits,
                choicesValues = LWM.allOutfitChoices,
                getFunc = function() return LWM.vars.mainbarOutfitIndex end,
                setFunc = function(var) LWM.SetStateOutfitChoice("MAINBAR", var) end,
                reference = "LWM_Mainbar_Dropdown",
                disabled = function() return not LWM.vars.perBarToggle end
            },
            [6] = {
                type = "dropdown",
                name = "Backup Bar Outfit",
                tooltip = "The outfit to be switched to when using your backup ability bar",
                choices = LWM.allOutfits,
                choicesValues = LWM.allOutfitChoices,
                getFunc = function() return LWM.vars.backbarOutfitIndex end,
                setFunc = function(var) LWM.SetStateOutfitChoice("BACKBAR", var) end,
                reference = "LWM_Backbar_Dropdown",
                disabled = function() return not LWM.vars.perBarToggle end
            },
            --[7] = {
            --    type = "divider",
            --},
            --[8] = {
            --    type = "checkbox",
            --    name = "Ability Bar Outfits",
            --    tooltip = "Have separate outfits for your Main and Backup ability bars?",
            --    choices = LWM.allOutfits,
            --    getFunc = function() return LWM.vars.perAbilityToggle end,
            --    setFunc = function() LWM.vars.perAbilityToggle = not LWM.vars.perAbilityToggle end,
            --    reference = "LWM_Per_Ability_Checkbox"
            --},
            --[9] = {
            --    type = "submenu",
            --    name = "Main Bar",
            --    tooltip = "Options related to the Main Bar abilities",
            --    disabled = function() return not LWM.vars.perAbilityToggle end,
            --    controls = {
            --        [1] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(1) end,
            --            tooltip = "The outfit to be switched to when using Ability 1",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilitymain1OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYMAIN1", var) end,
            --            disabled = LWM.CheckForNoDuration(1),
            --            reference = "LWM_Ability_Main1_Dropdown",
            --        },
            --        [2] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(2) end,
            --            tooltip = "The outfit to be switched to when using Ability 2",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilitymain2OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYMAIN2", var) end,
            --            disabled = LWM.CheckForNoDuration(2),
            --            reference = "LWM_Ability_Main2_Dropdown",
            --        },
            --        [3] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(3) end,
            --            tooltip = "The outfit to be switched to when using Ability 3",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilitymain3OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYMAIN3", var) end,
            --            disabled = LWM.CheckForNoDuration(3),
            --            reference = "LWM_Ability_Main3_Dropdown",
            --        },
            --        [4] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(4) end,
            --            tooltip = "The outfit to be switched to when using Ability 4",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilitymain4OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYMAIN4", var) end,
            --            disabled = LWM.CheckForNoDuration(4),
            --            reference = "LWM_Ability_Main4_Dropdown",
            --        },
            --        [5] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(5) end,
            --            tooltip = "The outfit to be switched to when using Ability 5",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilitymain5OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYMAIN5", var) end,
            --            disabled = LWM.CheckForNoDuration(5),
            --            reference = "LWM_Ability_Main5_Dropdown",
            --        },
            --        [6] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(6) end,
            --            tooltip = "The outfit to be switched to when using Ultimate",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilitymain6OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYMAIN6", var) end,
            --            disabled = LWM.CheckForNoDuration(6),
            --            reference = "LWM_Ability_Main6_Dropdown",
            --        },
            --    }
            --},
            --[10] = {
            --    type = "submenu",
            --    name = "Back Bar",
            --    tooltip = "Options related to the Back Bar abilities",
            --    disabled = function() return not LWM.vars.perAbilityToggle end,
            --    controls = {
            --        [1] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(1, HOTBAR_CATEGORY_BACKUP) end,
            --            tooltip = "The outfit to be switched to when using Ability 1",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilityback1OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYBACK1", var) end,
            --            disabled = LWM.CheckForNoDuration(1, HOTBAR_CATEGORY_BACKUP),
            --            reference = "LWM_Ability_Back1_Dropdown",
            --        },
            --        [2] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(2, HOTBAR_CATEGORY_BACKUP) end,
            --            tooltip = "The outfit to be switched to when using Ability 2",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilityback2OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYBACK2", var) end,
            --            disabled = LWM.CheckForNoDuration(2, HOTBAR_CATEGORY_BACKUP),
            --            reference = "LWM_Ability_Back2_Dropdown",
            --        },
            --        [3] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(3, HOTBAR_CATEGORY_BACKUP) end,
            --            tooltip = "The outfit to be switched to when using Ability 3",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilityback3OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYBACK3", var) end,
            --            disabled = LWM.CheckForNoDuration(3, HOTBAR_CATEGORY_BACKUP),
            --            reference = "LWM_Ability_Back3_Dropdown",
            --        },
            --        [4] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(4, HOTBAR_CATEGORY_BACKUP) end,
            --            tooltip = "The outfit to be switched to when using Ability 4",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilityback4OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYBACK4", var) end,
            --            disabled = LWM.CheckForNoDuration(4, HOTBAR_CATEGORY_BACKUP),
            --            reference = "LWM_Ability_Back4_Dropdown",
            --        },
            --        [5] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(5, HOTBAR_CATEGORY_BACKUP) end,
            --            tooltip = "The outfit to be switched to when using Ability 5",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilityback5OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYBACK5", var) end,
            --            disabled = LWM.CheckForNoDuration(5, HOTBAR_CATEGORY_BACKUP),
            --            reference = "LWM_Ability_Back5_Dropdown",
            --        },
            --        [6] = {
            --            type = "dropdown",
            --            name = function() return LWM.GetAbilityName(6, HOTBAR_CATEGORY_BACKUP) end,
            --            tooltip = "The outfit to be switched to when using Ultimate",
            --            choices = LWM.allOutfits,
            --            choicesValues = LWM.allOutfitChoices,
            --            getFunc = function() return LWM.vars.abilityback6OutfitIndex end,
            --            setFunc = function(var) LWM.SetStateOutfitChoice("ABILITYBACK6", var) end,
            --            disabled = LWM.CheckForNoDuration(6, HOTBAR_CATEGORY_BACKUP),
            --            reference = "LWM_Ability_Back6_Dropdown",
            --        },
            --    }
            --}
        }
    },
    [4] = {
        type = "submenu",
        name = "Locations",
        tooltip = "Options related to locations",
        controls = {
            [1] = {
                type = "dropdown",
                name = "House Outfit",
                tooltip = "The outfit to be worn in houses",
                choices = LWM.allOutfits,
                choicesValues = LWM.allOutfitChoices,
                getFunc = function() return LWM.vars.houseOutfitIndex end,
                setFunc = function(var) LWM.SetStateOutfitChoice("HOUSE", var) end,
                reference = "LWM_House_Dropdown"
            },
            [2] = {
                type = "dropdown",
                name = "Dungeon Outfit",
                tooltip = "The outfit to be worn in dungeons",
                choices = LWM.allOutfits,
                choicesValues = LWM.allOutfitChoices,
                getFunc = function() return LWM.vars.dungeonOutfitIndex end,
                setFunc = function(var) LWM.SetStateOutfitChoice("DUNGEON", var) end,
                reference = "LWM_Dungeon_Dropdown"
            },
            [3] = {
                type = "submenu",
                name = "PVP",
                tooltip = "Options related to PVP locations",
                controls = {
                    [1] = {
                        type = "dropdown",
                        name = "Battleground Outfit",
                        tooltip = "The outfit to be worn in Battleground",
                        choices = LWM.allOutfits,
                        choicesValues = LWM.allOutfitChoices,
                        getFunc = function() return LWM.vars.battlegroundOutfitIndex end,
                        setFunc = function(var) LWM.SetStateOutfitChoice("BATTLEGROUND", var) end,
                        reference = "LWM_Battleground_Dropdown"
                    },
                    [2] = {
                        type = "divider",
                    },
                    [3] = {
                        type = "dropdown",
                        name = "Cyrodiil Overworld Outfit",
                        tooltip = "The outfit to be worn in Cyrodiil",
                        choices = LWM.allOutfits,
                        choicesValues = LWM.allOutfitChoices,
                        getFunc = function() return LWM.vars.cyrodiil_overworldOutfitIndex end,
                        setFunc = function(var) LWM.SetStateOutfitChoice("CYRODIIL_OVERWORLD", var) end,
                        reference = "LWM_Cyrodiil_Overworld_Dropdown"
                    },
                    [4] = {
                        type = "dropdown",
                        name = "Cyrodiil Delve Outfit",
                        tooltip = "The outfit to be worn in Cyrodiil Delves",
                        choices = LWM.allOutfits,
                        choicesValues = LWM.allOutfitChoices,
                        getFunc = function() return LWM.vars.cyrodiil_delveOutfitIndex end,
                        setFunc = function(var) LWM.SetStateOutfitChoice("CYRODIIL_DELVE", var) end,
                        reference = "LWM_Cyrodiil_Delve_Dropdown"
                    },
                    [5] = {
                        type = "dropdown",
                        name = "Imperial City Outfit",
                        tooltip = "The outfit to be worn in Imperial City",
                        choices = LWM.allOutfits,
                        choicesValues = LWM.allOutfitChoices,
                        getFunc = function() return LWM.vars.imperialOutfitIndex end,
                        setFunc = function(var) LWM.SetStateOutfitChoice("IMPERIAL", var) end,
                        reference = "LWM_Imperial_Dropdown"
                    },
                    [6] = {
                        type = "dropdown",
                        name = "Imperial Sewers Outfit",
                        tooltip = "The outfit to be worn in Imperial Sewers",
                        choices = LWM.allOutfits,
                        choicesValues = LWM.allOutfitChoices,
                        getFunc = function() return LWM.vars.sewersOutfitIndex end,
                        setFunc = function(var) LWM.SetStateOutfitChoice("SEWERS", var) end,
                        reference = "LWM_Sewers_Dropdown"
                    },
                }
            },
        }
    }
}

-- Helper functions

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

-- Event functions

function LWM.OnOutfitRenamed(_, _, _)
    for i=1,GetNumUnlockedOutfits() do
        LWM.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
    end

    if LWM_Default_Dropdown then LWM_Default_Dropdown:UpdateChoices() end
    if LWM_Combat_Dropdown then LWM_Combat_Dropdown:UpdateChoices() end
    if LWM_Stealth_Dropdown then LWM_Stealth_Dropdown:UpdateChoices() end
    if LWM_Mainbar_Dropdown then LWM_Mainbar_Dropdown:UpdateChoices() end
    if LWM_Backbar_Dropdown then LWM_Backbar_Dropdown:UpdateChoices() end
    if LWM_House_Dropdown then LWM_House_Dropdown:UpdateChoices() end
    if LWM_Cyrodiil_Overworld_Dropdown then LWM_Cyrodiil_Overworld_Dropdown:UpdateChoices() end
    if LWM_Cyrodiil_Delve_Dropdown then LWM_Cyrodiil_Delve_Dropdown:UpdateChoices() end
    if LWM_Imperial_Dropdown then LWM_Imperial_Dropdown:UpdateChoices() end
    if LWM_Sewers_Dropdown then LWM_Sewers_Dropdown:UpdateChoices() end
    if LWM_Battleground_Dropdown then LWM_Battleground_Dropdown:UpdateChoices() end
end

function LWM.ChangeToLocationOutfit()
    if GetCurrentZoneHouseId() ~= 0 then
        LWM.ChangeOutfit(LWM.vars.houseOutfitIndex)
    elseif IsActiveWorldBattleground() then
        LWM.ChangeOutfit(LWM.vars.battlegroundOutfitIndex)
    elseif IsPlayerInAvAWorld() then
        if IsInCyrodiil() then
            LWM.ChangeOutfit(LWM.vars.cyrodiil_overworldOutfitIndex)
        elseif IsInImperialCity() then
            if GetCurrentMapIndex() then
                LWM.ChangeOutfit(LWM.vars.imperialOutfitIndex)
            else
                LWM.ChangeOutfit(LWM.vars.sewersOutfitIndex)
            end
        else
            LWM.ChangeOutfit(LWM.vars.cyrodiil_delveOutfitIndex)
        end
    elseif IsUnitInDungeon("player") then
        LWM.ChangeOutfit(LWM.vars.dungeonOutfitIndex)
    else
        LWM.ChangeOutfit(LWM.vars.defaultOutfitIndex)
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
        name = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
        if name == "" then
            name = "Outfit " .. tostring(i)
            LWM.allOutfits[i + OUTFIT_OFFSET] = name
            LWM.allOutfitChoices[i + OUTFIT_OFFSET] = i
            RenameOutfit(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i, name)
        end
    end
end

--function LWM.OnUseAction(event, rawIndex)
--    local index = rawIndex - 2
--    local weaponPair, _ = GetActiveWeaponPairInfo()
--    local mainBar = (weaponPair == 1)
--
--    local bar = HOTBAR_CATEGORY_PRIMARY
--    if not mainBar then bar = HOTBAR_CATEGORY_BACKUP end
--
--    local hasDuration = not LWM.CheckForNoDuration(index, bar)
--
--    if hasDuration then
--        d(LWM.GetAbilityName(index) .. " cast")
--    end
--end
--
--function LWM.ActionFinished(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
--    if result == ACTION_RESULT_EFFECT_FADED then
--        d(abilityId)
--        d(GetAbilityName(abilityId))
--        d("==========")
--    end
--end

-- "Main" functions

function LWM:Initialize()
    LWM.vars = ZO_SavedVars:NewCharacterIdSettings("LWMVars", LWM.variableVersion, nil, LWM.default, GetWorldName())

    local handlers = ZO_AlertText_GetHandlers() -- TODO: Make this safer using code below
    handlers[EVENT_OUTFIT_EQUIP_RESPONSE] = function() end

    --local handlers = ZO_AlertText_GetHandlers()
    --local originalHandler = handlers[EVENT_OUTFIT_CHANGE_RESPONSE]
    --handlers[EVENT_OUTFIT_CHANGE_RESPONSE] = function(result, actorCategory, outfitIndex)
    --    if result == something then
    --        return false -- do not show the alert
    --    else
    --        return originalHandler(result, actorCategory, outfitIndex)
    --    end
    --end

    self.inCombat = IsUnitInCombat("player")
    self.inStealth = GetUnitStealthState("player")

    for i=1,GetNumUnlockedOutfits() do
        self.allOutfits[i + OUTFIT_OFFSET] = GetOutfitName(GAMEPLAY_ACTOR_CATEGORY_PLAYER, i)
        self.allOutfitChoices[i + OUTFIT_OFFSET] = i
    end

    if LWM.LibFeedbackInstalled then
        button, LWM.feedback = LibFeedback:initializeFeedbackWindow(
                LWM,
                LWM.fullName,
                WINDOW_MANAGER:CreateTopLevelWindow("LWMDummyControl"),
                LWM.username,
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

    LAM2:RegisterAddonPanel("LWMOptions", panelData)
    LAM2:RegisterOptionControls("LWMOptions", optionsData)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_OUTFIT_RENAME_RESPONSE, self.OnOutfitRenamed)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, self.OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_STEALTH_STATE_CHANGED, self.OnPlayerStealthState)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_REINCARNATED, self.OnPlayerRes)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_DYEING_STATION_INTERACT_START , self.OnPlayerUseOutfitStation)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED , self.ChangeToCombatOutfit)
    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ACTION_SLOT_ABILITY_USED , self.OnUseAction)
    --EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT , self.ActionFinished)
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
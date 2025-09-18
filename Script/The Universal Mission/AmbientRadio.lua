-- ====================================================================================
--  TUM.AMBIENTRADIO - HANDLES AMBIENT CHATTER/RADIO MESSAGES REACTING TO A MISSION EVENT
-- ====================================================================================
-- (local) doAmbientChatter(stringID, callsign, minimumDelaySinceLastMessage, replacements, centerPoint, maxRadiusInNM)
-- (local) onEventDead(event)
-- (local) onEventEjection(event)
-- (local) onEventHit(event)
-- (local) onEventKill(event)
-- (local) onEventLand(event)
-- (local) onEventLandingAfterEjection(event)
-- (local) onEventPlayerEnterUnit(event)
-- (local) onEventShootingStart(event)
-- (local) onEventShotFriendly(event)
-- (local) onEventShotHostile(event)
-- (local) onEventShot(event)
-- (local) onEventTakeOff(event)
-- TUM.ambientRadio.onEvent(event)
-- ====================================================================================

TUM.ambientRadio = {}

do
    local lastAmbientChatter = 0

    local function getNearestFriendlyAircraft(point2)
        local units = {}

        local planeGroups = coalition.getGroups(TUM.settings.getPlayerCoalition(), Group.Category.AIRPLANE)
        for _,g in ipairs(planeGroups) do
            local groupUnits = g:getUnits()
            for _,u in ipairs(groupUnits) do
                table.insert(units, u)
            end
        end

        local heloGroups = coalition.getGroups(TUM.settings.getPlayerCoalition(), Group.Category.HELICOPTER)
        for _,g in ipairs(heloGroups) do
            local groupUnits = g:getUnits()
            for _,u in ipairs(groupUnits) do
                table.insert(units, u)
            end
        end

        if #units == 0 then return nil end

        return DCSEx.dcs.getNearestObject(point2, units)
    end

    -------------------------------------
    -- Plays an ambient radio message
    -------------------------------------
    -- @param messageID ID of the radio message in scrambe.db.radioMessages
    -- @param replacements String placeholders ($1, $2...) replacements in the message
    -- @param callsign (optional) Callsign of the caller unit
    -- @param minimumDelaySinceLastMessage (optional) If the last message happened less than this number of seconds from the current time, don't play the message
    -- @param replacements (optional) Table of strings to use as replacement for $1, $2, $3...
    -- @param centerPoint (optional) Center point used for max radius measurement
    -- @param maxRadiusInNM (optional) Maximum radius (in nm) beyond which units will not recieve the message
    -------------------------------------
    local function doAmbientChatter(messageID, replacements, callsign, minimumDelaySinceLastMessage, centerPoint, maxRadiusInNM)
        if not callsign and centerPoint then
            local nearestAircraft = getNearestFriendlyAircraft(centerPoint)
            if nearestAircraft then
                callsign = nearestAircraft:getCallsign()
            else
                callsign = "AIRCRAFT"
            end
        end

        -- Check parameters
        callsign = callsign or "AIRCRAFT"
        minimumDelaySinceLastMessage = minimumDelaySinceLastMessage or 1
        if maxRadiusInNM then maxRadiusInNM = DCSEx.converter.nmToMeters(maxRadiusInNM) end

        -- Don't play this message if another message was played too recently
        local currentTime = timer.getAbsTime()
        if currentTime < lastAmbientChatter + minimumDelaySinceLastMessage then return end
        lastAmbientChatter = currentTime

        local players = coalition.getPlayers(TUM.settings.getPlayerCoalition())
        if not players or #players == 0 then return end

        for _,p in pairs(players) do
            local tooFar = false

            -- If the message is restricted to a given zone, make sure the player isn't too far
            if centerPoint and maxRadiusInNM then
                if DCSEx.math.getDistance2D(centerPoint, p:getPoint()) > maxRadiusInNM then
                    tooFar = true
                end
            end

            if not tooFar then
                TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(p), messageID, replacements, callsign)
            end
        end
    end

    ----------------------------------------------
    -- Called when a DEAD event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventDead(event)
        if not event.initiator then return end -- No initiator
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Initiator isn't an unit
        if event.initiator:getCoalition() ~= TUM.settings.getPlayerCoalition() then return end -- Not a friendly

        local unitDesc = event.initiator:getDesc()

        if unitDesc.category == Unit.Category.AIRPLANE or unitDesc.category == Unit.Category.HELICOPTER then
            doAmbientChatter("commandFriendlyDown", { event.initiator:getCallsign() }, "COMMAND", 1)
        end
    end

    ----------------------------------------------
    -- Called when an EJECTION event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventEjection(event)
        if not event.initiator then return end -- No initator
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Initiator isn't an unit
        if event.initiator:getCoalition() ~= TUM.settings.getPlayerCoalition() then return end -- Initiator isn't a friendly
        if event.initiator:getPlayerName() then return end -- No "ejecting!" message for players, so it won't cut the "mission failed" music which is played at the same time
        if TUM.wingmen.getUnitWingmanNumber(event.initiator) then return end -- Wingmen have their own "I'm going down!" messages

        doAmbientChatter("pilotEjecting", nil, event.initiator:getCallsign(), 1)
    end

    ----------------------------------------------
    -- Called when a HIT event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventHit(event)
        if not event.target then return end -- No target
        if Object.getCategory(event.target) ~= Object.Category.UNIT then return end -- Target isn't an unit
        if event.target:getCoalition() ~= TUM.settings.getPlayerCoalition() then return end -- Target isn't a friendly

        -- Blue on blue event
        if event.initiator then
            if Object.getCategory(event.initiator) == Object.Category.UNIT then -- Attacker is an unit
                if event.initiator:getCoalition() == TUM.settings.getPlayerCoalition() then -- Attacker is a friendly
                    doAmbientChatter("commandBlueOnBlue", nil, "COMMAND", 1)
                    return
                end
            end
        end

        -- Friendly aircraft hit
        if event.target:getDesc().category == Unit.Category.AIRPLANE or event.target:getDesc().category == Unit.Category.HELICOPTER then
            if Object.getCategory(event.initiator) == Object.Category.UNIT then
                if not event.initiator:getPlayerName() then -- Players don't radio out when they're hit
                    doAmbientChatter("pilotImHit", nil, event.target:getCallsign(), 3)
                end
            end
        end
    end

    ----------------------------------------------
    -- Called when a KILL event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventKill(event)
        if not event.target or not event.initiator then return end -- No event target or initiator
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Killer isn't an unit
        if event.initiator:getCoalition() ~= TUM.settings.getPlayerCoalition() then return end -- Killer isn't a friendly
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) and event.initiator:getPlayerName() then return end -- No player chatter in MP

        local targetDesc = event.target:getDesc()

        local killerName = nil
        if event.initiator:getCallsign() then
            killerName = event.initiator:getCallsign()
        else
            killerName = event.initiator:getName()
        end

        local killMessage = "pilotKillGround"

        if Object.getCategory(event.target) == Object.Category.SCENERY then
            if TUM.objectives.getSceneryObjectObjective(event.target) then
                doAmbientChatter("pilotKillStrike", nil, killerName, 1)
            else
                return -- Building was not a scenery target, congratulations you just bombed a random civilian structure lol
            end
        elseif Object.getCategory(event.target) == Object.Category.STATIC then
            killMessage = "pilotKillStrike"
            doAmbientChatter("pilotKillStrike", nil, killerName, 1)
        elseif Object.getCategory(event.target) == Object.Category.UNIT then
            local killUnitType = Library.objectNames.get(event.target) -- Library.objectNames.getGeneric(event.target)
            local minMessageInterval = 2

            if targetDesc.category == Unit.Category.AIRPLANE then
                killMessage = "pilotKillAir"
                killUnitType = Library.objectNames.get(event.target)
            elseif targetDesc.category == Unit.Category.HELICOPTER then
                killMessage = "pilotKillAir"
                killUnitType = Library.objectNames.get(event.target)
            elseif targetDesc.category == Unit.Category.GROUND_UNIT then
                if event.target:hasAttribute("Infantry") then
                    killMessage = "pilotKillInfantry"
                    minMessageInterval = 4
                else
                    killMessage = "pilotKillGround"
                end
            elseif targetDesc.category == Unit.Category.SHIP then
                killMessage = "pilotKillShip"
            elseif targetDesc.category == Unit.Category.STRUCTURE then
                killMessage = "pilotKillStrike"
            end

            doAmbientChatter(killMessage, killUnitType, killerName, minMessageInterval)
        end
    end

    ----------------------------------------------
    -- Called when a LAND event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventLand(event)
        if not event.initiator then return end -- No event initiator
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Initiator isn't an unit
        if event.initiator:getCoalition() ~= TUM.settings.getPlayerCoalition() then return end -- Not a friendly
        if not event.place then return end -- Not landed at an airbase (e.g. helicopter landing on the ground)

        local baseName = event.place:getName():upper()

        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) or not event.initiator:getPlayerName() then
            doAmbientChatter("atcSafeLanding", {event.initiator:getCallsign(), baseName}, baseName.." ATC", 1)
        end
    end

    ----------------------------------------------
    -- Called when a LANDING_AFTER_EJECTION event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventLandingAfterEjection(event)
        if not event.initiator then return end -- No event initiator
        if event.initiator:getCoalition() ~= TUM.settings.getPlayerCoalition() then return end -- Not a friendly

        doAmbientChatter("commandFriendlyPilotOnGround", nil, "COMMAND", 1)
    end

    ----------------------------------------------
    -- Called when a PLAYER_ENTER_UNIT event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventPlayerEnterUnit(event)
        if not event.initiator then return end -- No event initiator

        -- TODO
    end

    ----------------------------------------------
    -- Called when a SHOOTING_START event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventShootingStart(event)
        if not event.initiator then return end -- No event initiator
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Initiator isn't an unit

        -- Plane or helicopter
        if event.initiator:getDesc().category == Unit.Category.AIRPLANE or event.initiator:getDesc().category == Unit.Category.HELICOPTER then
            if event.initiator:getCoalition() == TUM.settings.getPlayerCoalition() then
                if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) and event.initiator:getPlayerName() then return end -- No player chatter in MP
                doAmbientChatter("pilotLaunchGuns", nil, event.initiator:getCallsign(), 2)
                return
            end
        end

        -- AAA
        if event.initiator:hasAttribute("AAA") and event.initiator:getCoalition() == TUM.settings.getEnemyCoalition() then
            doAmbientChatter("pilotWarningAAA", nil, nil, 2, event.initiator:getPoint(), 8)
            return
        end
    end

    --------------------------------------------------------------
    -- Called when a SHOT event happens, with a friendly initiator
    --
    -- @param event Event data
    --------------------------------------------------------------
    local function onEventShotFriendly(event)
        if not event.initiator then return end -- No event initiator
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Initiator isn't an unit
        local unitCategory = event.initiator:getDesc().category
        local weaponDesc = event.weapon:getDesc()

        if unitCategory == Unit.Category.AIRPLANE or unitCategory == Unit.Category.HELICOPTER then
            if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) and event.initiator:getPlayerName() then return end -- No player chatter in MP

            if weaponDesc.category == Weapon.Category.BOMB then
                doAmbientChatter("pilotLaunchPickle", nil, event.initiator:getCallsign(), 1)
            elseif weaponDesc.category == Weapon.Category.ROCKET then
                doAmbientChatter("pilotLaunchRocket", nil, event.initiator:getCallsign(), 1)
            elseif weaponDesc.category == Weapon.Category.MISSILE then
                if weaponDesc.missileCategory == Weapon.MissileCategory.AAM then
                    if weaponDesc.guidance == Weapon.GuidanceType.IR then
                        doAmbientChatter("pilotLaunchFox2", nil, event.initiator:getCallsign(), 1)
                    elseif weaponDesc.guidance == Weapon.GuidanceType.RADAR_ACTIVE then
                        doAmbientChatter("pilotLaunchFox3", nil, event.initiator:getCallsign(), 1)
                    elseif weaponDesc.guidance == Weapon.GuidanceType.RADAR_SEMI_ACTIVE then
                        doAmbientChatter("pilotLaunchFox1", nil, event.initiator:getCallsign(), 1)
                    else
                        doAmbientChatter("pilotLaunchRifle", nil, event.initiator:getCallsign(), 1)
                    end
                elseif weaponDesc.missileCategory == Weapon.MissileCategory.ANTI_SHIP or weaponDesc.typeName == "weapons.missiles.AGM_84D" then
                    doAmbientChatter("pilotLaunchBruiser", nil, event.initiator:getCallsign(), 1)
                elseif weaponDesc.guidance == Weapon.GuidanceType.RADAR_PASSIVE then
                    doAmbientChatter("pilotLaunchMagnum", nil, event.initiator:getCallsign(), 1)
                else
                    doAmbientChatter("pilotLaunchRifle", nil, event.initiator:getCallsign(), 1)
                end
            end
        -- elseif unitCategory == Unit.Category.GROUND_UNIT then
        --     if event.initiator:hasAttribute("MANPADS") then
        --         -- Do nothing, no message for MANPADS
        --     elseif event.initiator:hasAttribute("IR Guided SAM") then
        --         -- doAmbientChatter("Friendly SAM engaging", nil, "Air defense HQ", 2)
        --     elseif event.initiator:hasAttribute("SAM") then
        --         -- doAmbientChatter("Friendly SAM engaging", nil, "Air defense HQ", 2)
        --     end
        -- elseif unitCategory == Unit.Category.SHIP then
            -- TODO
        end
    end

    ---------------------------------------------------------------------
    -- Called when a SHOT event happens, with a hostile or neutral initiator
    --
    -- @param event Event data
    ---------------------------------------------------------------------
    local function onEventShotHostile(event)
        if not event.initiator then return end -- No event initiator
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Initiator isn't an unit

        if event.initiator:getDesc().category == Unit.Category.AIRPLANE or event.initiator:getDesc().category == Unit.Category.HELICOPTER then
            -- if weaponDesc.category == Weapon.Category.MISSILE then
            --     if weaponDesc.missileCategory == Weapon.MissileCategory.AAM then
            --         doAmbientChatter("Missile!", nil, nil, 2, event.initiator:getPoint(), 8)
            --     end
            -- end
        elseif event.initiator:getDesc().category == Unit.Category.GROUND_UNIT or event.initiator:getDesc().category == Unit.Category.SHIP then
            if event.initiator:hasAttribute("MANPADS") then
                doAmbientChatter("pilotWarningMANPADS", nil, nil, 2, event.initiator:getPoint(), 8)
            elseif event.initiator:hasAttribute("IR Guided SAM") then
                doAmbientChatter("pilotWarningSAMLaunch", nil, nil, 2, event.initiator:getPoint(), 12)
            elseif event.initiator:hasAttribute("SAM SR") then
                doAmbientChatter("pilotWarningSAMLaunch", nil, nil, 2, event.initiator:getPoint(), 16)
            elseif event.initiator:hasAttribute("SAM") or event.initiator:hasAttribute("SAM LL") or event.initiator:hasAttribute("SAM CC") or event.initiator:hasAttribute("SAM LR") then
                doAmbientChatter("pilotWarningSAMLaunch", nil, nil, 2, event.initiator:getPoint(), 32)
            end
        end
    end

    -----------------------------------
    -- Called when a SHOT event happens
    --
    -- @param event Event data
    -----------------------------------
    local function onEventShot(event)
        if not event.initiator then return end -- No event initiator
        if not event.weapon then return end -- No weapon shot, abort

        if event.initiator:getCoalition() == TUM.settings.getPlayerCoalition() then
            onEventShotFriendly(event)
        else
            onEventShotHostile(event)
        end
    end

    ----------------------------------------------
    -- Called when a TAKEOFF event happens
    --
    -- @param event Event data
    ----------------------------------------------
    local function onEventTakeOff(event)
        if not event.initiator then return end -- No event initiator
        if event.initiator:getCoalition() ~= TUM.settings.getPlayerCoalition() then return end -- Not a friendly

        local airbaseName = "airbase"
        if event.place then airbaseName = event.place:getName() end

        local callsign = event.initiator:getCallsign() or "aircraft"

        doAmbientChatter("Fly safe, "..callsign.."!", nil, airbaseName) -- TODO: proper message
    end

    -------------------------------------
    -- Called when an event is raised
    -- @param event The DCS World event
    -------------------------------------
    function TUM.ambientRadio.onEvent(event)
        if event.id == world.event.S_EVENT_DEAD then
            onEventDead(event)
        elseif event.id == world.event.S_EVENT_EJECTION then
            onEventEjection(event)
        elseif event.id == world.event.S_EVENT_HIT then
            onEventHit(event)
        elseif event.id == world.event.S_EVENT_KILL then
            onEventKill(event)
        elseif event.id == world.event.S_EVENT_LAND then
            onEventLand(event)
        elseif event.id == world.event.S_EVENT_LANDING_AFTER_EJECTION then
            onEventLandingAfterEjection(event)
        -- elseif event.id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
        --     onEventPlayerEnterUnit(event)
        elseif event.id == world.event.S_EVENT_SHOOTING_START then
            onEventShootingStart(event)
        elseif event.id == world.event.S_EVENT_SHOT then
            onEventShot(event)
        -- elseif event.id == world.event.S_EVENT_TAKEOFF then
        --     onEventTakeOff(event)
        end
    end
end

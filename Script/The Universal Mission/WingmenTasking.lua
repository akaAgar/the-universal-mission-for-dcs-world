-- ====================================================================================
-- TUM.WINGMENTASKING - HANDLES THE WINGMEN'S TASKING
-- ====================================================================================
-- ====================================================================================

TUM.wingmenTasking = {}

do
    TUM.wingmenTasking.DEFAULT_MARKER_TEXT = "flight"

    local mapMarkerMissingWarningAlreadyDisplayed = false -- Was the "map marker missing" warning already displayed during the mission?
    local targetPointMapMarker = nil

    local currentTargetedGroupID = nil

    local function allowWeaponUse(wingmenCtrl, allowUse)
        allowUse = allowUse or false
        wingmenCtrl:setOption(AI.Option.Air.id.REACTION_ON_THREAT, AI.Option.Air.val.REACTION_ON_THREAT.EVADE_FIRE)
        wingmenCtrl:setOption(AI.Option.Air.id.PROHIBIT_AA, not allowUse)
        wingmenCtrl:setOption(AI.Option.Air.id.PROHIBIT_AG, not allowUse)
    end

    local function getOrbitTaskTable(point2)
        return {
            id = "Orbit",
            params = {
                altitude = math.max(DCSEx.converter.feetToMeters(10000), world.getPlayer():getPoint().y),
                pattern = "Circle",
                point = point2,
                width = DCSEx.converter.nmToMeters(1.0)
            }
        }
    end

    local function getRejoinTaskTable(formationDistance)
        formationDistance = formationDistance or 800

        return {
            id = "Follow",
            params = {
                groupId = DCSEx.dcs.getObjectIDAsNumber(world.getPlayer():getGroup()),
                lastWptIndexFlag  = false,
                lastWptIndex = -1,
                pos = { x = -formationDistance, y = 0, z = -formationDistance }
            }
        }
    end

    function TUM.wingmenTasking.commandEngage(groupCategory, targetAttributes, delayRadioAnswer)
        delayRadioAnswer = delayRadioAnswer or false
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No wingmen in multiplayer

        local wingmenCtrl = TUM.wingmen.getController()
        if not wingmenCtrl then return end

        allowWeaponUse(wingmenCtrl, true)

        local detectedContacts = TUM.wingmenContacts.getContacts(groupCategory)
        local validTargets = {}
        for _,c in ipairs(detectedContacts) do
            local g = DCSEx.world.getGroupByID(c.id)
            if g then
                local gUnits = g:getUnits()
                for _,u in ipairs(gUnits) do
                    local isValid = false
                    if not targetAttributes or #targetAttributes == 0 then
                        isValid = true
                    else
                        for _,a in ipairs(targetAttributes) do
                            if u:hasAttribute(a) then
                                isValid = true
                                break
                            end
                        end
                    end

                    if isValid then table.insert(validTargets, u) end
                end
            end
        end

        if #validTargets == 0 then
            TUM.radio.playForAll("pilotWingmanEngageNoTarget", { TUM.wingmen.getFirstWingmanNumber() }, TUM.wingmen.getFirstWingmanCallsign(), true)
            return
        end

        local wingmenPosition = DCSEx.world.getGroupCenter(TUM.wingmen.getGroup())

        validTargets = DCSEx.dcs.getNearestObjects(wingmenPosition, validTargets, 1)
        local target = validTargets[1]
        currentTargetedGroupID = DCSEx.dcs.getGroupIDAsNumber(target:getGroup())
        local taskTable = {
            id = "AttackGroup",
            params = {
                groupId = currentTargetedGroupID,
            }
        }
        wingmenCtrl:setTask(taskTable)
        -- wingmenCtrl:pushTask(getRejoinTaskTable()) -- Makes sure wingmen rejoin with the player after attack

        local targetInfo = nil
        local messageSuffix = nil
        if target:inAir() then
            messageSuffix = "Air"
            targetInfo = Library.objectNames.getGeneric(target)..", "
            targetInfo = targetInfo..DCSEx.dcs.getBRAA(target:getPoint(), wingmenPosition, true)
        else
            messageSuffix = "Surface"
            targetInfo = Library.objectNames.getGeneric(target)..", "
            targetInfo = targetInfo..DCSEx.dcs.getBRAA(target:getPoint(), wingmenPosition, false)
        end

        -- Mark the last targeted point in debug mode
        if TUM.DEBUG_MODE then
            if targetPointMapMarker then
                trigger.action.removeMark(targetPointMapMarker)
                targetPointMapMarker = nil
            end
            targetPointMapMarker = DCSEx.world.getNextMarkerID()
            trigger.action.markToAll(targetPointMapMarker, "Last wingmen attack point", target:getPoint(), true)
        end

        TUM.radio.playForAll("pilotWingmanEngage"..messageSuffix, { TUM.wingmen.getFirstWingmanNumber(), targetInfo }, TUM.wingmen.getFirstWingmanCallsign(), true)
    end

    function TUM.wingmenTasking.commandGoToMapMarker(markerText, delayRadioAnswer)
        markerText = markerText or TUM.wingmenTasking.DEFAULT_MARKER_TEXT
        delayRadioAnswer = delayRadioAnswer or false
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No wingmen in multiplayer

        local mapMarker = DCSEx.world.getMarkerByText(markerText)
        if not mapMarker and not mapMarkerMissingWarningAlreadyDisplayed then
            trigger.action.outText("Map marker missing.\nYou must create a marker on the F10 map and set it text to \""..markerText:upper().."\" (without quotes) to communicate coordinates to your wingmen.", 10)
            mapMarkerMissingWarningAlreadyDisplayed = true
        end

        local wingmenCtrl = TUM.wingmen.getController()
        if not wingmenCtrl then return end

        allowWeaponUse(wingmenCtrl, false)

        if not mapMarker then
            -- TUM.radio.playForAll("pilotWingmanGoToMarkerNoMarker", { TUM.wingmen.getFirstWingmanNumber() }, TUM.wingmen.getFirstWingmanCallsign(), true)
            return
        end

        currentTargetedGroupID = nil
        wingmenCtrl:setTask(getOrbitTaskTable(DCSEx.math.vec3ToVec2(mapMarker.pos)))
        -- TUM.radio.playForAll("pilotWingmanGoToMarker", { TUM.wingmen.getFirstWingmanNumber() }, TUM.wingmen.getFirstWingmanCallsign(), true)
    end

    function TUM.wingmenTasking.commandOrbit(delayRadioAnswer)
        delayRadioAnswer = delayRadioAnswer or false
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No wingmen in multiplayer

        local wingmenCtrl = TUM.wingmen.getController()
        if not wingmenCtrl then return end

        allowWeaponUse(wingmenCtrl, false)

        currentTargetedGroupID = nil
        wingmenCtrl:setTask(getOrbitTaskTable(DCSEx.world.getGroupCenter(TUM.wingmen.getGroup())))
        TUM.radio.playForAll("pilotWingmanOrbit", { TUM.wingmen.getFirstWingmanNumber() }, TUM.wingmen.getFirstWingmanCallsign(), delayRadioAnswer)
    end

    function TUM.wingmenTasking.commandRejoin(formationDistance, delayRadioAnswer, silent)
        delayRadioAnswer = delayRadioAnswer or false
        silent = silent or false
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No wingmen in multiplayer

        local player = world:getPlayer()
        if not player then return end

        local wingmenCtrl = TUM.wingmen.getController()
        if not wingmenCtrl then return end

        allowWeaponUse(wingmenCtrl, false)

        currentTargetedGroupID = nil
        wingmenCtrl:setTask(getRejoinTaskTable(formationDistance))
        if not silent then
            TUM.radio.playForAll("pilotWingmanRejoin", { TUM.wingmen.getFirstWingmanNumber() }, TUM.wingmen.getFirstWingmanCallsign(), delayRadioAnswer)
        end
    end

    function TUM.wingmenTasking.commandReportContacts(groupCategory, noReportIfNoContacts, delayRadioAnswer)
        noReportIfNoContacts = noReportIfNoContacts or false
        delayRadioAnswer = delayRadioAnswer or false
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No wingmen in multiplayer

        local reportString = TUM.wingmenContacts.getContactsAsReportString(groupCategory, true)

        if not reportString then
            if noReportIfNoContacts then return false end
            TUM.radio.playForAll("pilotWingmanReportContactsNoJoy", { TUM.wingmen.getFirstWingmanNumber() }, TUM.wingmen.getFirstWingmanCallsign(), true)
            return true
        else
            TUM.radio.playForAll("pilotWingmanReportContacts", { TUM.wingmen.getFirstWingmanNumber(), reportString }, TUM.wingmen.getFirstWingmanCallsign(), delayRadioAnswer)
            return true
        end
    end

    function TUM.wingmenTasking.commandReportStatus(delayRadioAnswer)
        delayRadioAnswer = delayRadioAnswer or false
        if TUM.settings.getValue(TUM.settings.id.MULTIPLAYER) then return end -- No wingmen in multiplayer

        local wingmenGroup = TUM.wingmen.getGroup()
        if not wingmenGroup then return end

        local groupUnits = wingmenGroup:getUnits()

        local statusMsg = ""
        for i,u in ipairs(groupUnits) do
            statusMsg = statusMsg..u:getCallsign():upper().."\n"
            if u:getLife() >= u:getLife0() then
                statusMsg = statusMsg.."- No damage sustained, fuel green"
            else
                statusMsg = statusMsg.."- Aircraft suffered damage, fuel green"
            end
            statusMsg = statusMsg.."\n- BRAA from you: "..DCSEx.dcs.getBRAA(u:getPoint(), DCSEx.math.vec3ToVec2(world:getPlayer():getPoint()), true)
            statusMsg = statusMsg.."\n- Armament: "
            local ammo = u:getAmmo()
            if #ammo == 0 then
                statusMsg = statusMsg.."None"
            else
                for j,a in ipairs(ammo) do
                    if a.count and a.desc and (a.desc.displayName or a.desc.typeName) then
                        local ammoName = a.desc.displayName or a.desc.typeName
                        if j > 1 then statusMsg = statusMsg..", " end
                        statusMsg = statusMsg..tostring(a.count).."x "..ammoName
                    end
                end
            end

            if i < #groupUnits then statusMsg = statusMsg.."\n\n" end
        end

        TUM.radio.playForAll("pilotWingmanReportStatus", { TUM.wingmen.getFirstWingmanNumber(), statusMsg },  TUM.wingmen.getFirstWingmanCallsign(), delayRadioAnswer)
    end

    ----------------------------------------------------------
    -- Called on every mission update tick (every 10-20 seconds)
    ----------------------------------------------------------    
    function TUM.wingmenTasking.onClockTick()
        -- Targeted group is dead? Mark group as nil and rejoin leader
        if currentTargetedGroupID then
            local tgtGroup = DCSEx.world.getGroupByID(currentTargetedGroupID)
            if not tgtGroup or tgtGroup:getSize() == 0 then
                TUM.wingmenTasking.commandRejoin(nil, false)
                tgtGroup = nil
            end
        end
    end
end

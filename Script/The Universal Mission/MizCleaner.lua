-- ====================================================================================
-- TUM.MIZCLEANER - REMOVED UNWANTED UNIT GROUPS FROM THE MIZ FILE
-- ====================================================================================
-- (local) removeAIAircraftOnLandEvent(event)
-- (local) removeAIWingmen()
-- TUM.mizCleaner.onStartUp()
-- TUM.mizCleaner.onEvent(event)
-- ====================================================================================

TUM.mizCleaner = {}

do
    -------------------------------------
    -- If event is an AI aircraft land event, remove it so it "frees room" (e.g. don't occupy an "air force unit" slot) for new aircraft
    -- @param event A DCS World event, possibly a S_EVENT_LAND event
    -------------------------------------
    local function removeAIAircraftOnLandEvent(event)
        if not event.initiator then return end
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Not an unit
        if event.initiator:getPlayerName() then return end -- Don't remove player aircraft, that would cause horrendous bugs

        event.initiator:destroy()
    end

    -------------------------------------
    -- Removes all AI wingmen units
    -------------------------------------
    local function removeAIWingmen()
        local groups = DCSEx.envMission.getGroups(TUM.settings.getPlayerCoalition())

        local aiWingMenToRemove = {}
        for _,g in ipairs(groups) do
            if g.units then
                local isPlayerGroup = false

                for _,u in ipairs(g.units) do
                    if u.skill == "Player" or u.skill == "Client" then
                        isPlayerGroup = true
                    end
                end

                if isPlayerGroup then
                    for _,u in ipairs(g.units) do
                        if u.skill ~= "Player" and u.skill ~= "Client" then
                            table.insert(aiWingMenToRemove, u.unitId)
                        end
                    end
                end
            end
        end

        if #aiWingMenToRemove > 0 then
            for _,id in ipairs(aiWingMenToRemove) do
                local u = DCSEx.world.getUnitByID(id)
                if u then u:destroy() end
            end
            TUM.log("Removed "..tostring(#aiWingMenToRemove).." AI wingmen from the mission.\nPlease do not add AI wingmen to the mission, The Universal Mission relies on its own wingman system.", TUM.logger.logLevel.WARNING)
        end
    end

    -------------------------------------
    -- Called on mission start up
    -- @return True if started up properly, false if an error happened
    -------------------------------------
    function TUM.mizCleaner.onStartUp()
        removeAIWingmen()
        return true
    end

    -------------------------------------
    -- Called when an event is raised
    -- @param event The DCS World event
    -------------------------------------
    function TUM.mizCleaner.onEvent(event)
        if event.id == world.event.S_EVENT_LAND and event.place then
            removeAIAircraftOnLandEvent(event)
        end
    end
end

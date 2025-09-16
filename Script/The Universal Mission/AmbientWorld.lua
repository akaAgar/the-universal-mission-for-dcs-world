-- ====================================================================================
--  TUM.AMBIENTWORLD - HANDLES LITTLE DETAILS DESIGNED TO MAKE THE GAME WORLD MORE ALIVE
-- ====================================================================================
-- ====================================================================================

TUM.ambientWorld = {}

do
    local groupIDs = {}

    ---------------
    -- CONSTANTS --
    ---------------
    local ESCAPING_CREW_ONE_TIME_OUT_OF = 6 -- one time of out this number, crew will flee destroyed vehicles

    local function doSpawnEscapingCrew(point3)
        local options = {
            disableWeapons = true,
            hidden = true,
            invisible = true,
            moveBy = 250,
            spreadDistance = math.random(2, 3),
        }

        local unitTypes = Library.factions.getUnits(TUM.settings.getEnemyFaction(), DCSEx.enums.unitFamily.GROUND_INFANTRY, math.random(1, 3))
        if not unitTypes or #unitTypes == 0 then return end

        local groupInfo = DCSEx.unitGroupMaker.create(TUM.settings.getEnemyCoalition(), Group.Category.GROUND, DCSEx.math.vec3ToVec2(point3), unitTypes, options)
        if groupInfo then
            table.insert(groupIDs, groupInfo.groupID)
        end
    end


    -- Called when an unit is destroyed
    local function onEventDead(event)
        if not event.initiator then return end -- Nothing was hit

        -- TODO: spawn from target scenery buildings and static structures

        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Target wasn't an unit
        if event.initiator:getDesc().category ~= Unit.Category.GROUND_UNIT then return end -- Wasn't a ground unit
        if not event.initiator:hasAttribute("Vehicles") then return end -- Wasn't a vehicle
        if event.initiator:getCoalition() ~= TUM.settings.getEnemyCoalition() then return end -- Only spawn escaping crew from enemy vehicles

        if math.random(1, ESCAPING_CREW_ONE_TIME_OUT_OF) ~= 1 then return end -- Do not spawn every time

        TUM.log("Spawning crew escaping from destroyed unit "..event.initiator:getName())
        timer.scheduleFunction(
            doSpawnEscapingCrew,
            event.initiator:getPoint(),
            timer.getTime() + math.random(4, 7)
        )
    end

    -- Called when an unit takes damage
    local function onEventHit(event)
        if not event.initiator then return end -- Nothing was hit
        if Object.getCategory(event.initiator) ~= Object.Category.UNIT then return end -- Target wasn't an unit
        if event.initiator:getCoalition() ~= TUM.settings.getEnemyCoalition() then return end -- Unit is not an enemy
        if event.initiator:getDesc().category ~= Unit.Category.AIRPLANE and event.initiator:getDesc().category ~= Unit.Category.HELICOPTER then return end -- Wasn't an aircraft
        if event.initiator:inAir() then return end -- Unit is currently in air

        trigger.action.explosion(event.initiator:getPoint(), 100) -- Detonate the parked aircraft, to make it easier to kill
    end

    function TUM.ambientWorld.removeAll()
        for _,id in ipairs(groupIDs) do
            DCSEx.world.destroyGroupByID(id)
        end

        groupIDs = {}
    end

    -------------------------------------
    -- Called when an event is raised
    -- @param event The DCS World event
    -------------------------------------
    function TUM.ambientWorld.onEvent(event)
        if not event then return end -- No event

        if event.id == world.event.S_EVENT_DEAD then
            onEventDead(event)
        elseif event.id == world.event.S_EVENT_HIT then
            onEventHit(event)
        end
    end
end

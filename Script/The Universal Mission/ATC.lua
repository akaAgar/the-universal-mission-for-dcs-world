TUM.atc = {}

do
    local function getFlyTime(playerUnit, point3)
        local point2 = DCSEx.math.vec3ToVec2(point3)

        local velocity = playerUnit:getVelocity()
        local speed = math.max(1, math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y + velocity.z * velocity.z))
        local distance = DCSEx.math.getDistance2D(point2, DCSEx.math.vec3ToVec2(playerUnit:getPoint()))
        local timeInMinutes = math.max(1, math.floor(distance / (speed * 60)))
        local eta = DCSEx.string.getTimeString(timer.getAbsTime() + timeInMinutes * 60)
        if timeInMinutes > 600 then
            return "More than ten hours of flight time at current airspeed\n"
        elseif timeInMinutes > 120 then
            return tostring(math.floor(timeInMinutes / 60)).." hours of flight time at current airspeed, ETA "..eta.."\n"
        elseif timeInMinutes < 2 then
            return "Less than 2 minutes of flight time at current airspeed, ETA "..eta.."\n"
        else
            return tostring(timeInMinutes).." minutes of flight time at current airspeed, ETA "..eta.."\n"
        end
    end

    local function getTemperatureCelsiusAndFarenheit(temperature, inKelvins)
        inKelvins = inKelvins or false
        if inKelvins then temperature = temperature - 273.15 end

        return tostring(math.floor(temperature)).."°C/"..tostring(math.floor(DCSEx.converter.celsiusToFahrenheit(temperature))).."°F"
    end

    function TUM.atc.requestNavAssistanceToObjective(index, delayRadioAnswer)
        local obj = TUM.objectives.getObjective(index)
        if not obj then return end

        local msgIDSuffix = ""
        if obj.preciseCoordinates then msgIDSuffix = "Precise" end

        local players = coalition.getPlayers(TUM.settings.getPlayerCoalition())
        for _,p in ipairs(players) do
            -- Give BRA to objective
            local navInfo = "- Fly "..DCSEx.dcs.getBRAA(obj.waypoint3, p:getPoint(), false).."\n"
            navInfo = navInfo.."- "..getFlyTime(p, obj.waypoint3) -- Give flight time and ETA

            -- Give objective coordinates
            if obj.preciseCoordinates then
                navInfo = navInfo.."\nExact coordinates for objective are:\n"
            else
                navInfo = navInfo.."\nNo exact coordinates for objective. Approximate coordinates are:\n"
            end
            navInfo = navInfo..DCSEx.world.getCoordinatesAsString(obj.waypoint3, false)

            TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(p), "commandObjectiveCoordinates"..msgIDSuffix, { obj.name, navInfo }, "Command", delayRadioAnswer, nil, nil, 2.5)
        end
    end

    function TUM.atc.requestNavAssistanceToAirbase(delayRadioAnswer)
        local players = coalition.getPlayers(TUM.settings.getPlayerCoalition())
        for _,p in ipairs(players) do
            local airbaseInfo = nil -- Mark as nil, in case no valid airbase is found

            local validAirbaseTypes = { Airbase.Category.AIRDROME }
            if p:hasAttribute("Helicopters") then table.insert(validAirbaseTypes, Airbase.Category.HELIPAD) end
            local pDesc = p:getDesc()
            if pDesc.LandRWCategories and #pDesc.LandRWCategories > 0 then
                -- TODO: check player unit description to filter compatible carrier types (Harrier/helos can land anywhere, naval fighters can land on carriers, etc)
                table.insert(validAirbaseTypes, Airbase.Category.SHIP)
            end

            local allAirbases = coalition.getAirbases(TUM.settings.getPlayerCoalition())
            if allAirbases and #allAirbases > 0 then
                allAirbases = DCSEx.dcs.getNearestObjects(DCSEx.math.vec3ToVec2(p:getPoint()), allAirbases)

                for i=1,#allAirbases do
                    local abDesc = allAirbases[i]:getDesc()

                    if DCSEx.table.contains(validAirbaseTypes, abDesc.category) then
                        local abPoint = allAirbases[i]:getPoint()

                        if abDesc.category == Airbase.Category.AIRDROME then
                            airbaseInfo = abDesc.displayName:upper().." AIRBASE:\n"
                        else -- Helipad or ship
                            airbaseInfo = abDesc.displayName:upper()..":\n"
                        end
                        airbaseInfo = airbaseInfo.."- Fly "..DCSEx.dcs.getBRAA(abPoint, p:getPoint(), false).."\n"
                        airbaseInfo = airbaseInfo.."- "..getFlyTime(p, abPoint).."\n"
                        airbaseInfo = airbaseInfo..DCSEx.world.getCoordinatesAsString(abPoint, false)

                        local runways = allAirbases[i]:getRunways()
                        if #runways > 0 then
                            airbaseInfo = airbaseInfo.."\n\nRunways: "
                            for j=1,#runways do
                                -- Compute the runway course (in degrees, divided by 10)
                                local courseDeg = math.floor(DCSEx.converter.radiansToDegrees(runways[j].course * -1))
                                if courseDeg < 0 then courseDeg = courseDeg + 360 end
                                if courseDeg >= 360 then courseDeg = courseDeg - 360 end
                                courseDeg = math.floor(courseDeg / 10)

                                -- Compute the opposite runway coursecourseDegNeg
                                local courseDegNeg = courseDeg + 18
                                if courseDegNeg >= 36 then courseDegNeg = courseDegNeg - 36 end

                                -- Make sure the lowest runway heading is displayed first
                                if courseDeg > courseDegNeg then
                                    local tmp = courseDegNeg
                                    courseDegNeg = courseDeg
                                    courseDeg = tmp
                                end

                                airbaseInfo = airbaseInfo..tostring(courseDeg).."/"..tostring(courseDegNeg).." ("..tostring(math.floor(runways[j].length)).." m)"
                                if j < #runways then airbaseInfo = airbaseInfo..", " end
                            end
                        end
                        -- TODO: radio tower frequency?

                        break -- Stop after finding one
                    end
                end
            end

            if airbaseInfo then
                TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(p), "atcRequireNearestAirbase", { airbaseInfo }, "Control", delayRadioAnswer, nil, false, 2.5)
            else
                TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(p), "atcRequireNearestAirbaseNone", nil, "Control", delayRadioAnswer)
            end
        end
    end

    function TUM.atc.requestWeatherUpdate(delayRadioAnswer)
        local commonWeatherInfo = "- It is currenly "..DCSEx.string.getTimeString()
        if Library.environment.isItNightTime() then
            commonWeatherInfo = commonWeatherInfo.." (night, sunrise at "..DCSEx.string.getTimeString(Library.environment.getDayTime(nil, false))..")\n"
        else
            commonWeatherInfo = commonWeatherInfo.." (day, sunset at "..DCSEx.string.getTimeString(Library.environment.getDayTime(nil, true))..")\n"
        end

        commonWeatherInfo = commonWeatherInfo.."- Cloud cover: "..TUM.weather.getWeatherName(nil, true).."\n"
        commonWeatherInfo = commonWeatherInfo.."- Wind: "..TUM.weather.getWindName()..", with avg. speed of "..tostring(math.floor(Library.environment.getWindAverage())).."m/s\n"
        commonWeatherInfo = commonWeatherInfo.."- Average ground-level temperature is "..getTemperatureCelsiusAndFarenheit(env.mission.weather.season.temperature).."\n"

        local players = coalition.getPlayers(TUM.settings.getPlayerCoalition())
        for _,p in ipairs(players) do
            local lTemperature, _ = atmosphere.getTemperatureAndPressure(p:getPoint())

            local localWeatherInfo = ""
            localWeatherInfo = localWeatherInfo.."- Wind speed at your location is "..tostring(math.floor(DCSEx.math.getLength3D(atmosphere.getWind(p:getPoint())))).."m/s\n"
            localWeatherInfo = localWeatherInfo.."- Temperature at your location is "..getTemperatureCelsiusAndFarenheit(lTemperature, true).."\n"

            TUM.radio.playForUnit(DCSEx.dcs.getObjectIDAsNumber(p), "atcWeatherUpdate", { commonWeatherInfo..localWeatherInfo }, "Control", delayRadioAnswer)
        end
    end
end

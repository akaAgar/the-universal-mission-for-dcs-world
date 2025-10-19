-- ====================================================================================
-- TUM.WEATHER - HANDLES THE MISSION'S WEATHER SETTINGS
-- ====================================================================================
-- ====================================================================================

TUM.weather = {}

do
    local cloudPresets = {
		-- "Light Scattered 1",
		Preset1 = {
			readableName = "Few scattered clouds (METAR: FEW/SCT 7/8)",
			readableNameShort = "Light scattered",
            xpBonus = 0,
		},

		-- "Light Scattered 2",
		Preset2 = {
			readableName = "Two layers few and scattered (METAR: FEW/SCT 8/10 SCT 23/24)",
			readableNameShort = "Light scattered",
            xpBonus = 0,
		},

		-- "High Scattered 1",
		Preset3 = {
			readableName = "Two layers scattered (METAR: SCT 8/9 FEW 21)",
			readableNameShort = "High Scattered",
            xpBonus = 0,
		},

		-- "High Scattered 2",
		Preset4 = {
			readableName = "Two layers scattered (METAR: SCT 8/10 FEW/SCT 24/26)",
			readableNameShort = "High Scattered",
            xpBonus = 0,
		},

		-- "Scattered 1",
		Preset5 = {
			readableName = "Three layers high altitude scattered (METAR: SCT 14/17 FEW 27/29 BKN 40)",
			readableNameShort = "Scattered",
            xpBonus = 0,
		},

		-- "Scattered 2",
		Preset6 = {
			readableName = "One layer scattered/broken (METAR: SCT/BKN 8/10 FEW 40)",
			readableNameShort = "Scattered",
            xpBonus = 0,
		},

		-- "Scattered 3",
		Preset7 = {
			readableName = "Two layers scattered/broken (METAR: BKN 7.5/12 SCT/BKN 21/23 SCT 40)",
			readableNameShort = "Scattered",
            xpBonus = 0,
		},

		-- "High Scattered 3",
		Preset8 = {
			readableName = "Two layers scattered/broken high altitude (METAR: SCT/BKN 18/20 FEW 36/38 FEW 40)",
			readableNameShort = "High Scattered",
            xpBonus = 0,
		},

		-- "Scattered 4",
		Preset9 = {
			readableName = "Two layers broken/scattered (METAR: BKN 7.5/10 SCT 20/22 FEW41)",
			readableNameShort = "Scattered",
            xpBonus = 0,
		},

		-- "Scattered 5",
		Preset10 = {
			readableName = "Two layers scattered large thick clouds (METAR: SCT/BKN 18/20 FEW36/38 FEW 40)",
			readableNameShort = "Scattered",
            xpBonus = 0,
		},

		-- "Scattered 6",
		Preset11 = {
			readableName = "Two layers scattered large clouds high ceiling (METAR: BKN 18/20 BKN 32/33 FEW 41)",
			readableNameShort = "Scattered",
            xpBonus = 0,
		},

		-- "Scattered 7",
		Preset12 = {
			readableName = "Two layers scattered large clouds high ceiling (METAR: BKN 12/14 SCT 22/23 FEW 41)",
			readableNameShort = "Scattered",
            xpBonus = 0,
		},

		-- "Broken 1",
		Preset13 = {
			readableName = "Two layers broken clouds (METAR: BKN 12/14 BKN 26/28 FEW 41)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Broken 2",
		Preset14 = {
			readableName = "Broken thick low layer with few high layers\nMETAR: BKN LYR 7/16 FEW 41)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Broken 3",
		Preset15 = {
			readableName = "Two layers broken large clouds (METAR: SCT/BKN 14/18 BKN 24/27 FEW 40)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Broken 4",
		Preset16 = {
			readableName = "Two layers broken large clouds (METAR: BKN 14/18 BKN 28/30 FEW 40)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Broken 5",
		Preset17 = {
			readableName = "Three layers broken/overcast (METAR: BKN/OVC LYR 7/13 20/22 32/34)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Broken 6",
		Preset18 = {
			readableName = "Three layers broken/overcast (METAR: BKN/OVC LYR 13/15 25/29 38/41)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Broken 7",
		Preset19 = {
			readableName = "Three layers overcast at low level (METAR: OVC 9/16 BKN/OVC LYR 23/24 31/33)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Broken 8",
		Preset20 = {
			readableName = "Three layers overcast low level (METAR: BKN/OVC 13/18 BKN 28/30 SCT FEW 38)",
			readableNameShort = "Broken",
            xpBonus = 0.05,
		},

		-- "Overcast 1",
		Preset21 = {
			readableName = "Overcast low level (METAR: BKN/OVC LYR 7/8 17/19)",
			readableNameShort = "Overcast",
            xpBonus = 0.10,
		},

		-- "Overcast 2",
		Preset22 = {
			readableName = "Overcast low level (METAR: BKN LYR 7/10 17/20)",
			readableNameShort = "Overcast",
            xpBonus = 0.10,
		},

		-- "Overcast 3",
		Preset23 = {
			readableName = "Three layers broken low level scattered high (METAR: BKN LYR 11/14 18/25 SCT 32/35)",
			readableNameShort = "Overcast",
            xpBonus = 0.10,
		},

		-- "Overcast 4",
		Preset24 = {
			readableName = "Three layers overcast (METAR: BKN/OVC 3/7 17/22 BKN 34)",
			readableNameShort = "Overcast",
            xpBonus = 0.10,
		},

		-- "Overcast 5",
		Preset25 = {
			readableName = "Three layers overcast (METAR: OVC LYR 12/14 22/25 40/42)",
			readableNameShort = "Overcast",
            xpBonus = 0.10,
		},

		-- "Overcast 6",
		Preset26 = {
			readableName = "Three layers overcast (METAR: OVC 9/15 BKN 23/25 SCT 32)",
			readableNameShort = "Overcast",
            xpBonus = 0.10,
		},

		-- "Overcast 7",
		Preset27 = {
			readableName = "Three layer overcast (METAR: OVC 8/15 SCT/BKN 25/26 34/36)",
			readableNameShort = "Overcast",
            xpBonus = 0.10,
		},

        -- "Overcast And Rain 1",
		RainyPreset1 = {
			readableName = "Overcast with rain (METAR: VIS 3-5KM RA OVC 3/15 28/30 FEW 40)",
			readableNameShort = "Overcast and rain",
            xpBonus = 0.25,
		},

		-- "Overcast And Rain 2",
		RainyPreset2 = {
			readableName = "Overcast with rain (METAR: VIS 1-5KM RA BKN/OVC 3/11 SCT 18/29 FEW 40)",
			readableNameShort = "Overcast and rain",
            xpBonus = 0.25,
		},

		-- "Overcast And Rain 3",
		RainyPreset3 = {
			readableName = "Overcast with rain (METAR: VIS 3-5KM RA OVC LYR 6/18 19/21 SCT 34)",
			readableNameShort = "Overcast and rain",
            xpBonus = 0.25,
		},

		-- "Light Rain 1",
		RainyPreset4 = {
			readableName = "Two layers scattered large thick clouds (METAR: SCT/BKN 18/20 FEW36/38 FEW 40)",
			readableNameShort = "Light rain",
            xpBonus = 0.15,
		},

		-- "Light Rain 2",
		RainyPreset5 = {
			readableName = "Three layers broken/overcast (METAR: BKN/OVC LYR 7/13 20/22 32/34)",
			readableNameShort = "Light rain",
            xpBonus = 0.15,
		},

		-- "Light Rain 3",
		RainyPreset6 = {
			readableName = "Three layers overcast at low level (METAR: OVC 9/16 BKN/OVC LYR 23/24 31/33)",
			readableNameShort = "Light rain",
            xpBonus = 0.15,
		},

		-- "Light Rain 4",
		NEWRAINPRESET4 = {
			readableName = "Two layers overcast at low level (METAR: OVC 9/16 BKN/OVC LYR 23/24 31/33)",
			readableNameShort = "Light rain",
            xpBonus = 0.15,
		},
    }

    local function getWindBeaufortScale(speedInMS)
        local speedInKMH = DCSEx.converter.mpsToKmph(speedInMS or Library.environment.getWindAverage())

        if speedInKMH < 1 then return 0
        elseif speedInKMH <= 5 then return 1
        elseif speedInKMH <= 11 then return 2
        elseif speedInKMH <= 19 then return 3
        elseif speedInKMH <= 28 then return 4
        elseif speedInKMH <= 38 then return 5
        elseif speedInKMH <= 49 then return 6
        elseif speedInKMH <= 61 then return 7
        elseif speedInKMH <= 74 then return 8
        elseif speedInKMH <= 88 then return 9
        elseif speedInKMH <= 102 then return 10
        elseif speedInKMH <= 117 then return 11
        else return 12
        end
    end

    function TUM.weather.getWeatherName(presetID, longForm)
        presetID = presetID or env.mission.weather.clouds.preset
        longForm = longForm or false

        if cloudPresets[presetID] == nil then return "Unknown" end
        if longForm then return cloudPresets[presetID].readableName end
        return cloudPresets[presetID].readableNameShort
    end

    function TUM.weather.getWeatherXPModifier(presetID)
        presetID = presetID or env.mission.weather.clouds.preset

        if cloudPresets[presetID] == nil then return 0 end

        return cloudPresets[presetID].xpBonus
    end

    function TUM.weather.getWindName(speedInMS)
        local windBeaufort = getWindBeaufortScale(speedInMS)

        if windBeaufort == 0 then return "calm"
        elseif windBeaufort == 1 then return "light air"
        elseif windBeaufort == 2 then return "light breeze"
        elseif windBeaufort == 3 then return "gentle breeze"
        elseif windBeaufort == 4 then return "moderate breeze"
        elseif windBeaufort == 5 then return "fresh breeze"
        elseif windBeaufort == 6 then return "strong breeze"
        elseif windBeaufort == 7 then return "moderate gale"
        elseif windBeaufort == 8 then return "fresh gale"
        elseif windBeaufort == 9 then return "strong gale"
        elseif windBeaufort == 10 then return "storm"
        elseif windBeaufort == 11 then return "violent storm"
        elseif windBeaufort == 12 then return "hurricane"
        end
    end

    function TUM.weather.getWindXPModifier(speedInMS)
        local windBeaufort = getWindBeaufortScale(speedInMS)

        if windBeaufort == 0 then return 0.00
        elseif windBeaufort == 1 then return 0.02
        elseif windBeaufort == 2 then return 0.04
        elseif windBeaufort == 3 then return 0.08
        elseif windBeaufort == 4 then return 0.10
        elseif windBeaufort == 5 then return 0.12
        elseif windBeaufort == 6 then return 0.15
        elseif windBeaufort == 7 then return 0.18
        elseif windBeaufort == 8 then return 0.21
        elseif windBeaufort == 9 then return 0.24
        elseif windBeaufort == 10 then return 0.27
        elseif windBeaufort == 11 then return 0.30
        elseif windBeaufort == 12 then return 0.33
        end
    end
end

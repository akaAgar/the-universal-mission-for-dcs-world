mission =
{
	["groundControl"] =
	{
		["passwords"] =
		{
			["artillery_commander"] = {},
			["instructor"] = {},
			["observer"] = {},
			["forward_observer"] = {},
		},
		["roles"] =
		{
			["artillery_commander"] =
			{
				["neutrals"] = 0,
				["blue"] = 0,
				["red"] = 0,
			},
			["instructor"] =
			{
				["neutrals"] = 0,
				["blue"] = 0,
				["red"] = 0,
			},
			["observer"] =
			{
				["neutrals"] = 0,
				["blue"] = 0,
				["red"] = 0,
			},
			["forward_observer"] =
			{
				["neutrals"] = 0,
				["blue"] = 0,
				["red"] = 0,
			},
		},
		["isPilotControlVehicles"] = false,
	},
	["requiredModules"] = {},
	["date"] =
	{
		["Year"] = __DATE_YEAR__,
		["Day"] = __DATE_DAY__,
		["Month"] = __DATE_MONTH__,
	},
	["trig"] =
	{
		["actions"] =
		{
			[1] = "a_do_script_file(\"Script.lua\"); mission.trig.events[\"mission start\"][1]=nil;",
		},
		["events"] =
		{
			["mission start"] =
			{
				[1] = "if mission.trig.conditions[1]() then mission.trig.actions[1]() end",
			},
		},
		["custom"] = {},
		["func"] = {},
		["flag"] =
		{
			[1] = true,
		},
		["conditions"] =
		{
			[1] = "return(true)",
		},
		["customStartup"] = {},
		["funcStartup"] = {},
	},
	["maxDictId"] = 5,
	["result"] =
	{
		["offline"] =
		{
			["conditions"] = {},
			["actions"] = {},
			["func"] = {},
		},
		["total"] = 0,
		["blue"] =
		{
			["conditions"] = {},
			["actions"] = {},
			["func"] = {},
		},
		["red"] =
		{
			["conditions"] = {},
			["actions"] = {},
			["func"] = {},
		},
	},
	["pictureFileNameN"] = {},
	["descriptionNeutralsTask"] = "",
	["pictureFileNameServer"] = {},
	["weather"] =
	{
		["wind"] =
		{
			["at8000"] =
			{
				["speed"] = 0,
				["dir"] = 0,
			},
			["atGround"] =
			{
				["speed"] = 0,
				["dir"] = 0,
			},
			["at2000"] =
			{
				["speed"] = 0,
				["dir"] = 0,
			},
		},
		["enable_fog"] = false,
		["season"] =
		{
			["temperature"] = __WEATHER_TEMPERATURE__,
		},
		["qnh"] = 760,
		["cyclones"] = {},
		["dust_density"] = 0,
		["enable_dust"] = false,
		["clouds"] =
		{
			["thickness"] = 200,
			["density"] = 0,
			["preset"] = "Preset2",
			["base"] = 2500,
			["iprecptns"] = 0,
		},
		["atmosphere_type"] = 0,
		["groundTurbulence"] = 0,
		["halo"] =
		{
			["preset"] = "auto",
		},
		["type_weather"] = 0,
		["modifiedTime"] = false,
		["name"] = "Winter, clean sky",
		["fog"] =
		{
			["visibility"] = 0,
			["thickness"] = 0,
		},
		["visibility"] =
		{
			["distance"] = 80000,
		},
	},
	["theatre"] = "__THEATER__",
	["triggers"] =
	{
		["zones"] =
		{
			__ZONES__
		},
	},
	["map"] =
	{
		["centerY"] = __MAP_CENTER_Y__,
		["zoom"] = __MAP_ZOOM__,
		["centerX"] = __MAP_CENTER_X__,
	},
	["coalitions"] =
	{
		["blue"] =
		{
			[1] = 80,
		},
		["neutrals"] =
		{
			[1] = 18,
			[2] = 91,
			[3] = 70,
			[4] = 83,
			[5] = 21,
			[6] = 23,
			[7] = 65,
			[8] = 24,
			[9] = 11,
			[10] = 86,
			[11] = 64,
			[12] = 25,
			[13] = 8,
			[14] = 63,
			[15] = 27,
			[16] = 28,
			[17] = 76,
			[18] = 84,
			[19] = 26,
			[20] = 13,
			[21] = 90,
			[22] = 29,
			[23] = 62,
			[24] = 30,
			[25] = 5,
			[26] = 78,
			[27] = 16,
			[28] = 6,
			[29] = 87,
			[30] = 31,
			[31] = 61,
			[32] = 32,
			[33] = 33,
			[34] = 60,
			[35] = 17,
			[36] = 34,
			[37] = 35,
			[38] = 15,
			[39] = 69,
			[40] = 20,
			[41] = 36,
			[42] = 59,
			[43] = 37,
			[44] = 71,
			[45] = 79,
			[46] = 58,
			[47] = 57,
			[48] = 56,
			[49] = 55,
			[50] = 92,
			[51] = 88,
			[52] = 38,
			[53] = 12,
			[54] = 73,
			[55] = 39,
			[56] = 89,
			[57] = 54,
			[58] = 40,
			[59] = 77,
			[60] = 72,
			[61] = 41,
			[62] = 0,
			[63] = 42,
			[64] = 43,
			[65] = 44,
			[66] = 85,
			[67] = 75,
			[68] = 45,
			[69] = 19,
			[70] = 9,
			[71] = 53,
			[72] = 46,
			[73] = 22,
			[74] = 47,
			[75] = 52,
			[76] = 10,
			[77] = 66,
			[78] = 51,
			[79] = 3,
			[80] = 4,
			[81] = 1,
			[82] = 74,
			[83] = 82,
			[84] = 2,
			[85] = 7,
			[86] = 68,
			[87] = 50,
			[88] = 49,
			[89] = 48,
			[90] = 67,
		},
		["red"] =
		{
			[1] = 81,
		},
	},
	["descriptionText"] = "__MISSION_DESCRIPTION__",
	["pictureFileNameR"] = {},
	["descriptionBlueTask"] = "__MISSION_BRIEFING__",
	["goals"] = {},
	["descriptionRedTask"] = "__MISSION_BRIEFING__",
	["pictureFileNameB"] = {},
	["coalition"] =
	{
		["blue"] =
		{
			["bullseye"] =
			{
				["y"] = __BULLSEYE_BLUE_Y__,
				["x"] = __BULLSEYE_BLUE_X__,
			},
			["nav_points"] = {},
			["name"] = "blue",
			["country"] =
			{
				[1] =
				{
					["id"] = 80,
					["name"] = "CJTF Blue",
					["plane"] =
					{
						["group"] =
						{
__PLAYER_GROUP__
						},
					},
				},
			},
		},
		["neutrals"] =
		{
			["bullseye"] =
			{
				["y"] = __MAP_CENTER_Y__,
				["x"] = __MAP_CENTER_X__,
			},
			["nav_points"] = {},
			["name"] = "neutrals",
			["country"] = {},
		},
		["red"] =
		{
			["bullseye"] =
			{
				["y"] = __BULLSEYE_RED_Y__,
				["x"] = __BULLSEYE_RED_X__,
			},
			["nav_points"] = {},
			["name"] = "red",
			["country"] = {},
		},
	},
	["sortie"] = "DictKey_sortie_5",
	["version"] = 23,
	["trigrules"] =
	{
		[1] =
		{
			["rules"] = {},
			["comment"] = "RunMissionScript",
			["eventlist"] = "mission start",
			["actions"] =
			{
				[1] =
				{
					["predicate"] = "a_do_script_file",
					["file"] = "Script.lua",
				},
			},
			["predicate"] = "triggerOnce",
		},
	},
	["currentKey"] = 38,
	["failures"] = {},
	["forcedOptions"] =
	{
		["userMarks"] = true,
		["RBDAI"] = false,
		["unrestrictedSATNAV"] = true,
	},
	["start_time"] = 28800,
}

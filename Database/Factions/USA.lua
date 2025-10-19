Library.factions.defaults[coalition.side.BLUE] = "USA"

do
    Library.factions.tables["USA"] = {}
    Library.factions.tables["USA"].theaters = {}
    Library.factions.tables["USA"].timePeriods = {}

    Library.factions.tables["USA"].units = {}

    Library.factions.tables["USA"].units[DCSEx.enums.timePeriod.WORLD_WAR_2] = {}
    Library.factions.tables["USA"].units[DCSEx.enums.timePeriod.KOREA_WAR] = {}
    Library.factions.tables["USA"].units[DCSEx.enums.timePeriod.VIETNAM_WAR] = {}

    Library.factions.tables["USA"].units[DCSEx.enums.timePeriod.COLD_WAR] = {
        [DCSEx.enums.unitFamily.AIRDEFENSE_AAA_MOBILE] = { "Gepard", "Vulcan" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_AAA_STATIC] = { "Gepard", "Vulcan" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_MANPADS] = { "Soldier stinger" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_LONG] = { "*Patriot" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_MEDIUM] = { "*HAWK", "*NASAMS" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_SHORT] = { "rapier_fsa", "Roland ADS" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_SHORT_IR] = { "M6 Linebacker", "M48 Chaparral", "M1097 Avenger" },

        [DCSEx.enums.unitFamily.GROUND_APC] = { "AAV7", "Cobra", "LAV-25", "M-2 Bradley", "M-113", "M1045 HMMWV TOW", "M1126 Stryker ICV", "M1128 Stryker MGS", "Marder", "MCV-80", "MLRS FDDM", "TPZ", "CHAP_M1130", "CHAP_MATV" },
        [DCSEx.enums.unitFamily.GROUND_ARTILLERY] = { "M-109", "MLRS", "CHAP_M142_ATACMS_M48", "CHAP_M142_GMLRS_M31" },
        [DCSEx.enums.unitFamily.GROUND_INFANTRY] = { "Soldier M4 GRG", "Soldier M4", "Soldier M249", "Soldier RPG" },
        [DCSEx.enums.unitFamily.GROUND_MBT] = { "Challenger2", "Leclerc", "Leopard-2", "Leopard1A3", "M-1 Abrams", "Merkava_Mk4" },
        [DCSEx.enums.unitFamily.GROUND_SS_MISSILE] = { "Scud_B" },
        [DCSEx.enums.unitFamily.GROUND_UNARMED] = { "Land_Rover_101_FC", "Land_Rover_109_S3", "M 818", "CHAP_M1083" },

        [DCSEx.enums.unitFamily.HELICOPTER_ATTACK] = { "AH-1W", "AH-64D", "OH-58D", "SA342L", "SA342M", "SA342Minigun", "SA342Mistral" },
        [DCSEx.enums.unitFamily.HELICOPTER_TRANSPORT] = { "CH-47D", "CH-53E", "SH-60B", "UH-60A" },

        [DCSEx.enums.unitFamily.PLANE_ATTACK] = { "A-10C_2" },
        [DCSEx.enums.unitFamily.PLANE_AWACS] = { "E-2C", "E-3A" },
        [DCSEx.enums.unitFamily.PLANE_BOMBER] = { "B-1B Lancer", "B-52H" },
        [DCSEx.enums.unitFamily.PLANE_FIGHTER] = { "F-16C_50", "FA-18C_hornet" },
        [DCSEx.enums.unitFamily.PLANE_TANKER] = { "KC-135", "KC135MPRS" },
        [DCSEx.enums.unitFamily.PLANE_TRANSPORT] = { "C-17A", "C-130" },
        [DCSEx.enums.unitFamily.PLANE_UAV] = { "RQ-1A Predator" },

        [DCSEx.enums.unitFamily.SHIP_CARGO] = { "Dry-cargo ship-1", "Dry-cargo ship-2", "ELNYA", "Ship_Tilde_Supply" },
        [DCSEx.enums.unitFamily.SHIP_CARRIER] = { "CVN_71", "CVN_72", "CVN_73", "CVN_75", "hms_invincible", "LHA_Tarawa", "Stennis" },
        [DCSEx.enums.unitFamily.SHIP_CRUISER] = { "TICONDEROG" },
        [DCSEx.enums.unitFamily.SHIP_FRIGATE] = { "PERRY", "USS_Arleigh_Burke_IIa" },
        [DCSEx.enums.unitFamily.SHIP_LIGHT] = { "speedboat" },
        [DCSEx.enums.unitFamily.SHIP_MISSILE_BOAT] = { "CastleClass_01", "La_Combattante_II" },
        [DCSEx.enums.unitFamily.SHIP_SUBMARINE] = { "santafe" },

        -- [DCSEx.enums.unitFamily.STATIC_STRUCTURE] = { "af_hq", ".Command Center", "Building01_PBR", "Building02_PBR", "Building03_PBR", "Building04_PBR", "Building05_PBR", "Bunker", "Chemical tank A", "Comms tower M", "FARP Fuel Depot", "outpost", "Sandbox", "Workshop A" },
        [DCSEx.enums.unitFamily.STATIC_STRUCTURE] = { "af_hq", ".Command Center", "Building01_PBR", "Building02_PBR", "Building03_PBR", "Building04_PBR", "Building05_PBR", "Chemical tank A", "Comms tower M", "FARP Fuel Depot", "outpost", "Workshop A" },
    }

    Library.factions.tables["USA"].units[DCSEx.enums.timePeriod.MODERN] = {
        [DCSEx.enums.unitFamily.AIRDEFENSE_AAA_MOBILE] = { "Gepard", "Vulcan" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_AAA_STATIC] = { "Gepard", "Vulcan" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_MANPADS] = { "Soldier stinger" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_LONG] = { "*Patriot" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_MEDIUM] = { "*HAWK", "*NASAMS" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_SHORT] = { "rapier_fsa", "Roland ADS" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_SHORT_IR] = { "M6 Linebacker", "M48 Chaparral", "M1097 Avenger" },

        [DCSEx.enums.unitFamily.GROUND_APC] = { "AAV7", "Cobra", "LAV-25", "M-2 Bradley", "M-113", "M1045 HMMWV TOW", "M1126 Stryker ICV", "M1128 Stryker MGS", "Marder", "MCV-80", "MLRS FDDM", "TPZ", "CHAP_M1130", "CHAP_MATV" },
        [DCSEx.enums.unitFamily.GROUND_ARTILLERY] = { "M-109", "MLRS", "CHAP_M142_ATACMS_M48", "CHAP_M142_GMLRS_M31" },
        [DCSEx.enums.unitFamily.GROUND_INFANTRY] = { "Soldier M4 GRG", "Soldier M4", "Soldier M249", "Soldier RPG" },
        [DCSEx.enums.unitFamily.GROUND_MBT] = { "Challenger2", "Leclerc", "Leopard-2", "Leopard1A3", "M-1 Abrams", "Merkava_Mk4" },
        [DCSEx.enums.unitFamily.GROUND_SS_MISSILE] = { "Scud_B" },
        [DCSEx.enums.unitFamily.GROUND_UNARMED] = { "Land_Rover_101_FC", "Land_Rover_109_S3", "M 818", "CHAP_M1083" },

        [DCSEx.enums.unitFamily.HELICOPTER_ATTACK] = { "AH-1W", "AH-64D", "OH-58D", "SA342L", "SA342M", "SA342Minigun", "SA342Mistral" },
        [DCSEx.enums.unitFamily.HELICOPTER_TRANSPORT] = { "CH-47D", "CH-53E", "SH-60B", "UH-60A" },

        [DCSEx.enums.unitFamily.PLANE_ATTACK] = { "A-10C_2" },
        [DCSEx.enums.unitFamily.PLANE_AWACS] = { "E-2C", "E-3A" },
        [DCSEx.enums.unitFamily.PLANE_BOMBER] = { "B-1B Lancer", "B-52H" },
        [DCSEx.enums.unitFamily.PLANE_FIGHTER] = { "F-16C_50", "FA-18C_hornet" },
        [DCSEx.enums.unitFamily.PLANE_TANKER] = { "KC-135", "KC135MPRS" },
        [DCSEx.enums.unitFamily.PLANE_TRANSPORT] = { "C-17A", "C-130" },
        [DCSEx.enums.unitFamily.PLANE_UAV] = { "RQ-1A Predator" },

        [DCSEx.enums.unitFamily.SHIP_CARGO] = { "Dry-cargo ship-1", "Dry-cargo ship-2", "ELNYA", "Ship_Tilde_Supply" },
        [DCSEx.enums.unitFamily.SHIP_CARRIER] = { "CVN_71", "CVN_72", "CVN_73", "CVN_75", "hms_invincible", "LHA_Tarawa", "Stennis" },
        [DCSEx.enums.unitFamily.SHIP_CRUISER] = { "TICONDEROG" },
        [DCSEx.enums.unitFamily.SHIP_FRIGATE] = { "PERRY", "USS_Arleigh_Burke_IIa" },
        [DCSEx.enums.unitFamily.SHIP_LIGHT] = { "speedboat" },
        [DCSEx.enums.unitFamily.SHIP_MISSILE_BOAT] = { "CastleClass_01", "La_Combattante_II" },
        [DCSEx.enums.unitFamily.SHIP_SUBMARINE] = { "santafe" },

        -- [DCSEx.enums.unitFamily.STATIC_STRUCTURE] = { "af_hq", ".Command Center", "Building01_PBR", "Building02_PBR", "Building03_PBR", "Building04_PBR", "Building05_PBR", "Bunker", "Chemical tank A", "Comms tower M", "FARP Fuel Depot", "outpost", "Sandbox", "Workshop A" },
        [DCSEx.enums.unitFamily.STATIC_STRUCTURE] = { "af_hq", ".Command Center", "Building01_PBR", "Building02_PBR", "Building03_PBR", "Building04_PBR", "Building05_PBR", "Chemical tank A", "Comms tower M", "FARP Fuel Depot", "outpost", "Workshop A" },
    }
end
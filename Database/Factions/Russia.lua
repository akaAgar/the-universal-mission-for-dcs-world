do
    local factionName = "Russia"
    -- if env.mission.date.Year < 1990 then
    --     factionName = "USSR"
    -- end

    Library.factions.defaults[coalition.side.RED] = factionName

    Library.factions.tables[factionName] = {}
    Library.factions.tables[factionName].theaters = {}
    Library.factions.tables[factionName].timePeriods = {}

    Library.factions.tables[factionName].units = {}

    Library.factions.tables[factionName].units[DCSEx.enums.timePeriod.WORLD_WAR_2] = {}
    Library.factions.tables[factionName].units[DCSEx.enums.timePeriod.KOREA_WAR] = {}
    Library.factions.tables[factionName].units[DCSEx.enums.timePeriod.VIETNAM_WAR] = {}
    Library.factions.tables[factionName].units[DCSEx.enums.timePeriod.COLD_WAR] = {}

    Library.factions.tables[factionName].units[DCSEx.enums.timePeriod.MODERN] = {
        [DCSEx.enums.unitFamily.AIRDEFENSE_AAA_MOBILE] = { "Ural-375 ZU-23", "ZSU_57_2", "ZSU-23-4 Shilka" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_AAA_STATIC] = { "ZU-23 Emplacement Closed", "ZU-23 Emplacement" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_MANPADS] = { "SA-18 Igla manpad", "SA-18 Igla-S manpad" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_LONG] = { "*SA-2", "*SA-10" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_LONG] = { "*SA-10" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_MEDIUM] = { "*SA-3", "*SA-6", "*SA-11" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_SHORT] = { "2S6 Tunguska", "Osa 9A33 ln", "Tor 9A331", "CHAP_PantsirS1", "CHAP_TorM2" },
        [DCSEx.enums.unitFamily.AIRDEFENSE_SAM_SHORT_IR] = { "Strela-1 9P31", "Strela-10M3" },

        [DCSEx.enums.unitFamily.GROUND_APC] = { "BMD-1", "BMP-1", "BMP-2", "BMP-3", "Boman", "BRDM-2", "BTR_D", "BTR-80", "BTR-82A", "Grad_FDDM", "MTLB", "CHAP_BMPT" },
        [DCSEx.enums.unitFamily.GROUND_ARTILLERY] = { "Grad-URAL", "SAU 2-C9", "SAU Akatsia", "SAU Gvozdika", "SAU Msta", "Smerch", "SpGH_Dana", "Uragan_BM-27", "CHAP_TOS1A" },
        [DCSEx.enums.unitFamily.GROUND_INFANTRY] = { "Infantry AK", "Infantry AK ver2", "Infantry AK ver3", "Paratrooper AKS-74", "Paratrooper RPG-16", "Soldier AK" },
        [DCSEx.enums.unitFamily.GROUND_MBT] = { "T-55", "T-72B", "T-80UD", "T-90" },
        [DCSEx.enums.unitFamily.GROUND_SS_MISSILE] = { "Scud_B", "CHAP_9K720_HE" },
        [DCSEx.enums.unitFamily.GROUND_UNARMED] = { "Ural-375", "Ural-4320 APA-5D", "Ural-4320T" },

        [DCSEx.enums.unitFamily.HELICOPTER_ATTACK] = { "Ka-50", "Mi-24V", "Mi-28N" },
        [DCSEx.enums.unitFamily.HELICOPTER_TRANSPORT] = { "Ka-27", "Mi-8MT", "Mi-26" },

        [DCSEx.enums.unitFamily.PLANE_ATTACK] = { "Su-25" },
        [DCSEx.enums.unitFamily.PLANE_AWACS] = { "A-50" },
        [DCSEx.enums.unitFamily.PLANE_BOMBER] = { "Tu-22M3", "Tu-95MS", "Tu-160" },
        [DCSEx.enums.unitFamily.PLANE_FIGHTER] = { "MiG-29", "Su-27", "Su-33" },
        [DCSEx.enums.unitFamily.PLANE_TANKER] = { "IL-78M" },
        [DCSEx.enums.unitFamily.PLANE_TRANSPORT] = { "An-26B", "An-30M", "IL-76MD" },
        [DCSEx.enums.unitFamily.PLANE_UAV] = { "WingLoong-I" },

        [DCSEx.enums.unitFamily.HELICOPTER_ATTACK] = { "Ka-50", "Mi-24V", "Mi-28N" },

        [DCSEx.enums.unitFamily.SHIP_CARGO] = { "Dry-cargo ship-1", "Dry-cargo ship-2", "ELNYA", "Ship_Tilde_Supply" },
        [DCSEx.enums.unitFamily.SHIP_CARRIER] = { "CV_1143_5", "KUZNECOW" },
        [DCSEx.enums.unitFamily.SHIP_CRUISER] = { "MOSCOW", "PIOTR" },
        [DCSEx.enums.unitFamily.SHIP_FRIGATE] = { "NEUSTRASH", "REZKY" },
        [DCSEx.enums.unitFamily.SHIP_LIGHT] = { "speedboat" },
        [DCSEx.enums.unitFamily.SHIP_MISSILE_BOAT] = { "ALBATROS", "BDK-775", "MOLNIYA", "CHAP_Project22160_TorM2KM" },
        [DCSEx.enums.unitFamily.SHIP_SUBMARINE] = { "IMPROVED_KILO", "KILO", "SOM" },

        -- [DCSEx.enums.unitFamily.STATIC_STRUCTURE] = { "af_hq", ".Command Center", "Building01_PBR", "Building02_PBR", "Building03_PBR", "Building04_PBR", "Building05_PBR", "Bunker", "Chemical tank A", "Comms tower M", "FARP Fuel Depot", "outpost", "Sandbox", "Workshop A" },
        [DCSEx.enums.unitFamily.STATIC_STRUCTURE] = { "af_hq", ".Command Center", "Building01_PBR", "Building02_PBR", "Building03_PBR", "Building04_PBR", "Building05_PBR", "Chemical tank A", "Comms tower M", "FARP Fuel Depot", "outpost", "Workshop A" },
    }
end

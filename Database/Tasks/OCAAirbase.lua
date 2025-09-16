Library.tasks.ocaAirbase = {
   taskFamily = DCSEx.enums.taskFamily.OCA,
   description =
   {
      briefing = {
         "Neutralizing this enemy airbase will eliminate their ability to conduct sustained air sorties and restore local air superiority.",
         "Taking out this airbase will disrupt their logistics and sortie tempo, buying time for our ground forces to consolidate.",
         "This airbase is the hub of enemy reconnaissance and close air support—removing it reduces battlefield intelligence and strike pressure.",
         "Outlasting enemy air campaign requires degrading that facility's operational capacity to prevent rotational sorties.",
         "Disabling this node of their air network constrains their command-and-control reach and limits coordinated strikes."
      },
      short = "Destroy enemy airbase",
   },
   conditions = {
      difficultyMinimum = 0,
      eras = {},
   },
   completionEvent = DCSEx.enums.taskEvent.DESTROY,
   flags = { DCSEx.enums.taskFlag.ALLOW_JTAC, DCSEx.enums.taskFlag.AIRBASE_TARGET },
   minimumDistance = DCSEx.converter.nmToMeters(10.0),
   safeRadius = 100,
   surfaceType = land.SurfaceType.LAND,
   targetCount = { 1, 1 },
   targetFamilies = { DCSEx.enums.unitFamily.STATIC_SCENERY },
   waypointInaccuracy = 0.0
}

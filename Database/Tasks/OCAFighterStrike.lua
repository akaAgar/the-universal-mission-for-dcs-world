Library.tasks.ocaFighterStrike = {
   taskFamily = DCSEx.enums.taskFamily.OCA,
   description =
   {
      briefing = {
         "",
      },
      short = "Destroy enemy bomber on the ramp",
   },
   conditions = {
      difficultyMinimum = 0,
      eras = {},
   },
   completionEvent = DCSEx.enums.taskEvent.DESTROY,
   flags = { DCSEx.enums.taskFlag.ALLOW_JTAC, DCSEx.enums.taskFlag.PARKED_AIRCRAFT_TARGET },
   minimumDistance = 0.0,
   safeRadius = 0,
   surfaceType = land.SurfaceType.LAND,
   targetCount = { 1, 1 },
   targetFamilies = { DCSEx.enums.unitFamily.PLANE_FIGHTER },
   waypointInaccuracy = 0.0
}

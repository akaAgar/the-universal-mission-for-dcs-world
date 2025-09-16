Library.tasks.heloHuntTransport = {
   taskFamily = DCSEx.enums.taskFamily.HELO_HUNT,
   description =
   {
      briefing = {
         "",
      },
      short = "Destroy enemy transport helicopters",
   },
   conditions = {
      difficultyMinimum = 0,
      eras = {},
   },
   completionEvent = DCSEx.enums.taskEvent.DESTROY,
   flags = { },
   minimumDistance = DCSEx.converter.nmToMeters(10.0),
   safeRadius = 100,
   surfaceType = nil,
   targetCount = { 2, 3 },
   targetFamilies = { DCSEx.enums.unitFamily.HELICOPTER_TRANSPORT },
   waypointInaccuracy = DCSEx.converter.nmToMeters(6.0)
}

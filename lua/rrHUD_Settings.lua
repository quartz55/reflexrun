reflexrun =
  {
  };

registerWidget("reflexrun");


function reflexrun:draw()
  consolePerformCommand("ui_reset")
  consolePerformCommand("ui_hide_all")
  rr_Timer:settings()
  rr_HealthBar:settings()
  rr_ArmorBar:settings()
  rr_SpeedMeter:settings()
  rr_TimeStamp:settings()
  rr_TimesList:settings()
  rr_NewRecord:settings()
  rr_SpecPlayer:settings()
  rr_MovementKeys:settings()
  rr_Tutorial:settings()
end

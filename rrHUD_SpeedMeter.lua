require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_SpeedMeter =
  {
  };

registerWidget("rr_SpeedMeter");

function rr_SpeedMeter:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local showPos = false

  local barWidth = viewport.width/2
  local barHeight = 20
  local barRight = 0
  local barLeft = barWidth
  local barTop = -barHeight
  local barBottom = 0

  local speedIcon = "internal/ui/reflexrunHUD/icons/ups"
  local speedIconSize = barHeight
  local speedIconX = speedIconSize + 20
  local speedIconY = -barHeight/2

  local speedFontSize = barHeight*2
  local speedFontX = speedIconX + speedIconSize + 10
  local speedFontY = -barHeight/2

  local speedIconColor = PHGPHUD_BLUE_COLOR
  local speedFontColor = PHGPHUD_WHITE_COLOR

  local speedText = math.floor(specPl.speed)

  -- Draw speed icon
  nvgFillColor(speedIconColor);
  nvgSvg(speedIcon, speedIconX, speedIconY, speedIconSize);

  -- Draw speed
  nvgFontSize(speedFontSize);
  nvgFontFace(PHGPHUD_FONT_BOLD);
  nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);

  nvgFillColor(PHGPHUD_BLACK_COLOR);
  nvgText(speedFontX, speedFontY+1, speedText)

  nvgFillColor(speedFontColor);
  nvgText(speedFontX, speedFontY, speedText)

  if showPos then
    nvgText(speedFontX, speedFontY-50, "|X| " .. math.floor(specPl.position.x) .. " |Y| " .. math.floor(specPl.position.y) .. " |Z| " .. math.floor(specPl.position.z))
  end
end

function rr_SpeedMeter:settings()
  consolePerformCommand("ui_show_widget rr_SpeedMeter")
  consolePerformCommand("ui_set_widget_anchor rr_SpeedMeter -1 1")
  consolePerformCommand("ui_set_widget_offset rr_SpeedMeter -1 " .. -PHGPHUD_BARS_HEIGHT-40)
  consolePerformCommand("ui_set_widget_scale rr_SpeedMeter 1")
end

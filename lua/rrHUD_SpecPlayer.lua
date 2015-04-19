require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_SpecPlayer =
  {
  };

registerWidget("rr_SpecPlayer");

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_SpecPlayer:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local barHeight = 40

  local specIcon = "internal/ui/reflexrunHUD/icons/visibility1";
  local specIconSize = barHeight*0.35
  local specIconX = specIconSize + 20
  local specIconY = barHeight/2
  local specIconColor = PHGPHUD_BLUE_COLOR

  local specFontSize = barHeight*0.8
  local specFontX = specIconX + specIconSize + 10
  local specFontY = barHeight/2
  local specFontColor = PHGPHUD_WHITE_COLOR

  local trapWidth = 300
  local trapHeight = barHeight
  local triLength = trapHeight/math.tan(0.913)
  local trapWidth2 = trapWidth-2*triLength

  -- Draw background trapezoid
  nvgScale(1, -1)
  drawTrapezoid({x = 0, y = 0},
    {bottomWidth = trapWidth, topWidth = trapWidth2, height = trapHeight}, "right")
    nvgFillLinearGradient(0, -trapHeight, 0, 0, ColorA(PHGPHUD_BLACK_COLOR, 225), ColorA(PHGPHUD_BLACK_COLOR, 245))
  nvgFill()
  nvgStrokeLinearGradient(0, -trapHeight, 0, 0, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
  nvgStroke()
  nvgBeginPath()
  nvgRect(0, 0, trapWidth-triLength, -trapHeight)
  nvgStrokeLinearGradient(0, -trapHeight, 0, 0, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
  nvgStroke()
  nvgScale(1, -1)

  -- Draw spec icon
  nvgFillColor(specIconColor);
  nvgSvg(specIcon, specIconX, specIconY, specIconSize);

  -- Draw spec name
  nvgFontSize(specFontSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
  nvgFillColor(specFontColor);

  nvgScissor(0, 0, trapWidth-triLength, trapHeight)
  nvgText(specFontX, specFontY, specPl.name)

end

function rr_SpecPlayer:settings()
  consolePerformCommand("ui_show_widget rr_SpecPlayer")
  consolePerformCommand("ui_set_widget_anchor rr_SpecPlayer -1 -1")
  consolePerformCommand("ui_set_widget_offset rr_SpecPlayer 0 0")
  consolePerformCommand("ui_set_widget_scale rr_SpecPlayer 1")
end

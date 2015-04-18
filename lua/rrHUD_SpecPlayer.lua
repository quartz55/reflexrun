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

  local barWidth = viewport.width/2
  local barHeight = 15
  local barRight = barWidth
  local barLeft = 0
  local barTop = 0
  local barBottom = 0

  local specIcon = "internal/ui/reflexrunHUD/icons/visibility1";
  local specIconSize = barHeight
  local specIconX = specIconSize + 20
  local specIconY = barHeight/2
  local specIconColor = PHGPHUD_WHITE_COLOR

  local specFontSize = barHeight*2
  local specFontX = specIconX + specIconSize + 10
  local specFontY = barHeight/2
  local specFontColor = PHGPHUD_WHITE_COLOR

  -- Draw spec icon
  nvgFillColor(specIconColor);
  nvgSvg(specIcon, specIconX, specIconY, specIconSize);

  -- Draw spec name
  nvgFontSize(specFontSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
  nvgFillColor(specFontColor);

  nvgText(specFontX, specFontY, specPl.name)

end

function rr_SpecPlayer:settings()
  consolePerformCommand("ui_show_widget rr_SpecPlayer")
  consolePerformCommand("ui_set_widget_anchor rr_SpecPlayer -1 -1")
  consolePerformCommand("ui_set_widget_offset rr_SpecPlayer 0 65")
  consolePerformCommand("ui_set_widget_scale rr_SpecPlayer 1")
end

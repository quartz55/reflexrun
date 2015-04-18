require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_MovementKeys =
  {
  };

registerWidget("rr_MovementKeys");

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_MovementKeys:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local leftArrowIcon = "internal/ui/reflexrunHUD/icons/leftarrow-01"
  local upArrowIcon = "internal/ui/reflexrunHUD/icons/toparrow-01"
  local rightArrowIcon = "internal/ui/reflexrunHUD/icons/rightarrow-01"
  local downArrowIcon = "internal/ui/reflexrunHUD/icons/downarrow-01"
  local jumpIcon = "internal/ui/reflexrunHUD/icons/Jump"

  local arrowIconSize = 10
  local arrowIconColor = PHGPHUD_WHITE_COLOR

  if specPl.buttons.left then
    nvgFillColor(arrowIconColor);
    nvgSvg(leftArrowIcon, -30, 0, arrowIconSize);
  end
  if specPl.buttons.forward then
    nvgFillColor(arrowIconColor);
    nvgSvg(upArrowIcon, 0, -30, arrowIconSize);
  end
  if specPl.buttons.right then
    nvgFillColor(arrowIconColor);
    nvgSvg(rightArrowIcon, 30, 0, arrowIconSize);
  end
  if specPl.buttons.back then
    nvgFillColor(arrowIconColor);
    nvgSvg(downArrowIcon, 0, 30, arrowIconSize);
  end
  if specPl.buttons.jump then
    nvgFillColor(arrowIconColor);
    nvgSvg(jumpIcon, 30, 30, arrowIconSize);
  end

end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_MovementKeys:settings()
  consolePerformCommand("ui_show_widget rr_MovementKeys")
  consolePerformCommand("ui_set_widget_anchor rr_MovementKeys 0 0")
  consolePerformCommand("ui_set_widget_offset rr_MovementKeys 0 0")
  consolePerformCommand("ui_set_widget_scale rr_MovementKeys 1")
end

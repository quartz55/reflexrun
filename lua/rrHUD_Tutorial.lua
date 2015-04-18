require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_Tutorial =
  {
  };

registerWidget("rr_Tutorial");

local tween = require "base/internal/ui/reflexrunHUD/lua/tween"

local svgSize = 500

local tVals = {alpha=0;y=65}

local animating = false

local alphaT, yT, yT, yT, yT
-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_Tutorial:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local tutorialSVG = "internal/ui/reflexrunHUD/icons/tabtutorial";
  local svgX = 0
  local svgY = 0

  -- if showScores then
  --   if not animating then
  --     animating = true

  --     alphaT = tween.new(1-tVals.alpha+0.01, tVals, {alpha = 1}, 'outQuint')
  --     yT = tween.new(1-(65-tVals.y)/65+0.01, tVals, {y = 0}, 'outQuint')
  --   end
  -- elseif animating then
  --   animating = false

  --   alphaT = tween.new(tVals.alpha*0.5+0.01, tVals, {alpha = 0}, 'inQuint')
  --   yT = tween.new(0.5-(tVals.y/65)*0.5+0.01, tVals, {y = 65}, 'inQuint')
  -- end

  -- if alphaT ~= null then alphaT:update(deltaTimeRaw) end
  -- if yT ~= null then yT:update(deltaTimeRaw) end

  -- if tVals.alpha <= 0 then return end

  -- nvgFillColor(ColorA(PHGPHUD_WHITE_COLOR, 255*tVals.alpha));
  -- nvgSvg(tutorialSVG, svgX, svgX+tVals.y, svgSize);

end

function rr_Tutorial:settings()
  consolePerformCommand("ui_show_widget rr_Tutorial")
  consolePerformCommand("ui_set_widget_anchor rr_Tutorial 0 1")
  consolePerformCommand("ui_set_widget_offset rr_Tutorial 0 " .. -PHGPHUD_BARS_HEIGHT - svgSize/2*0.95)
  consolePerformCommand("ui_set_widget_scale rr_Tutorial 1")
end

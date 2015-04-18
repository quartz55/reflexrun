require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_TimeStamp =
  {
    time = 0;
  };

registerWidget("rr_TimeStamp");

local tween = require "base/internal/ui/reflexrunHUD/lua/tween"

local tVals = {}

local function showStamp(text)

  local stampIcon = "internal/ui/reflexrunHUD/icons/RunEnded";
  local stampIconSize = 30*tVals.size
  local stampIconX = 0;
  local stampIconY = 0-tVals.y;
  local stampIconColor = ColorA(PHGPHUD_BLUE_COLOR, 255*tVals.alpha)

  local stampCircleSize = stampIconSize+15
  local stampCircleStrokeSize = 5
  local stampCircleColor = ColorA(PHGPHUD_BLACK_COLOR, 255*tVals.alpha)
  local stampCircleStrokeColor = ColorA(PHGPHUD_LIGHTGREY_COLOR, 255*tVals.alpha)

  local stampFontSize = 70
  local stampFontX = 0;
  local stampFontY = stampCircleSize+10+tVals.y;
  local stampFontColor = ColorA(PHGPHUD_WHITE_COLOR, 255*tVals.alpha)

  -- Draw stamp icon
  nvgBeginPath()

  nvgFillColor(ColorA(stampCircleColor, 255*tVals.alpha2))
  nvgCircle(stampIconX, stampIconY, stampCircleSize*tVals.size2)
  nvgFill()

  nvgBeginPath()

  nvgFillColor(stampCircleColor)
  nvgCircle(stampIconX, stampIconY, stampCircleSize)
  nvgFill()
  nvgStrokeWidth(stampCircleStrokeSize)
  nvgStrokeColor(stampCircleStrokeColor)
  nvgStroke()

  nvgFillColor(stampIconColor);
  nvgSvg(stampIcon, stampIconX, stampIconY, stampIconSize);

  -- Draw stamp time
  nvgFontSize(stampFontSize);
  nvgFontFace(PHGPHUD_FONT_BOLD);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

  nvgFillColor(ColorA(PHGPHUD_BLACK_COLOR, 255*tVals.alpha));
  nvgText(stampFontX, stampFontY+1, text)

  nvgFillColor(stampFontColor);
  nvgText(stampFontX, stampFontY, text)

end

local animating = false
local sizeT, alphaT, yT, sizeT2, alphaT2
local function animate(time)

  if not animating then
    animating = true
    tVals.y = 80
    tVals.size = 1.5
    tVals.alpha = 1

    tVals.size2 = 1
    tVals.alpha2 = 1

    yT = tween.new(2, tVals, {y = 0}, 'outElastic')
    sizeT = tween.new(3, tVals, {size = 1}, 'inOutElastic')
    alphaT = tween.new(2, tVals, {alpha = 0}, 'inQuint', 4)

    sizeT2 = tween.new(1, tVals, {size2 = 5}, 'outQuint')
    alphaT2 = tween.new(1, tVals, {alpha2 = 0}, 'outQuint')

  elseif animating then

    sizeT:update(deltaTimeRaw)
    yT:update(deltaTimeRaw)
    sizeT2:update(deltaTimeRaw)
    alphaT2:update(deltaTimeRaw)
    local alphaTDone = alphaT:update(deltaTimeRaw)
    if alphaTDone then
      animating = false
    end

    showStamp(formatTime(time))

  end

end

function rr_TimeStamp:newStamp(time)
  animating = false
  rr_TimeStamp.time = time
  animate(rr_TimeStamp.time)
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_TimeStamp:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  if animating then animate(rr_TimeStamp.time) end

end

function rr_TimeStamp:settings()
  consolePerformCommand("ui_show_widget rr_TimeStamp")
  consolePerformCommand("ui_set_widget_anchor rr_TimeStamp 0 -1")
  consolePerformCommand("ui_set_widget_offset rr_TimeStamp 0 100")
  consolePerformCommand("ui_set_widget_scale rr_TimeStamp 1")
end

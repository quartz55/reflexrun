require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_NewRecord =
  {
  };

registerWidget("rr_NewRecord");

local tween = require("base/internal/ui/reflexrunHUD/tween")

local tVals = {}

local function showStamp(text)

  local stampIcon = "internal/ui/reflexrunHUD/icons/Newrecordicon";
  local stampIconSize = 30*tVals.size
  local stampIconX = 0;
  local stampIconY = 0-tVals.y;
  local stampIconColor = ColorA(PHGPHUD_WHITE_COLOR, 255*tVals.alpha)

  local stampCircleSize = stampIconSize+15
  local stampCircleStrokeSize = 5
  local stampCircleColor = ColorA(PHGPHUD_BLACK_COLOR, 255*tVals.alpha)
  local stampCircleStrokeColor = ColorA(PHGPHUD_GOLD_COLOR, 255*tVals.alpha)

  local stampFontSize = 70
  local stampFontX = 0;
  local stampFontY = stampCircleSize+10+tVals.y;
  local stampFontColor = ColorA(PHGPHUD_LIGHTGOLD_COLOR, 255*tVals.alpha)

  -- Draw record icon
  nvgBeginPath()

  nvgFillColor(ColorA(PHGPHUD_LIGHTGOLD_COLOR, 255*tVals.alpha2))
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

  -- Draw record text
  nvgFontSize(stampFontSize);
  nvgFontFace(PHGPHUD_FONT_BOLD);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

  nvgFillColor(ColorA(PHGPHUD_BLACK_COLOR, 255*tVals.alpha));
  nvgText(stampFontX, stampFontY+1, text)

  nvgFillColor(stampFontColor);
  nvgText(stampFontX, stampFontY, text)

end

local animating = false
local soundPlayed = false
local sizeT, alphaT, yT, sizeT2, alphaT2, delayT
local function animate(text)

  if not animating then
    animating = true
    tVals.y = 50
    tVals.size = 1.5
    tVals.alpha = 1

    tVals.size2 = 1
    tVals.alpha2 = 1

    tVals.delay = 0

    delayT = tween.new(1, tVals, {delay = 0})

    yT = tween.new(2, tVals, {y = 0}, 'outElastic')
    sizeT = tween.new(3, tVals, {size = 1}, 'inOutElastic', 0.5)
    alphaT = tween.new(2, tVals, {alpha = 0}, 'inQuint', 4)

    sizeT2 = tween.new(1, tVals, {size2 = 5}, 'outQuint')
    alphaT2 = tween.new(1, tVals, {alpha2 = 0}, 'outQuint')

  elseif animating then
    local delayDone = delayT:update(deltaTimeRaw)
    if delayDone then
      if not soundPlayed then
        for i=1,6,1 do
          playSound("internal/ui/reflexrunHUD/sfx/newrecordfinal");
        end
        soundPlayed = true
      end
      sizeT:update(deltaTimeRaw)
      yT:update(deltaTimeRaw)
      sizeT2:update(deltaTimeRaw)
      alphaT2:update(deltaTimeRaw)
      local alphaTDone = alphaT:update(deltaTimeRaw)
      if alphaTDone then
        animating = false
        soundPlayed = false
      end

      showStamp(text)

    end

  end

end

function rr_NewRecord:new()
  animating = false
  animate("NEW RECORD")
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_NewRecord:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  if animating then animate("NEW RECORD") end

end

function rr_NewRecord:settings()
  consolePerformCommand("ui_show_widget rr_NewRecord")
  consolePerformCommand("ui_set_widget_anchor rr_NewRecord 0 0")
  consolePerformCommand("ui_set_widget_offset rr_NewRecord 0 -220")
  consolePerformCommand("ui_set_widget_scale rr_NewRecord 1")
end

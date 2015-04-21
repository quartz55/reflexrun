require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_TimesList =
  {
  };

registerWidget("rr_TimesList");

local localList = {}
local prevTime
local maxTimers = 5

-------------------------------------------------------------------------
-------------------------------------------------------------------------

local function drawList(list)

  local labelSize = 30
  local timerSize = 40
  local frameX = 0

  -- get text length
  nvgFontSize(timerSize);
  nvgFontFace(PHGPHUD_FONT_BOLD);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

  local frameWidth = nvgTextWidth("00:00:00") + 20
  local frameHeight = timerSize+20

  local trapWidth2 = (maxTimers+3)*frameHeight
  local trapHeight = frameWidth
  local trapWidth = trapWidth2+2*(trapHeight/math.tan(0.913))

  local textX = frameWidth/2
  local textY = -trapWidth2/2


  -- Draw background trapezoid
  nvgRotate(math.pi/2)
  drawTrapezoid({x = -trapWidth/2, y = 0},
    {bottomWidth = trapWidth, topWidth = trapWidth2, height = trapHeight}, "full")
    nvgFillLinearGradient(0, -frameHeight, 0, 0, ColorA(PHGPHUD_BLACK_COLOR, 225), ColorA(PHGPHUD_BLACK_COLOR, 245))
  nvgFill()
  nvgStrokeLinearGradient(0, -frameHeight, 0, 0, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
  nvgStroke()
  nvgRotate(-math.pi/2)

  -- Draw run records
  nvgBeginPath()
  nvgRect(0, textY, frameWidth, frameHeight, 5)
  nvgFillColor(PHGPHUD_BLUE_COLOR)
  nvgStrokeLinearGradient(frameWidth, 0, 0, 0, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
  nvgStroke()
  nvgFontSize(labelSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
  nvgFillColor(PHGPHUD_BLUE_COLOR);
  nvgFontBlur(0)
  nvgText(textX, textY+frameHeight/2, "Run Records")

  textY = textY + frameHeight

  -- Draw records
  for i, v in pairs(list) do

    if i > maxTimers then break end

    nvgBeginPath()
    nvgRect(frameX, textY, frameWidth, frameHeight, 5)
    nvgFillColor(PHGPHUD_BLUE_COLOR)
    if i == 1 then nvgFill() end
    nvgStrokeLinearGradient(frameWidth, 0, 0, 0, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
    nvgStroke()

    nvgFontSize(timerSize);
    nvgFontFace(PHGPHUD_FONT_REGULAR);
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

    local timerText = formatTime(v)
    nvgFillColor(PHGPHUD_WHITE_COLOR);
    nvgText(textX, textY+frameHeight/2, timerText)

    textY = textY + frameHeight
  end

  -- Draw prevrun
  ---- BG
  nvgBeginPath()
  nvgRect(0, textY, frameWidth, frameHeight, 5)
  nvgFillColor(PHGPHUD_BLUE_COLOR)
  nvgStrokeLinearGradient(frameWidth, 0, 0, 0, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))

  ---- Text
  nvgFontSize(labelSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);
  nvgFillColor(PHGPHUD_BLUE_COLOR);
  nvgFontBlur(0)
  nvgText(textX, textY+frameHeight/2, "Previous Run")

  textY = textY + frameHeight

  nvgBeginPath()
  nvgFillColor(PHGPHUD_BLUE_COLOR)
  nvgRect(frameX, textY, frameWidth, frameHeight, 5)
  nvgStrokeLinearGradient(frameWidth, 0, 0, 0, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
  nvgStroke()

  nvgFontSize(timerSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);


  local timerText = formatTime(prevTime)
  nvgFillColor(PHGPHUD_BLACK_COLOR);
  nvgText(textX, textY+frameHeight/2+1, timerText)
  nvgFillColor(PHGPHUD_WHITE_COLOR);
  nvgText(textX, textY+frameHeight/2, timerText)

end

function rr_TimesList:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  drawList(localList)

end

function rr_TimesList:updateList(newList, newPrevTime)
  prevTime = newPrevTime or prevTime
  for i,v in pairs(newList) do
    localList[i] = v
  end
end

function rr_TimesList:settings()
  consolePerformCommand("ui_show_widget rr_TimesList")
  consolePerformCommand("ui_set_widget_anchor rr_TimesList -1 0")
  consolePerformCommand("ui_set_widget_offset rr_TimesList 0 0")
  consolePerformCommand("ui_set_widget_scale rr_TimesList 1")
end

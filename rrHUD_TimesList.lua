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
  local timerSpacing = 10

  local frameX = 0

  nvgFontSize(timerSize);
  nvgFontFace(PHGPHUD_FONT_BOLD);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);
  local frameWidth = nvgTextWidth("00:00:00") + 20
  local frameHeight = timerSize+10

  local textX = frameWidth/2
  local textY = -#localList/2*(frameHeight+timerSpacing)


  -- Draw run records
  nvgFontSize(labelSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

  nvgFillColor(PHGPHUD_WHITE_COLOR);
  nvgText(textX, textY, "Run Records")

  textY = textY + labelSize + timerSpacing

  for i, v in pairs(list) do

    if i > maxTimers then break end

    nvgBeginPath()
    nvgFillColor(PHGPHUD_BLUE_COLOR)
    nvgRoundedRect(frameX, textY, frameWidth, frameHeight, 5)
    if i == 1 then nvgFill() end
    nvgStrokeColor(PHGPHUD_WHITE_COLOR)
    nvgStroke()

    nvgFontSize(timerSize);
    nvgFontFace(PHGPHUD_FONT_REGULAR);
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

    local timerText = formatTime(v)
    nvgFillColor(PHGPHUD_BLACK_COLOR);
    nvgText(textX, textY+frameHeight/2+1, timerText)
    nvgFillColor(PHGPHUD_WHITE_COLOR);
    nvgText(textX, textY+frameHeight/2, timerText)

    textY = textY + frameHeight + timerSpacing
  end

  -- Draw prevrun records
  nvgFontSize(labelSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_TOP);

  nvgFillColor(PHGPHUD_WHITE_COLOR);
  nvgText(textX, textY, "Previous Run")

  textY = textY + labelSize + timerSpacing

  if prevTime == null then return end

  nvgBeginPath()
  nvgFillColor(PHGPHUD_BLUE_COLOR)
  nvgRoundedRect(frameX, textY, frameWidth, frameHeight, 5)
  nvgStrokeColor(PHGPHUD_WHITE_COLOR)
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
  prevTime = newPrevTime
  for i,v in pairs(newList) do
    localList[i] = v
  end
end

function rr_TimesList:settings()
  consolePerformCommand("ui_show_widget rr_TimesList")
  consolePerformCommand("ui_set_widget_anchor rr_TimesList -1 0")
  consolePerformCommand("ui_set_widget_offset rr_TimesList 30 0")
  consolePerformCommand("ui_set_widget_scale rr_TimesList 1")
end

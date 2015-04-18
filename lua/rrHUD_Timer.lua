require "base/internal/ui/reflexrunHUD/phgphudcore"
require "base/internal/ui/reflexrunHUD/lua/rrMapTriggers"

rr_Timer =
  {
    firstStart = true
  };

registerWidget("rr_Timer");

-------------------------------------------------------------------------
-- Timer Class
-------------------------------------------------------------------------
local Timer = {}
Timer.__index = Timer

function Timer.new(delta)
  local self = setmetatable({}, Timer)
  self.delta = delta
  self.timer = 0.0
  self.counting = false
  return self
end

function Timer.update(self)
  if self.counting then
    self.timer = self.timer + self.delta
  end
end

function Timer.reset(self)
  self.timer = 0
  self.counting = false
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

local startZone, endzone
local currMap
local maxStamps = 5

local timer
local timeStamps = {}

local function resetTimes()
  for i=1, maxStamps,1 do
    timeStamps[i] = PHGPHUD_TIMER_MAX
  end
end

local function stampTime(time)

  if time < timeStamps[1] then
    -- rr_NewRecord:new()
  end

  for i, v in pairs(timeStamps) do
    if time < v or v == nil then
      table.insert(timeStamps, i, time)
      timeStamps[maxStamps+1] = nil
      break
    end
  end

  -- rr_TimeStamp:newStamp(time)
  rr_TimesList:updateList(timeStamps, time)
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_Timer:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  -- Reset times on load
  if currMap ~= world.mapName or currMap == nil then
    resetTimes()
    rr_TimesList:updateList(timeStamps, PHGPHUD_TIMER_MAX)
    currMap = world.mapName
  end

  -- Sizes and positions
  local frameWidth = viewport.width
  local frameHeight = PHGPHUD_BARS_HEIGHT

  local frameTop = -frameHeight
  local frameBottom = 0
  local frameLeft = 0
  local frameRight = frameWidth

  ------- Icons
  local mapIcon = "internal/ui/reflexrunHUD/icons/Map";
  local mapIconSize = frameHeight*0.3
  local mapIconX = mapIconSize + 20
  local mapIconY = -frameHeight/2

  local alertIcon = "internal/ui/reflexrunHUD/icons/Megaalert";
  local alertIconSize = frameHeight*0.3
  local alertIconX = frameWidth/4
  local alertIconY = -frameHeight/2

  local timerIcon = "internal/ui/reflexrunHUD/icons/Timer";
  local timerIconSize = frameHeight*0.3
  local timerIconX = frameWidth/2-108
  local timerIconY = -frameHeight/2

  local logoIcon = "internal/ui/reflexrunHUD/icons/reflexrun";
  local logoIconSize = frameHeight*2.5
  local logoIconX = frameWidth-logoIconSize-30
  local logoIconY = -frameHeight/2

  ------- Fonts
  local timerFontSize = frameHeight
  local timerFontX = timerIconX + timerIconSize + 10
  local timerFontY = -frameHeight/2

  local mapFontSize = frameHeight*0.8
  local mapFontX = mapIconX + mapIconSize + 10
  local mapFontY = -frameHeight/2

  local alertFontSize = frameHeight*0.5
  local alertFontX = alertIconX + alertIconSize + 10
  local alertFontY = -frameHeight/2

  -- Colors
  local frameColor = PHGPHUD_BACKGROUND_COLOR
  local strokeColor = PHGPHUD_BLUE_COLOR
  local fontColor = PHGPHUD_WHITE_COLOR
  local mapIconColor = PHGPHUD_BLUE_COLOR
  local alertIconColor = PHGPHUD_YELLOW_COLOR
  local timerIconColor = PHGPHUD_BLUE_COLOR
  local logoIconColor = PHGPHUD_WHITE_COLOR

  -------------------------------------------------------------------------
  -- Timer --
  -------------------------------------------------------------------------
  if rr_Timer.firstStart then
    timer = Timer.new(deltaTimeRaw)
    rr_Timer.firstStart = false
    startZone = false
  end

  -- Start timer
  if startZone
    and not checkPlayerPosition(specPl, world.mapName, "begin")
  then
    timer.timer = 0.0
    timer.counting = true
    for i=1,PHGPHUD_TIMERSOUNDS_VOLUME,1 do
      playSound("internal/ui/reflexrunHUD/sfx/DefragStart");
    end
  end

  -- Reset timer
  if timer.counting
    and checkPlayerPosition(localPl, world.mapName, "begin")
  then
    timer.timer = 0.0
    timer.counting = false
  end

  -- End timer
  if timer.counting
  and checkPlayerPosition(specPl, world.mapName, "end")
    and not endZone
  then
    timer.counting = false
    stampTime(timer.timer)
    for i=1,PHGPHUD_TIMERSOUNDS_VOLUME,1 do
      playSound("internal/ui/reflexrunHUD/sfx/DefragStop");
    end
  end

  startZone = checkPlayerPosition(specPl, world.mapName, "begin")
  endZone = checkPlayerPosition(specPl, world.mapName, "end")

  local currTime = formatTime(0)
  if timer ~= nil then
    timer:update()
    currTime = formatTime(timer.timer)
  end
  -------------------------------------------------------------------------
  -------------------------------------------------------------------------

  -- Draw frame
  nvgBeginPath();
  nvgRect(frameLeft, frameTop, frameWidth, frameHeight);
  nvgFillColor(frameColor);
  nvgFill();
  nvgStrokeLinearGradient(frameLeft, frameTop, frameLeft, frameHeight, strokeColor, ColorA(strokeColor, 0));
  nvgStroke();

  -- Draw map icon
  nvgFillColor(mapIconColor);
  nvgSvg(mapIcon, mapIconX, mapIconY, mapIconSize);

  -- Draw map name
  nvgFontSize(mapFontSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
  nvgFillColor(fontColor);
  nvgText(mapFontX, mapFontY, world.mapName)

  -- Ready alert
  -- if not timer.counting and not specPl.hasMega then
  --   -- Draw alert text
  --   nvgFontSize(alertFontSize);
  --   nvgFontFace(PHGPHUD_FONT_REGULAR);
  --   nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);

  --   local size = nvgTextWidth("Pick Mega to ready")
  --   nvgFillColor(ColorA(alertIconColor, 100));
  --   nvgFontBlur(3)
  --   nvgText(alertFontX-size/2, alertFontY, "Pick Mega to ready")
  --   nvgFillColor(alertIconColor);
  --   nvgFontBlur(0)
  --   nvgText(alertFontX-size/2, alertFontY, "Pick Mega to ready")

  --   -- Draw alert icon
  --   nvgFillColor(alertIconColor);
  --   nvgSvg(alertIcon, alertIconX-size/2, alertIconY, alertIconSize);
  -- end

  -- Draw timer icon
  nvgFillColor(timerIconColor);
  nvgSvg(timerIcon, timerIconX, timerIconY, timerIconSize);

  -- Draw timer
  nvgFontSize(timerFontSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
  nvgFillColor(fontColor);
  nvgText(timerFontX, timerFontY, currTime)

  -- nvgFillColor(fontColor);
  -- if checkPlayerPosition(specPl, world.mapName, "begin") then
  --   nvgText(timerFontX, timerFontY-100, "IN")
  -- else
  --   nvgText(timerFontX, timerFontY-100, "OUT")
  -- end

  -- Draw logo icon
  nvgFillColor(logoIconColor);
  nvgSvg(logoIcon, logoIconX, logoIconY, logoIconSize);

end

function rr_Timer:settings()
  consolePerformCommand("ui_show_widget rr_Timer")
  consolePerformCommand("ui_set_widget_anchor rr_Timer -1 1")
  consolePerformCommand("ui_set_widget_offset rr_Timer 0 0")
  consolePerformCommand("ui_set_widget_scale rr_Timer 1")
end

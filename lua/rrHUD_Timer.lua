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

function Timer.new()
  local self = setmetatable({}, Timer)
  self.timer = 0.0
  self.counting = false
  return self
end

function Timer.update(self, delta)
  if self.counting then
    self.timer = self.timer + delta
  end
end

function Timer.reset(self)
  self.timer = 0
  self.counting = false
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

local playerList = {}
local currMap, currTime
local maxStamps = 5

local function resetTimes()
  local stamps = {}
  for i=1, maxStamps,1 do
    stamps[i] = PHGPHUD_TIMER_MAX
  end
  return stamps
end

local function stampTime(time, player, specPl)

  player.prevTime = time

  if time < player.timeStamps[1]
    and checkIfSame(specPl, player)
  then
    rr_NewRecord:new()
  end

  for i, v in pairs(player.timeStamps) do
    if time < v or v == nil then
      table.insert(player.timeStamps, i, time)
      table.remove(player.timeStamps, #player.timeStamps)
      break
    end
  end

  if checkIfSame(specPl, player) then
    rr_TimeStamp:newStamp(time)
    rr_TimesList:updateList(player.timeStamps, player.prevTime)
  end
end

local function createNewPlayer(player)
  local pl = {}
  local pos = {}
  pl.name = player.name
  pos.x = player.position.x
  pos.y = player.position.y
  pos.z = player.position.z
  pl.position = pos
  pl.timeStamps = resetTimes()
  pl.timer = Timer.new()
  pl.prevTime = PHGPHUD_TIMER_MAX
  pl.startZone = true
  pl.endZone = false
  return pl
end

local function createPlayerList(specPl)
  for i, v in pairs(players) do
    pl = createNewPlayer(v)
    playerList[#playerList+1] = pl

    if checkIfSame(specPl, pl) then
      rr_TimesList:updateList(pl.timeStamps, PHGPHUD_TIMER_MAX)
    end
  end
end

local function updatePlayerList(specPl)
  for i, v in pairs(players) do
    exists = false
    for j, n in pairs(playerList) do
      if v.name == n.name then
        exists = true
        playerList[j].position.x = v.position.x
        playerList[j].position.y = v.position.y
        playerList[j].position.z = v.position.z

        -- Start timer
        if playerList[j].startZone
          and not checkPlayerPosition(playerList[j], world.mapName, "begin")
        then
          playerList[j].timer.timer = 0.0
          playerList[j].timer.counting = true

          -- If specing player play sound
          if checkIfSame(specPl, playerList[j]) then
            for i=1,PHGPHUD_TIMERSOUNDS_VOLUME,1 do
              playSound("internal/ui/reflexrunHUD/sfx/DefragStart");
            end
          end

        end

        -- Reset timer
        if playerList[j].timer.counting
          and checkPlayerPosition(playerList[j], world.mapName, "begin")
        then
          playerList[j].timer.timer = 0.0
          playerList[j].timer.counting = false
        end

        -- End timer
        if playerList[j].timer.counting
        and checkPlayerPosition(playerList[j], world.mapName, "end")
          and not playerList[j].endZone
        then
          playerList[j].timer.counting = false
          stampTime(playerList[j].timer.timer, playerList[j], specPl)

          -- If specing player play sound
          if checkIfSame(specPl, playerList[j]) then
            for i=1,PHGPHUD_TIMERSOUNDS_VOLUME,1 do
              playSound("internal/ui/reflexrunHUD/sfx/DefragStop");
            end
          end

        end

        playerList[j].startZone = checkPlayerPosition(playerList[j], world.mapName, "begin")
        playerList[j].endZone = checkPlayerPosition(playerList[j], world.mapName, "end")

        if playerList[j].timer ~= nil then
          playerList[j].timer:update(deltaTimeRaw)
        end

        -- If specing player show timer
        if checkIfSame(specPl, playerList[j]) then
          rr_TimesList:updateList(playerList[j].timeStamps, playerList[j].prevTime)
          currTime = formatTime(playerList[j].timer.timer)
        end

      end
    end
    if not exists then table.insert(playerList, createNewPlayer(v)) end
  end

  -- Cleanup disconnected players
  -- for i, v in pairs(playerList) do
  --   exists = false
  --   for j, n in pairs(players) do
  --     if n.name == v.name then exists = true; break end
  --   end
  --   if not exists then table.remove(playerList, i) end
  -- end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_Timer:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()


  -- Sizes and positions
  local frameWidth = viewport.width
  local frameWidth2 = frameWidth*0.95
  local frameHeight = PHGPHUD_BARS_HEIGHT

  local frameTop = -frameHeight
  local frameBottom = 0
  local frameLeft = 0
  local frameRight = frameWidth

  ------- Icons
  local mapIcon = "internal/ui/reflexrunHUD/icons/Map";
  local mapIconSize = frameHeight*0.3
  local mapIconX = (frameWidth-frameWidth2)/2+mapIconSize + 20
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
  local logoIconX = frameWidth-(frameWidth-frameWidth2)/2-logoIconSize-30
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
    createPlayerList(specPl)
    rr_Timer.firstStart = false
  end

  -- Reset times on load
  if currMap ~= world.mapName or currMap == nil then
    createPlayerList(specPl)
    currMap = world.mapName
  end

  updatePlayerList(specPl)

  -------------------------------------------------------------------------
  -------------------------------------------------------------------------

  -- testing
  drawTrapezoid({x = frameLeft, y = frameBot},
    {bottomWidth=frameWidth, topWidth = frameWidth2, height = frameHeight}, "full")
  nvgFillLinearGradient(frameLeft, frameTop, frameLeft, frameBottom, ColorA(PHGPHUD_BLACK_COLOR, 225), ColorA(PHGPHUD_BLACK_COLOR, 245))
  nvgFill()
  nvgStrokeLinearGradient(frameLeft, frameTop, frameLeft, frameBottom, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
  nvgStroke()
  nvgBeginPath()
  nvgRect(frameLeft+(frameWidth-frameWidth2)/2, frameTop, frameWidth2, frameHeight)
  nvgStrokeLinearGradient(frameLeft, frameTop, frameLeft, frameBottom, PHGPHUD_BLUE_COLOR, ColorA(PHGPHUD_BLUE_COLOR, 0))
  nvgStroke()

  -- Draw frame
  -- nvgBeginPath();
  -- nvgRect(frameLeft, frameTop, frameWidth, frameHeight);
  -- nvgFillColor(frameColor);
  -- nvgFill();
  -- nvgStrokeLinearGradient(frameLeft, frameTop, frameLeft, frameHeight, strokeColor, ColorA(strokeColor, 0));
  -- nvgStroke();

  -- Draw map icon
  nvgFillColor(mapIconColor);
  nvgSvg(mapIcon, mapIconX, mapIconY, mapIconSize);

  -- Draw map name
  nvgFontSize(mapFontSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
  nvgFillColor(fontColor);
  nvgText(mapFontX, mapFontY, world.mapName)

  -- Draw timer icon
  nvgFillColor(timerIconColor);
  nvgSvg(timerIcon, timerIconX, timerIconY, timerIconSize);

  -- Draw timer
  nvgFontSize(timerFontSize);
  nvgFontFace(PHGPHUD_FONT_REGULAR);
  nvgTextAlign(NVG_ALIGN_LEFT, NVG_ALIGN_MIDDLE);
  nvgFillColor(fontColor);
  nvgText(timerFontX, timerFontY, currTime)

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

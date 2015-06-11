require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_Timer =
  {
    firstStart = true
  };

registerWidget("rr_Timer");

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

local function stampTime(time, Pl, specPl)

  if time < Pl.timeStamps[1]
    and checkIfSame(Pl, specPl)
  then
    rr_NewRecord:new()
  end

  for i, v in pairs(Pl.timeStamps) do
    if time < v or v == nil then
      table.insert(Pl.timeStamps, i, time)
      table.remove(Pl.timeStamps, #Pl.timeStamps)
      break
    end
  end

  if checkIfSame(Pl, specPl) then
    rr_TimeStamp:newStamp(time)
    rr_TimesList:updateList(Pl.timeStamps, Pl.prevTime)
  end
end

local function createNewPlayer(specPl)
  local pl = {}
  pl.name = specPl.name
  pl.timeStamps = resetTimes()
  pl.time = specPl.raceTimeCurrent or 0.0
  pl.prevTime = specPl.raceTimePrevious or PHGPHUD_TIMER_MAX
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


  -- count log messages
  local logCount = 0
  for k, v in pairs(log) do
    logCount = logCount + 1;
  end

  -- read log messages
  local latestEntry = {}
  for i = 1, logCount do
    local logEntry = log[i];
    if logEntry.age <= deltaTime then
      table.insert(latestEntry, logEntry)
    end
  end

  for i, v in pairs(players) do
    exists = false
    for j, n in pairs(playerList) do
      if v.name == n.name then
        exists = true

        playerList[j].time = players[i].raceTimeCurrent
        playerList[j].prevTime = players[i].raceTimePrevious

        -- Check latest entries
        for index, entry in pairs(latestEntry) do
          -- is race entry?
          if entry.type == LOG_TYPE_RACEEVENT then
            if players[entry.racePlayerIndex].name == playerList[j].name then
              -- Start timer Event
              if entry.raceEvent == RACE_EVENT_START then
                if checkIfSame(specPl, playerList[j]) then
                  playSound("internal/ui/reflexrunHUD/sfx/DefragStart");
                end
              end

              -- End timer Event
              if entry.raceEvent == RACE_EVENT_FINISH or
                entry.raceEvent == RACE_EVENT_FINISHANDWASRECORD
              then
                stampTime(playerList[j].prevTime, playerList[j], specPl)

                if checkIfSame(specPl, playerList[j]) then
                  playSound("internal/ui/reflexrunHUD/sfx/DefragStop");
                end
              end
            end
          end
        end
      end

      -- If specing specPl show times
      if checkIfSame(specPl, playerList[j]) then
        rr_TimesList:updateList(playerList[j].timeStamps, playerList[j].prevTime)
        if not specPl.raceActive then
          currTime = formatTime(playerList[j].prevTime)
        else
          currTime = formatTime(playerList[j].time)
        end
      end
    end

    if not exists then table.insert(playerList, createNewPlayer(v)) end
  end
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_Timer:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  -- Sizes and positions
  local frameWidth = viewport.width
  local frameHeight = PHGPHUD_BARS_HEIGHT
  local frameWidth2 = frameWidth-2*(frameHeight/math.tan(math.pi/4))

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

  -- Trapezoid
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

  if DEBUG then
    local time = formatTime(specPl.raceTimeCurrent)
    if not specPl.raceActive then time = formatTime(specPl.raceTimePrevious) end
    nvgText(timerFontX, timerFontY-100, time)
  end

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

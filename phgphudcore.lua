require "base/internal/ui/reflexcore"

-- DEBUG = true

PHGPHUD_TIMER_MAX = 5999999

--------------------
-- Util functions --
--------------------

function ColorA(color, alpha)
	return Color(color.r, color.g, color.b, alpha);
end

--------------------
--------------------

--------------------------
-- !! Customize HERE !! --
--------------------------

-- Sound files
PHGPHUD_TIMERSOUNDS_VOLUME = 2; -- Keep this below 8 plz :P

-- Sizes
PHGPHUD_BARS_HEIGHT = 65;
PHGPHUD_OUTLINE_THICKNESS = 1;
PHGPHUD_GAP_SIZE = 3;

-- Colors
PHGPHUD_BLUE_COLOR = Color(0, 85, 150, 255);
PHGPHUD_GREEN_COLOR = Color(25, 135, 0, 255);
PHGPHUD_YELLOW_COLOR = Color(195, 171, 0, 255);
PHGPHUD_RED_COLOR = Color(195, 0, 0, 255);
PHGPHUD_GOLD_COLOR = Color(169, 120, 0, 255);
PHGPHUD_LIGHTGOLD_COLOR = Color(212, 163, 0, 255);

PHGPHUD_GREY_COLOR = Color(25, 25, 25, 255);
PHGPHUD_LIGHTGREY_COLOR = Color(66, 66, 66, 255);
PHGPHUD_BLACK_COLOR = Color(0, 0, 0, 255);
PHGPHUD_WHITE_COLOR = Color(255, 255, 255, 255);

PHGPHUD_TEXT_COLOR = PHGPHUD_WHITE_COLOR;
PHGPHUD_OUTLINE_COLOR = PHGPHUD_BLUE_COLOR;
PHGPHUD_BAR_BACKGROUND_COLOR = PHGPHUD_GREY_COLOR;
PHGPHUD_BACKGROUND_COLOR = ColorA(PHGPHUD_BLACK_COLOR, 185);

-- Fonts
PHGPHUD_FONT_REGULAR = "SourceSansPro-Regular";
PHGPHUD_FONT_BOLD = "SourceSansPro-Bold";

--------------------------
--------------------------


--------------------
-- Misc functions --
--------------------

function drawTrapezoid(position, size, side)
  -- set vars
  ---- position
  local x = position.x or 0
  local y = position.y or 0
  ---- size
  local botW = size.bottomWidth or 200
  local topW = size.topWidth or 100
  local h = size.height or 50
  side = side or "full"

  -- helpers
  local topX = x+(botW-topW)/2

  -- Draw path
  nvgBeginPath()
  ---- Draw trapezoid
  nvgMoveTo(x, y)
  if side == "full" or side == "left" then
    nvgLineTo(topX, y-h)
  else nvgLineTo(x, y-h)
  end
  if side == "full" or side == "right" then
    nvgLineTo(topX+topW, y-h)
  else nvgLineTo(x+botW, y-h)
  end
  nvgLineTo(x+botW, y)
  nvgLineTo(x, y)
end

function formatTime(timeS)
  local t = {};

  local time = timeS

  t.seconds = math.floor(time/1000);
  t.minutes = math.floor(t.seconds / 60);
  t.seconds = t.seconds - t.minutes * 60;
  t.mili = math.floor((time - (t.seconds * 1000) - (t.minutes * 60 * 1000)))

  local mins = t.minutes
  if mins < 10 then mins = "0"..mins end
  local secs = t.seconds
  if secs < 10 then secs = "0"..secs end
  local milis = t.mili
  if t.mili < 100 then milis = "0"..milis end
  if t.mili < 10 then milis = "0"..milis end

  local fullText = mins .. ":" .. secs .. ":" .. milis
  return fullText;
end

function checkIfSame(player1, player2)
  return player1.name == player2.name
end

function shallowCopy(orig) -- http://lua-users.org/wiki/CopyTable
  local orig_type = type(orig)
  local copy

  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = orig_value
    end
  else -- number, string, boolean, etc
    copy = orig
  end

  return copy
end

--------------------
--------------------

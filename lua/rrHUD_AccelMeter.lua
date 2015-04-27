require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_AccelMeter =
  {
  };
registerWidget("rr_AccelMeter");

-------------------------------------------------------------------------
-- Vector2D Class --
-------------------------------------------------------------------------

local Vector2D = {}
Vector2D.__index = Vector2D

function Vector2D.new(x, y)
  local self = setmetatable({}, Vector2D)
  self.x = x or 0
  self.y = y or 0
  return self
end

function Vector2D:update(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function Vector2D:size()
  return math.sqrt(math.pow(self.x,2) + math.pow(self.y,2))
end

function Vector2D:dotProduct(vec2)
  assert(type(vec2) == "table", "vec2 must be a table")
  assert(type(vec2.x) ~= "nil", "vec2 must have an x value")
  assert(type(vec2.y) ~= "nil", "vec2 must have an y value")
  return (self.x*vec2.x)+(self.y*vec2.y)
end

function Vector2D:angle(vec2)
  assert(type(vec2) == "table", "vec2 must be a table")
  assert(type(vec2.x) ~= "nil", "vec2 must have an x value")
  assert(type(vec2.y) ~= "nil", "vec2 must have an y value")
  return math.acos(self:dotProduct(vec2)/(self:size()*vec2:size()))
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

local function posAngle(angle)
  angle = math.modf(angle, 360)
  if(angle < 0) then angle = angle + 360 end
  return angle
end

local accel, prevAng, timer, timer2, fps
local playerSpeed = Vector2D.new(0,0)
local deltaSpeed = Vector2D.new(0,0)
local playerAccel = Vector2D.new(0,0)
local radius = 100

function rr_AccelMeter:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  if prevAng == nil then prevAng = specPl.anglesDegrees.x end
  if timer == nil then timer = 0 end
  if timer2 == nil then timer2 = 0 end
  if fps == nil then fps = 120 end
  if accel == nil then accel = 0 end

  if timer2 >= 1/fps then
    timer2 = 0
    deltaSpeed:update(specPl.velocity.x - playerSpeed.x, specPl.velocity.z - playerSpeed.y)
    playerAccel:update(deltaSpeed.x/fps, deltaSpeed.y/fps)
    accel = playerAccel:size()
    if playerAccel.x < 0 and playerAccel.y < 0 then accel = accel * -1 end

    playerSpeed:update(specPl.velocity.x, specPl.velocity.z)
  end

  timer2 = timer2 + deltaTimeRaw

  -- Draw speed
  nvgFontSize(50);
  nvgFontFace(PHGPHUD_FONT_BOLD);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

  nvgFillColor(PHGPHUD_BLACK_COLOR);
  -- nvgText(0, 1, math.floor(accel))

  nvgFillColor(PHGPHUD_WHITE_COLOR);
  -- nvgText(0, 0, math.floor(accel))

  -- Draw angle

  local vec_x = Vector2D.new(1,0)
  local vec_nx = Vector2D.new(-1,0)

  local pl_ang = posAngle(specPl.anglesDegrees.x+90)
  local vel_ang
  if playerSpeed.y >= 0 then vel_ang = playerSpeed:angle(vec_nx)
  else vel_ang = math.pi + playerSpeed:angle(vec_x) end

  local min_ang = math.acos(320/playerSpeed:size())
  local opt_ang = math.acos((320-accel)/playerSpeed:size())
  local o = math.atan((accel*math.sqrt(math.pow(playerSpeed:size(), 2) - math.pow(320-accel, 2)))/(math.pow(playerSpeed:size(), 2) + accel*(320-accel)))
  local a = o/2+opt_ang
  local e = a-math.pi/4
  local t_ang_min = vel_ang
  local t_ang_op_m = vel_ang
  local t_ang_op = vel_ang

  if specPl.buttons.right then
    t_ang_op_m = t_ang_op + 1*e
    t_ang_op = t_ang_op + 1.2*e
  elseif specPl.buttons.left then
    t_ang_op_m = t_ang_op - 1*e
    t_ang_op = t_ang_op - 1.2*e
  end

  -- if specPl.anglesDegrees.x-prevAng > 0 then
  --   t_ang_op = t_ang_op + 1.2*e
  -- elseif specPl.anglesDegrees.x-prevAng < 0 then
  --   t_ang_op = t_ang_op - 1.2*e
  -- end

  if timer >= 1/10 then
    timer = 0
    prevAng = specPl.anglesDegrees.x
  end
  timer = timer + deltaTimeRaw

  local ang_diff_min = t_ang_min-math.rad(pl_ang)
  local ang_diff_op_m = t_ang_op_m-math.rad(pl_ang)
  local ang_diff_op = t_ang_op-math.rad(pl_ang)

  local lineSize = radius
  local dir = NVG_CW
  if ang_diff_min < ang_diff_op then dir = NVG_CW else dir = NVG_CCW end

  nvgBeginPath()
  nvgArc(0,0, lineSize, ang_diff_min-math.pi/2, ang_diff_op_m-math.pi/2, dir)
  nvgStrokeColor(ColorA(PHGPHUD_BLUE_COLOR, 120))
  nvgStrokeWidth(50)
  nvgStroke()

  nvgBeginPath()
  nvgArc(0,0, lineSize, ang_diff_op_m-math.pi/2, ang_diff_op-math.pi/2, dir)
  nvgStrokeColor(ColorA(PHGPHUD_GREEN_COLOR, 120))
  nvgStrokeWidth(50)
  nvgStroke()


  ----------------------
  -- Lines
  ----------------------
  nvgBeginPath()
  nvgMoveTo(0, 0)
  nvgLineTo(lineSize*math.cos(ang_diff_min-math.pi/2), lineSize*math.sin(ang_diff_min-math.pi/2))
  nvgStrokeWidth(3)
  nvgStrokeColor(PHGPHUD_YELLOW_COLOR)
  -- nvgStroke()

  nvgBeginPath()
  nvgMoveTo(0, 0)
  nvgLineTo(lineSize*math.cos(ang_diff_op-math.pi/2), lineSize*math.sin(ang_diff_op-math.pi/2))
  nvgStrokeWidth(3)
  nvgStrokeColor(PHGPHUD_BLUE_COLOR)
  -- nvgStroke()

  ----------------------
  ----------------------

  nvgFontSize(50);
  nvgFontFace(PHGPHUD_FONT_BOLD);
  nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE);

  nvgFillColor(PHGPHUD_WHITE_COLOR);
  -- nvgText(0, 100, pl_ang .. " | " .. math.floor(math.deg(vel_ang)))

end

function rr_AccelMeter:settings()
  consolePerformCommand("ui_show_widget rr_AccelMeter")
  consolePerformCommand("ui_set_widget_anchor rr_AccelMeter 0 0")
  consolePerformCommand("ui_set_widget_offset rr_AccelMeter 0 " .. radius)
  consolePerformCommand("ui_set_widget_scale rr_AccelMeter 1")
end

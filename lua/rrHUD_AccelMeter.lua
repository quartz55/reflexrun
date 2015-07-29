require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_AccelMeter =
  {
    canPosition = false; -- hide default widget sliders

    userData = {};
  };
registerWidget("rr_AccelMeter");

function rr_AccelMeter:initialize()
  self.userData = loadUserData();

  CheckSetDefaultValue(self, "userData", "table", {});

  CheckSetDefaultValue(self.userData, "drawAccelCircle", "boolean", true);
  CheckSetDefaultValue(self.userData, "drawAccelLine", "boolean", false);
  CheckSetDefaultValue(self.userData, "drawBlueLine", "boolean", true);

  CheckSetDefaultValue(self.userData, "guideCircle", "boolean", false);
  CheckSetDefaultValue(self.userData, "guideLine", "boolean", false);
  CheckSetDefaultValue(self.userData, "blueWidthC", "number", 50);
  CheckSetDefaultValue(self.userData, "greenWidthC", "number", 50);
  CheckSetDefaultValue(self.userData, "radiusC", "number", 100);
  CheckSetDefaultValue(self.userData, "lineScaleC", "number", 1);
  CheckSetDefaultValue(self.userData, "offsetC", "number", 100);

  CheckSetDefaultValue(self.userData, "blueWidthL", "number", 35);
  CheckSetDefaultValue(self.userData, "greenWidthL", "number", 35);
  CheckSetDefaultValue(self.userData, "lineScaleL", "number", 3);
  CheckSetDefaultValue(self.userData, "offsetL", "number", 0);
end

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
  -- angle = math.modf(angle, 360) -- this causes bad jitter
  if(angle < 0) then angle = angle + 360 end
  return angle
end

local accel, prevAng, timer, timer2
local playerSpeed = Vector2D.new(0,0)
local deltaSpeed = Vector2D.new(0,0)
local playerAccel = Vector2D.new(0,0)

function rr_AccelMeter:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local drawAccelCircle = self.userData.drawAccelCircle
  local drawAccelLine = self.userData.drawAccelLine
  local drawBlueLine = self.userData.drawBlueLine
  local guideCircle = self.userData.guideCircle
  local guideLine = self.userData.guideLine
  local blueWidthC = self.userData.blueWidthC
  local greenWidthC = self.userData.greenWidthC
  local radiusC = self.userData.radiusC
  local lineScaleC = self.userData.lineScaleC
  local offsetC = self.userData.offsetC
  local blueWidthL = self.userData.blueWidthL
  local greenWidthL = self.userData.greenWidthL
  local lineScaleL = self.userData.lineScaleL
  local offsetL = self.userData.offsetL

  local fps = consoleGetVariable("com_maxfps")
  if fps == 0 then fps = 1000 end -- for players who set unlimited fps, we want to avoid a divide by zero
  if fps < 125 then fps = 125 end -- any lower than this and the accelmeter jitters, so players who set a low maxfps can still have it nice looking

  if prevAng == nil then prevAng = specPl.anglesDegrees.x end
  if timer == nil then timer = 0 end
  if timer2 == nil then timer2 = 0 end
  -- if fps == nil then fps = 120 end
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

  if specPl.buttons.back then  -- Backwards strafe jumping
    vel_ang = -vel_ang
    pl_ang = -pl_ang + 180
  end

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

  local lineSize = radiusC
  local dir = NVG_CW
  if ang_diff_min < ang_diff_op then dir = NVG_CW else dir = NVG_CCW end

  local cgazB1 = (radiusC * math.cos(ang_diff_min-math.pi/2)) * lineScaleL
  local cgazB2 = (radiusC * math.cos(ang_diff_op-math.pi/2)) * lineScaleL
  local cgazG1 = (radiusC * math.cos(ang_diff_op_m-math.pi/2)) * lineScaleL
  local cgazG2 = (radiusC * math.cos(ang_diff_op-math.pi/2)) * lineScaleL

  ang_diff_min = ang_diff_min * lineScaleC
  ang_diff_op_m = ang_diff_op_m * lineScaleC
  ang_diff_op = ang_diff_op * lineScaleC

  if specPl.buttons.forward or specPl.buttons.back then
    if drawAccelCircle then
      nvgBeginPath()
      nvgArc(0, offsetC, radiusC, ang_diff_min-math.pi/2, ang_diff_op-math.pi/2, dir)
      nvgStrokeColor(ColorA(PHGPHUD_BLUE_COLOR, 120))
      nvgStrokeWidth(blueWidthC)
      if drawBlueLine then nvgStroke() end

      nvgBeginPath()
      nvgArc(0, offsetC, radiusC, ang_diff_op_m-math.pi/2, ang_diff_op-math.pi/2, dir)
      nvgStrokeColor(ColorA(PHGPHUD_GREEN_COLOR, 120))
      nvgStrokeWidth(greenWidthC)
      nvgStroke()
    end

    if drawAccelLine then
      nvgBeginPath()
      nvgMoveTo(cgazB1, offsetL)
      nvgLineTo(cgazB2, offsetL)
      nvgStrokeColor(ColorA(PHGPHUD_BLUE_COLOR, 120))
      nvgStrokeWidth(blueWidthL)
      if drawBlueLine then nvgStroke() end

      nvgBeginPath()
      nvgMoveTo(cgazG1, offsetL)
      nvgLineTo(cgazG2, offsetL)
      nvgStrokeColor(ColorA(PHGPHUD_GREEN_COLOR, 120))
      nvgStrokeWidth(greenWidthL)
      nvgStroke()
    end
  end

  -- Guide Circle
  if guideCircle and drawAccelCircle then
    nvgBeginPath()
    nvgCircle(0, offsetC, radiusC + blueWidthC/2 + 3)
    nvgStrokeColor(ColorA(PHGPHUD_BLUE_COLOR, 80))
    nvgStrokeWidth(6)
    nvgStroke()
  end

  -- Guide Line
  if guideLine and drawAccelCircle then
    nvgBeginPath()
    nvgStrokeColor(ColorA(PHGPHUD_RED_COLOR, 120))
    nvgStrokeWidth(6)
    nvgMoveTo(0, offsetC + -radiusC - blueWidthC/2 - 8)
    nvgLineTo(0, offsetC + -radiusC - blueWidthC/2 + 12)
    nvgStroke()
  end

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

function rr_AccelMeter:drawOptions(x, y)
  local sliderWidth = 200;
  local sliderStart = 140;

  local user = self.userData;

  if uiButton("Reset Settings", nil, x + 250, y - 35, 150, UI_DEFAULT_BUTTON_HEIGHT, PHGPHUD_RED_COLOR) then
    user.drawAccelCircle = true;
    user.drawAccelLine = false;
    user.drawBlueLine = true;

    user.guideCircle = false;
    user.guideLine = false;

    user.blueWidthC = 50;
    user.greenWidthC = 50;
    user.radiusC = 100;
    user.lineScaleC = 1;
    user.offsetC = 100;

    user.blueWidthL = 35;
    user.greenWidthL = 35;
    user.lineScaleL = 3;
    user.offsetL = 0;
  end

  uiLabel("DRAW ACCELMETER AS", x + 10, y);
  y = y + 35;

  user.drawAccelCircle = uiCheckBox(user.drawAccelCircle, "Circle", x, y);
  user.drawAccelLine = uiCheckBox(user.drawAccelLine, "Line", x + 100, y);
  user.drawBlueLine = uiCheckBox(user.drawBlueLine, "With Blue Area", x + 220, y);
  y = y + 50;

  uiLabel("SETTINGS FOR CIRCULAR ACCELMETER", x + 10, y);
  y = y + 35;

  user.guideCircle = uiCheckBox(user.guideCircle, "Guide Circle", x, y);
  user.guideLine = uiCheckBox(user.guideLine, "Guide Line", x + 160, y);
  y = y + 40;

  uiLabel("Blue Width", x, y);
  user.blueWidthC = round(uiSlider(x + sliderStart, y, sliderWidth, 10, 200, user.blueWidthC));
  user.blueWidthC = round(uiEditBox(user.blueWidthC, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  uiLabel("Green Width", x, y);
  user.greenWidthC = round(uiSlider(x + sliderStart, y, sliderWidth, 10, 200, user.greenWidthC));
  user.greenWidthC = round(uiEditBox(user.greenWidthC, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  uiLabel("Radius", x, y);
  user.radiusC = round(uiSlider(x + sliderStart, y, sliderWidth, 1, 500, user.radiusC));
  user.radiusC = round(uiEditBox(user.radiusC, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  uiLabel("Scale", x, y);
  user.lineScaleC = round(uiSlider(x + sliderStart, y, sliderWidth, 1, 12, user.lineScaleC));
  user.lineScaleC = round(uiEditBox(user.lineScaleC, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  uiLabel("Offset", x, y);
  user.offsetC = round(uiSlider(x + sliderStart, y, sliderWidth, -500, 500, user.offsetC));
  user.offsetC = round(uiEditBox(user.offsetC, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 50;

  uiLabel("SETTINGS FOR LINE ACCELMETER", x + 10, y);
  y = y + 35;

  uiLabel("Blue Width", x, y);
  user.blueWidthL = round(uiSlider(x + sliderStart, y, sliderWidth, 10, 200, user.blueWidthL));
  user.blueWidthL = round(uiEditBox(user.blueWidthL, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  uiLabel("Green Width", x, y);
  user.greenWidthL = round(uiSlider(x + sliderStart, y, sliderWidth, 10, 200, user.greenWidthL));
  user.greenWidthL = round(uiEditBox(user.greenWidthL, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  uiLabel("Scale", x, y);
  user.lineScaleL = round(uiSlider(x + sliderStart, y, sliderWidth, 1, 20, user.lineScaleL));
  user.lineScaleL = round(uiEditBox(user.lineScaleL, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  uiLabel("Offset", x, y);
  user.offsetL = round(uiSlider(x + sliderStart, y, sliderWidth, -500, 500, user.offsetL));
  user.offsetL = round(uiEditBox(user.offsetL, x + sliderStart + sliderWidth + 10, y, 60));
  y = y + 40;

  saveUserData(user);
end

function rr_AccelMeter:settings()
  consolePerformCommand("ui_show_widget rr_AccelMeter")
  consolePerformCommand("ui_set_widget_anchor rr_AccelMeter 0 0")
  consolePerformCommand("ui_set_widget_offset rr_AccelMeter 0 0")
  consolePerformCommand("ui_set_widget_scale rr_AccelMeter 1")
end

require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_AccelMeter =
  {
    canPosition = false; -- hide default widget sliders

    userData = {};
    defaultData = {
      drawAccelCircle = true;
      drawAccelLine = false;
      latencyWorkaround = false;
      guideCircle = false;
      guideLine = false;
      invertC = false;
      blueWidthC = 50;
      greenWidthC = 50;
      widthLockC = true;
      radiusC = 100;
      lineScaleC = 1;
      offsetC = 100;
      blueWidthL = 35;
      greenWidthL = 35;
      widthLockL = true;
      lineScaleL = 3;
      offsetL = 0;
      cBlue1 = shallowCopy(ColorA(PHGPHUD_BLUE_COLOR, 120));
      cBlue2 = shallowCopy(ColorA(PHGPHUD_BLUE_COLOR, 120));
      cGreen1 = shallowCopy(ColorA(PHGPHUD_GREEN_COLOR, 120));
      cGreen2 = shallowCopy(ColorA(PHGPHUD_GREEN_COLOR, 120));
    };
  };
registerWidget("rr_AccelMeter");

function rr_AccelMeter:initialize()
  self.userData = loadUserData();

  CheckSetDefaultValue(self, "userData", "table", {});

  CheckSetDefaultValue(self.userData, "drawAccelCircle", "boolean", self.defaultData.drawAccelCircle);
  CheckSetDefaultValue(self.userData, "drawAccelLine", "boolean", self.defaultData.drawAccelLine);
  CheckSetDefaultValue(self.userData, "latencyWorkaround", "boolean", self.defaultData.latencyWorkaround);

  CheckSetDefaultValue(self.userData, "guideCircle", "boolean", self.defaultData.guideCircle);
  CheckSetDefaultValue(self.userData, "guideLine", "boolean", self.defaultData.guideLine);
  CheckSetDefaultValue(self.userData, "invertC", "boolean", self.defaultData.invertC);
  
  CheckSetDefaultValue(self.userData, "blueWidthC", "number", self.defaultData.blueWidthC);
  CheckSetDefaultValue(self.userData, "greenWidthC", "number", self.defaultData.greenWidthC);
  CheckSetDefaultValue(self.userData, "widthLockC", "boolean", self.defaultData.widthLockC);
  CheckSetDefaultValue(self.userData, "radiusC", "number", self.defaultData.radiusC);
  CheckSetDefaultValue(self.userData, "lineScaleC", "number", self.defaultData.lineScaleC);
  CheckSetDefaultValue(self.userData, "offsetC", "number", self.defaultData.offsetC);

  CheckSetDefaultValue(self.userData, "blueWidthL", "number", self.defaultData.blueWidthL);
  CheckSetDefaultValue(self.userData, "greenWidthL", "number", self.defaultData.greenWidthL);
  CheckSetDefaultValue(self.userData, "widthLockL", "boolean", self.defaultData.widthLockL);
  CheckSetDefaultValue(self.userData, "lineScaleL", "number", self.defaultData.lineScaleL);
  CheckSetDefaultValue(self.userData, "offsetL", "number", self.defaultData.offsetL);

  CheckSetDefaultValue(self.userData, "cBlue1", "table", shallowCopy(self.defaultData.cBlue1));
  CheckSetDefaultValue(self.userData, "cBlue2", "table", shallowCopy(self.defaultData.cBlue2));
  CheckSetDefaultValue(self.userData, "cGreen1", "table", shallowCopy(self.defaultData.cGreen1));
  CheckSetDefaultValue(self.userData, "cGreen2", "table", shallowCopy(self.defaultData.cGreen2));

  -- needed for ColorPicker widget popup
  widgetCreateConsoleVariable("cBlue1", "string", argbToHex(self.defaultData.cBlue1));
  widgetCreateConsoleVariable("cBlue2", "string", argbToHex(self.defaultData.cBlue2));
  widgetCreateConsoleVariable("cGreen1", "string", argbToHex(self.defaultData.cGreen1));
  widgetCreateConsoleVariable("cGreen2", "string", argbToHex(self.defaultData.cGreen2));
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

function rr_AccelMeter:drawAC(ang_diff_min, ang_diff_op, ang_diff_op_m, dir)
  local colourB_X1 = self.userData.radiusC * math.cos(ang_diff_min-math.pi/2)
  local colourB_X2 = self.userData.radiusC * math.cos(ang_diff_op-math.pi/2)
  local colourB_Y1 = self.userData.radiusC * math.sin(ang_diff_min-math.pi/2) + self.userData.offsetC
  local colourB_Y2 = self.userData.radiusC * math.sin(ang_diff_op-math.pi/2) + self.userData.offsetC
  local colourG_X1 = self.userData.radiusC * math.cos(ang_diff_op_m-math.pi/2)
  local colourG_X2 = self.userData.radiusC * math.cos(ang_diff_op-math.pi/2)
  local colourG_Y1 = self.userData.radiusC * math.sin(ang_diff_op_m-math.pi/2) + self.userData.offsetC
  local colourG_Y2 = self.userData.radiusC * math.sin(ang_diff_op-math.pi/2) + self.userData.offsetC

  if self.userData.drawAccelCircle then
    nvgBeginPath()
    nvgArc(0, self.userData.offsetC, self.userData.radiusC, ang_diff_min-math.pi/2, ang_diff_op-math.pi/2, dir)
    nvgStrokeLinearGradient(colourB_X1, colourB_Y1, colourB_X2, colourB_Y2, self.userData.cBlue2, self.userData.cBlue1)
    nvgStrokeWidth(self.userData.blueWidthC)
    nvgStroke()

    nvgBeginPath()
    nvgArc(0, self.userData.offsetC, self.userData.radiusC, ang_diff_op_m-math.pi/2, ang_diff_op-math.pi/2, dir)
    nvgStrokeLinearGradient(colourG_X1, colourG_Y1, colourG_X2, colourG_Y2, self.userData.cGreen2, self.userData.cGreen1)
    nvgStrokeWidth(self.userData.greenWidthC)
    nvgStroke()
  end
end

function rr_AccelMeter:drawAL(cgazB1, cgazB2, cgazG1, cgazG2)
  if self.userData.drawAccelLine then
    nvgBeginPath()
    nvgMoveTo(cgazB1, self.userData.offsetL)
    nvgLineTo(cgazB2, self.userData.offsetL)
    nvgStrokeLinearGradient(cgazB1, 0, cgazB2, 0, self.userData.cBlue2, self.userData.cBlue1)
    nvgStrokeWidth(self.userData.blueWidthL)
    nvgStroke()

    nvgBeginPath()
    nvgMoveTo(cgazG1, self.userData.offsetL)
    nvgLineTo(cgazG2, self.userData.offsetL)
    nvgStrokeLinearGradient(cgazG1, 0, cgazG2, 0, self.userData.cGreen2, self.userData.cGreen1)
    nvgStrokeWidth(self.userData.greenWidthL)
    nvgStroke()
  end
end

function rr_AccelMeter:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local drawAccelCircle = self.userData.drawAccelCircle
  local latencyWorkaround = self.userData.latencyWorkaround
  local guideCircle = self.userData.guideCircle
  local guideLine = self.userData.guideLine
  local invertC = self.userData.invertC
  local blueWidthC = self.userData.blueWidthC
  local greenWidthC = self.userData.greenWidthC
  local radiusC = self.userData.radiusC
  local lineScaleC = self.userData.lineScaleC
  local offsetC = self.userData.offsetC
  local lineScaleL = self.userData.lineScaleL

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

  if (not latencyWorkaround) and specPl.buttons.back then -- Backwards strafe jumping
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

  if latencyWorkaround then
    if (specPl.anglesDegrees.x - prevAng) > 0 then
      t_ang_op_m = t_ang_op + 1*e
      t_ang_op = t_ang_op + 1.2*e
    elseif (specPl.anglesDegrees.x - prevAng) < 0 then
      t_ang_op_m = t_ang_op - 1*e
      t_ang_op = t_ang_op - 1.2*e
    end
  else
    if specPl.buttons.right then
      t_ang_op_m = t_ang_op + 1*e
      t_ang_op = t_ang_op + 1.2*e
    elseif specPl.buttons.left then
      t_ang_op_m = t_ang_op - 1*e
      t_ang_op = t_ang_op - 1.2*e
    end
  end

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

  local cgazB1 = (self.defaultData.radiusC * math.cos(ang_diff_min-math.pi/2)) * lineScaleL
  local cgazB2 = (self.defaultData.radiusC * math.cos(ang_diff_op-math.pi/2)) * lineScaleL
  local cgazG1 = (self.defaultData.radiusC * math.cos(ang_diff_op_m-math.pi/2)) * lineScaleL
  local cgazG2 = (self.defaultData.radiusC * math.cos(ang_diff_op-math.pi/2)) * lineScaleL

  local guideCircleWidth = 6
  local guideLineWidth = 4

  ang_diff_min = ang_diff_min * lineScaleC
  ang_diff_op_m = ang_diff_op_m * lineScaleC
  ang_diff_op = ang_diff_op * lineScaleC

  if invertC then
    if dir == NVG_CW then dir = NVG_CCW
    else dir = NVG_CW end

    ang_diff_min = -ang_diff_min + math.rad(180)
    ang_diff_op_m = -ang_diff_op_m + math.rad(180)
    ang_diff_op = -ang_diff_op + math.rad(180)
  end

  if latencyWorkaround and specPl.buttons.back then -- Backwards strafe jumping (high ping fix)
    if dir == NVG_CW then dir = NVG_CCW
    else dir = NVG_CW end

    ang_diff_min = -ang_diff_min
    ang_diff_op_m = -ang_diff_op_m
    ang_diff_op = -ang_diff_op
  end

  -- Draw Accelmeter
  if latencyWorkaround then
    self:drawAC(ang_diff_min, ang_diff_op, ang_diff_op_m, dir)
    self:drawAL(cgazB1, cgazB2, cgazG1, cgazG2)
  elseif specPl.buttons.forward or specPl.buttons.back then
    self:drawAC(ang_diff_min, ang_diff_op, ang_diff_op_m, dir)
    self:drawAL(cgazB1, cgazB2, cgazG1, cgazG2)
  end

  -- Guide Circle
  if guideCircle and drawAccelCircle then
    nvgBeginPath()
    if invertC then
      nvgStrokeLinearGradient(0, (radiusC + blueWidthC/2 + guideCircleWidth/2 + offsetC), 0, (radiusC/1.33 + blueWidthC/2 + guideCircleWidth/2 + offsetC), ColorA(PHGPHUD_BLUE_COLOR, 120), ColorA(PHGPHUD_BLUE_COLOR, 0))
    else
      nvgStrokeLinearGradient(0, -(radiusC + blueWidthC/2 + guideCircleWidth/2 - offsetC), 0, -(radiusC/1.33 + blueWidthC/2 + guideCircleWidth/2 - offsetC), ColorA(PHGPHUD_BLUE_COLOR, 120), ColorA(PHGPHUD_BLUE_COLOR, 0))
    end
    nvgStrokeWidth(guideCircleWidth)
    nvgCircle(0, offsetC, radiusC + blueWidthC/2 + guideCircleWidth/2)
    nvgStroke()
  end

  -- Guide Line
  if guideLine and drawAccelCircle then
    nvgBeginPath()
    nvgStrokeColor(ColorA(PHGPHUD_RED_COLOR, 190))
    nvgStrokeWidth(guideLineWidth)
    if invertC then
      nvgMoveTo(0, offsetC + radiusC - greenWidthC/2)
      nvgLineTo(0, offsetC + radiusC - greenWidthC/6)

      nvgMoveTo(0, offsetC + radiusC - greenWidthC/16)
      nvgLineTo(0, offsetC + radiusC + greenWidthC/16)

      nvgMoveTo(0, offsetC + radiusC + greenWidthC/2)
      nvgLineTo(0, offsetC + radiusC + greenWidthC/6)
    else
      nvgMoveTo(0, offsetC + -radiusC - greenWidthC/2)
      nvgLineTo(0, offsetC + -radiusC - greenWidthC/6)

      nvgMoveTo(0, offsetC + -radiusC - greenWidthC/16)
      nvgLineTo(0, offsetC + -radiusC + greenWidthC/16)

      nvgMoveTo(0, offsetC + -radiusC + greenWidthC/2)
      nvgLineTo(0, offsetC + -radiusC + greenWidthC/6)
    end

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
  local colIndent = 200;
  local sliderWidth = 480;
  local sliderStart = 140;
  local editBoxWidth = 70;
  local optargs = {};

  if ui2Button("RESET ALL SETTINGS", x, y + 210, 220, UI_DEFAULT_BUTTON_HEIGHT) then
    self.userData = {};
    self.userData = deepCopy(self.defaultData);

    consolePerformCommand("ui_rr_accelmeter_cBlue1 " .. argbToHex(self.defaultData.cBlue1));
    consolePerformCommand("ui_rr_accelmeter_cBlue2 " .. argbToHex(self.defaultData.cBlue2));
    consolePerformCommand("ui_rr_accelmeter_cGreen1 " .. argbToHex(self.defaultData.cGreen1));
    consolePerformCommand("ui_rr_accelmeter_cGreen2 " .. argbToHex(self.defaultData.cGreen2));
  end

  local user = self.userData;

  ui2Label("DRAW ACCELMETER AS", x + 10, y);
  y = y + 50;

  ui2Label("Circle", x, y);
  user.drawAccelCircle = ui2CheckBox(user.drawAccelCircle, x + colIndent, y);
  y = y + 50;
  ui2Label("Line", x, y);
  user.drawAccelLine = ui2CheckBox(user.drawAccelLine, x + colIndent, y);
  y = y + 50;
  ui2Label("High Ping Fix", x, y);
  user.latencyWorkaround = ui2CheckBox(user.latencyWorkaround, x + colIndent, y);
  y = y + 140;

  ui2Label("SETTINGS FOR CIRCULAR ACCELMETER", x + 10, y);
  y = y + 50;

  ui2Label("Guide Arc", x, y);
  user.guideCircle = ui2CheckBox(user.guideCircle, x + colIndent, y);
  y = y + 50;
  ui2Label("Guide Line", x, y);
  user.guideLine = ui2CheckBox(user.guideLine, x + colIndent, y);
  y = y + 50;
  ui2Label("Invert", x, y);
  user.invertC = ui2CheckBox(user.invertC, x + colIndent, y);
  y = y + 50;

  user.widthLockC = ui2CheckBox(user.widthLockC, x + 500, y + 25);
  if user.widthLockC then
    -- lock the values together
    user.blueWidthC = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Blue Width", user.blueWidthC, 10, 200);
    user.greenWidthC = user.blueWidthC;
    y = y + 50;
    user.greenWidthC = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Green Width", user.greenWidthC, 10, 200);
    user.blueWidthC = user.greenWidthC;
    y = y + 50;
  else
    user.blueWidthC = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Blue Width", user.blueWidthC, 10, 200);
    y = y + 50;
    user.greenWidthC = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Green Width", user.greenWidthC, 10, 200);
    y = y + 50;
  end
  user.radiusC = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Radius", user.radiusC, 1, 1000);
  y = y + 50;
  user.lineScaleC = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Scale", user.lineScaleC, 1, 12);
  y = y + 50;
  user.offsetC = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Offset", user.offsetC, -2000, 2000);
  y = y + 70;

  ui2Label("SETTINGS FOR LINE ACCELMETER", x + 10, y);
  y = y + 50;

  user.widthLockL = ui2CheckBox(user.widthLockL, x + 500, y + 25);
  if user.widthLockL then
    -- lock the values together
    user.blueWidthL = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Blue Width", user.blueWidthL, 10, 200);
    user.greenWidthL = user.blueWidthL;
    y = y + 50;
    user.greenWidthL = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Green Width", user.greenWidthL, 10, 200);
    user.blueWidthL = user.greenWidthL;
    y = y + 50;
  else
    user.blueWidthL = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Blue Width", user.blueWidthL, 10, 200);
    y = y + 50;
    user.greenWidthL = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Green Width", user.greenWidthL, 10, 200);
    y = y + 50;
  end
  user.lineScaleL = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Scale", user.lineScaleL, 1, 20);
  y = y + 50;
  user.offsetL = ui2RowSliderEditBox0Decimals(x, y, sliderStart, sliderWidth, editBoxWidth, "Offset", user.offsetL, -500, 500);
  y = y + 70;

  ui2Label("COLOUR SETTINGS", x + 10, y);
  y = y + 45;

  optargs.texttype = "color";
  optargs.bgcoltype = UI2_COLTYPE_BUTTON_BLACK;

  if ui2Button("RESET COLOUR", x, y + 360, 180, UI_DEFAULT_BUTTON_HEIGHT) then
    user.cBlue1 = shallowCopy(self.defaultData.cBlue1);
    user.cBlue2 = shallowCopy(self.defaultData.cBlue2);
    user.cGreen1 = shallowCopy(self.defaultData.cGreen1);
    user.cGreen2 = shallowCopy(self.defaultData.cGreen2);

    consolePerformCommand("ui_rr_accelmeter_cBlue1 " .. argbToHex(self.defaultData.cBlue1));
    consolePerformCommand("ui_rr_accelmeter_cBlue2 " .. argbToHex(self.defaultData.cBlue2));
    consolePerformCommand("ui_rr_accelmeter_cGreen1 " .. argbToHex(self.defaultData.cGreen1));
    consolePerformCommand("ui_rr_accelmeter_cGreen2 " .. argbToHex(self.defaultData.cGreen2));
  end

  ui2Label("Blue", x + 20, y + 55);
  ui2Label("Inside", x + 110, y);
  ui2Label("Outside", x + 245, y);
  y = y + 40;

  -- draw a neat box around the colour buttons
  nvgBeginPath();
  nvgStrokeColor(UI2_COLTYPE_TEXT_GREY.base);
  nvgStrokeWidth(4);
  nvgRoundedRect(x + 5, y, 370, 70, 5);
  nvgStroke();

  if ui2Button(user.cBlue1, x + 90, y + 10, 120, 50, optargs) then
    showAsPopup("ColorPicker", argbToHex(user.cBlue1), "", "ui_rr_accelmeter_cBlue1 %s");
  end
  if ui2Button(user.cBlue2, x + 230, y + 10, 120, 50, optargs) then
    showAsPopup("ColorPicker", argbToHex(user.cBlue2), "", "ui_rr_accelmeter_cBlue2 %s");
  end
  y = y + 40;

  ui2Label("Green", x + 20, y + 55);
  y = y + 40;

  -- draw a neat box around the colour buttons
  nvgBeginPath();
  nvgStrokeColor(UI2_COLTYPE_TEXT_GREY.base);
  nvgStrokeWidth(4);
  nvgRoundedRect(x + 5, y, 370, 70, 5);
  nvgStroke();

  if ui2Button(user.cGreen2, x + 90, y + 10, 120, 50, optargs) then
    showAsPopup("ColorPicker", argbToHex(user.cGreen2), "", "ui_rr_accelmeter_cGreen2 %s");
  end
  if ui2Button(user.cGreen1, x + 230, y + 10, 120, 50, optargs) then
    showAsPopup("ColorPicker", argbToHex(user.cGreen1), "", "ui_rr_accelmeter_cGreen1 %s");
  end
  y = y + 90;

  user.cBlue1 = hexArgbToCol(consoleGetVariable("ui_rr_accelmeter_cBlue1"));
  user.cBlue2 = hexArgbToCol(consoleGetVariable("ui_rr_accelmeter_cBlue2"));
  user.cGreen1 = hexArgbToCol(consoleGetVariable("ui_rr_accelmeter_cGreen1"));
  user.cGreen2 = hexArgbToCol(consoleGetVariable("ui_rr_accelmeter_cGreen2"));

  ui2Label("Preview", x + 110, y);
  y = y + 80;
  nvgBeginPath()
  nvgMoveTo(x + 50, y);
  nvgLineTo(x + 350, y);
  nvgStrokeLinearGradient(x + 50, 0, x + 350, 0, user.cBlue2, user.cBlue1);
  nvgStrokeWidth(80);
  nvgStroke();

  nvgBeginPath();
  nvgMoveTo(x + 350, y);
  nvgLineTo(x + 450, y);
  nvgStrokeLinearGradient(x + 350, 0, x + 450, 0, user.cGreen2, user.cGreen1);
  nvgStrokeWidth(80);
  nvgStroke();

  saveUserData(user);
end

function rr_AccelMeter:getOptionsHeight()
	return 1500; -- debug with: ui_optionsmenu_show_properties_height 1
end

function rr_AccelMeter:settings()
  consolePerformCommand("ui_show_widget rr_AccelMeter")
  consolePerformCommand("ui_set_widget_anchor rr_AccelMeter 0 0")
  consolePerformCommand("ui_set_widget_offset rr_AccelMeter 0 0")
  consolePerformCommand("ui_set_widget_scale rr_AccelMeter 1")
end

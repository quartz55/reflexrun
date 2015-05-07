require "base/internal/ui/reflexrunHUD/phgphudcore"

rr_Tutorial =
  {
  };

registerWidget("rr_Tutorial");

local rectY = -180
local rectH = 380
-------------------------------------------------------------------------
-------------------------------------------------------------------------
function rr_Tutorial:draw()

  if not shouldShowHUD() then return end

  local localPl = getLocalPlayer()
  local specPl = getPlayer()

  local tutorialSVG = "internal/ui/reflexrunHUD/icons/Reflexruntutorial";
  local svgX = 0
  local svgY = 0

  local logoIcon = "internal/ui/reflexrunHUD/icons/reflexrun";

  if showScores then

    nvgBeginPath()
    nvgRect(-400, rectY, 800, rectH)
    nvgFillColor(ColorA(PHGPHUD_BLACK_COLOR, 135))
    nvgFill()

    nvgFillColor(PHGPHUD_WHITE_COLOR)
    nvgSvg(logoIcon, 0, -50, 300)

    nvgFontSize(22)
    nvgFontFace(PHGPHUD_FONT_BOLD)
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE)
    nvgFillColor(PHGPHUD_WHITE_COLOR)
    nvgText(0, 0, "Version 1.0")
    nvgText(0, 22, "created by quartz and zEv")

    nvgFontSize(20)
    nvgFontFace(PHGPHUD_FONT_REGULAR)
    nvgTextAlign(NVG_ALIGN_CENTER, NVG_ALIGN_MIDDLE)
    nvgFillColor(PHGPHUD_WHITE_COLOR)
    nvgText(0, 100,
            "Maps made for Reflexrun are labeled with \"RR\" - All maps are on PHGP.TV Reflexrun / Movement server.")
    nvgText(0, 120,
            "Check www.phgp.tv for more information, tutorials and updates!")
  end
end

function rr_Tutorial:settings()
  consolePerformCommand("ui_show_widget rr_Tutorial")
  consolePerformCommand("ui_set_widget_anchor rr_Tutorial 0 1")
  consolePerformCommand("ui_set_widget_offset rr_Tutorial 0 " .. -PHGPHUD_BARS_HEIGHT-rectY-rectH-20)
  consolePerformCommand("ui_set_widget_scale rr_Tutorial 1")
end

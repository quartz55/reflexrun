-------------------------------------------------------------------------
-- Map Triggers
-------------------------------------------------------------------------

local mapTriggers =
  {
    ["RRreflexjump"] =
      {
        ["begin"] =
          {
            x1 = 115;
            y1 = 0;
            z1 = -496;
            x2 = 271;
            y2 = 47;
            z2 = -125;
          };
        ["end"] =
          {
            x1 = 3450;
            y1 = 1344;
            z1 = -1400;
            x2 = 3627;
            y2 = 1390;
            z2 = -1200;
          };
      };
    ["RRbldf1"] =
      {
        ["begin"] =
          {
            x1 = 5;
            y1 = 128;
            z1 = -130;
            x2 = 255;
            y2 = 175;
            z2 = 290;
          };
        ["end"] =
          {
            x1 = 1130;
            y1 = 640;
            z1 = 430;
            x2 = 1450;
            y2 = 690;
            z2 = 830;
          };
      };
    ["RRbldf2"] =
      {
        ["begin"] =
          {
            x1 = -480;
            y1 = -100;
            z1 = 2658;
            x2 = -120;
            y2 = -40;
            z2 = 2880;
          };
        ["end"] =
          {
            x1 = -996;
            y1 = 560;
            z1 = 1983;
            x2 = -730;
            y2 = 606;
            z2 = 2176;
          };
      };
    ["RRbldf3"] =
      {
        ["begin"] =
          {
            x1 = -68;
            y1 = 60;
            z1 = -200;
            x2 = 68;
            y2 = 120;
            z2 = -59;
          };
        ["end"] =
          {
            x1 = 2677;
            y1 = 576;
            z1 = 132;
            x2 = 2944;
            y2 = 630;
            z2 = -391;
          };
      };
    ["rrEnvTank"] =
      {
        ["begin"] =
          {
            x1 = 256;
            y1 = 0;
            z1 = 47;
            x2 = 192;
            y2 = 50;
            z2 = -112;
          };
        ["end"] =
          {
            x1 = 446;
            y1 = 0;
            z1 = 144;
            x2 = 511;
            y2 = 50;
            z2 = 239;
          };
      };
    ["RRollierun"] =
      {
        ["begin"] =
          {
            x1 = -112;
            y1 = 0;
            z1 = -240;
            x2 = 223;
            y2 = 50;
            z2 = 240;
          };
        ["end"] =
          {
            x1 = -203;
            y1 = 0;
            z1 = 240;
            x2 = -455;
            y2 = 50;
            z2 = -240;
          };
      };
    ["RRperflexia_dfrag"] =
      {
        ["begin"] =
          {
            x1 = -240;
            y1 = 0;
            z1 = -704;
            x2 = 40;
            y2 = 50;
            z2 = -276;
          };
        ["end"] =
          {
            x1 = -3000;
            y1 = -465;
            z1 = 3088;
            x2 = -3417;
            y2 = -420;
            z2 = 2737;
          };
      };
  };

local function inBetween(val, a, b)
  local min = math.min(a,b)
  local max = math.max(a,b)
  return (val >= min and val <= max)
end

function checkPlayerPosition(player, mapName, zone)
  for i, v in pairs(mapTriggers) do
    if string.lower(mapName) == string.lower(i) then
      if inBetween(player.position.x, v[zone].x1, v[zone].x2)
        and inBetween(player.position.y, v[zone].y1, v[zone].y2)
        and inBetween(player.position.z, v[zone].z1, v[zone].z2)
      then
        return true
      else return false
      end
    end
  end
  return false
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

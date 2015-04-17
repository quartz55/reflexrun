-------------------------------------------------------------------------
-- Map Triggers
-------------------------------------------------------------------------

mapTriggers =
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

    ["RRbldf2"] =
      {
        ["begin"] =
          {
            x1 = -480;
            y1 = -95;
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
  };

function checkPlayerPosition(player, mapName, zone)
  for i, v in pairs(mapTriggers) do
    if mapName == i then
      if player.position.x >= v[zone].x1 and player.position.x <= v[zone].x2
        and player.position.y >= v[zone].y1 and player.position.y <= v[zone].y2
        and player.position.z >= v[zone].z1 and player.position.z <= v[zone].z2
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

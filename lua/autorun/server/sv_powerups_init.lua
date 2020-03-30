include("utils/server/sv_powerups_manager.lua")
CFCPowerups = CFCPowerups or { }
local foundPowerups = file.Find("powerups/server/*.lua", "LUA")
for _index_0 = 1, #foundPowerups do
  local powerup = foundPowerups[_index_0]
  powerup = "powerups/server/" .. tostring(powerup)
  print("Including " .. tostring(powerup))
  include(powerup)
end
CFCPowerups.spawnLocations = include("powerups/config/maps/" .. game.GetMap() .. ".lua")
local playerInit
playerInit = function(ply)
  ply.Powerups = ply.Powerups or { }
end
hook.Remove("PlayerInitialSpawn", "CFC_Powerups_PlayerInit")
hook.Add("PlayerInitialSpawn", "CFC_Powerups_PlayerInit", playerInit)
local playerLeave
playerLeave = function(ply)
  for _, powerup in pairs(ply.Powerups) do
    powerup:Remove()
  end
end
hook.Remove("PlayerDisconnected", "CFC_Powerups_Cleanup")
hook.Add("PlayerDisconnected", "CFC_Powerups_Cleanup", playerLeave)
local playerExitPvp
playerExitPvp = function(ply)
  for _, powerup in pairs(ply.Powerups) do
    if powerup.RequiresPvp then
      powerup:Remove()
    end
  end
end
hook.Remove("CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp")
hook.Add("CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp", playerExitPvp)
local playerDied
playerDied = function(ply)
  for _, powerup in pairs(ply.Powerups) do
    if powerup.RemoveOnDeath then
      powerup:Remove()
    end
  end
end
hook.Remove("PostPlayerDeath", "CFC_Powerups_PlayerDeath")
return hook.Add("PostPlayerDeath", "CFC_Powerups_PlayerDeath", playerDied)

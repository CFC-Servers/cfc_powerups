require("logger")
CFCPowerups = { }
CFCPowerups.Logger = Logger("CFC Powerups")
include("utils/server/sv_config_manager.lua")
include("utils/server/sv_powerups_manager.lua")
include("utils/server/sv_powerups_spawner.lua")
include("powerups/server/base.lua")
include("powerups/server/cluster_combine_ball.lua")
include("powerups/server/regen.lua")
include("powerups/server/viper.lua")
include("powerups/server/speed.lua")
include("powerups/server/hotshot.lua")
include("powerups/server/feather.lua")
include("powerups/server/ammo.lua")
include("powerups/server/grenadier.lua")
include("powerups/server/flux_shield.lua")
include("powerups/server/thorns.lua")
include("powerups/server/magnetic_crossbow.lua")
AddCSLuaFile("autorun/client/cl_powerups_init.lua")
AddCSLuaFile("powerups/client/halos.lua")
AddCSLuaFile("powerups/client/flux_shield.lua")
AddCSLuaFile("powerups/client/thorns.lua")
resource.AddWorkshop("3114946264")
local mapConfigPath = "powerups/config/maps/" .. tostring(game.GetMap()) .. ".lua"
CFCPowerups.spawnLocations = { }
if file.Exists(mapConfigPath, "LUA") then
  CFCPowerups.spawnLocations = include(mapConfigPath)
end
hook.Add("PlayerSpawn", "CFC_Powerups_PlayerInit", function(ply)
  ply.Powerups = ply.Powerups or { }
end)
hook.Add("PlayerDisconnected", "CFC_Powerups_Cleanup", function(ply)
  for _, powerup in pairs(ply.Powerups) do
    powerup:Remove()
  end
end)
hook.Add("CFC_PvP_PlayerExitPvp", "CFC_Powerups_PlayerExitPvp", function(ply)
  for _, powerup in pairs(ply.Powerups) do
    if powerup.RequiresPvp then
      powerup:Remove()
    end
  end
end)
return hook.Add("PostPlayerDeath", "CFC_Powerups_PlayerDeath", function(ply)
  for _, powerup in pairs(ply.Powerups) do
    if powerup.RemoveOnDeath then
      powerup:Remove()
    end
  end
end)

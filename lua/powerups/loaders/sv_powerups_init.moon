
include "utils/server/sv_config_manager.lua"
include "utils/server/sv_powerups_manager.lua"
include "utils/server/sv_powerups_spawner.lua"

include "powerups/shared/shotgun.lua"

include "powerups/server/base.lua"
include "powerups/server/cluster_combine_ball.lua"
include "powerups/server/regen.lua"
include "powerups/server/viper.lua"
include "powerups/server/speed.lua"
include "powerups/server/hotshot.lua"
include "powerups/server/feather.lua"
include "powerups/server/ammo.lua"
include "powerups/server/grenadier.lua"
include "powerups/server/flux_shield.lua"
include "powerups/server/thorns.lua"
include "powerups/server/magnetic_crossbow.lua"
include "powerups/server/groundpound.lua"
include "powerups/server/shotgun.lua"
include "powerups/server/phoenix.lua"
include "powerups/server/super_speed.lua"
include "powerups/server/curse.lua"

AddCSLuaFile "powerups/shared/shotgun.lua"

AddCSLuaFile "powerups/client/halos.lua"
AddCSLuaFile "powerups/client/flux_shield.lua"
AddCSLuaFile "powerups/client/thorns.lua"
AddCSLuaFile "powerups/client/shotgun.lua"
AddCSLuaFile "powerups/client/curse.lua"

resource.AddWorkshop "3114946264"

-- TODO: Automatically include all powerups after including the base powerup
--foundPowerups = file.Find "powerups/server/*.lua", "LUA"

--for powerup in *foundPowerups
--    powerup = "powerups/server/#{powerup}"
--
--    print "Including #{powerup}"
--    include powerup

mapConfigPath = "powerups/config/maps/#{game.GetMap!}.lua"
CFCPowerups.spawnLocations = {}

if file.Exists mapConfigPath, "LUA"
    CFCPowerups.spawnLocations = include mapConfigPath


hook.Add "PlayerSpawn", "CFC_Powerups_PlayerInit", (ply) ->
    ply.Powerups or= {}

hook.Add "PlayerDisconnected", "CFC_Powerups_Cleanup", (ply) ->
    powerup\Remove! for _, powerup in pairs ply.Powerups

hook.Add "CFC_PvP_PlayerExitPvp", "CFC_Powerups_PlayerExitPvp", (ply) ->
    powerup\Remove! for _, powerup in pairs ply.Powerups when powerup.RequiresPvp

hook.Add "PostPlayerDeath", "CFC_Powerups_PlayerDeath", (ply) ->
    powerup\Remove! for _, powerup in pairs ply.Powerups when powerup.RemoveOnDeath

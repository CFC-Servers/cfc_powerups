export CFCPowerups
CFCPowerups = {}

include "utils/server/sv_config_manager.lua"
include "utils/server/sv_powerups_manager.lua"
include "utils/server/sv_powerups_spawner.lua"

include "powerups/server/base.lua"
include "powerups/server/cluster_combine_ball.lua"
include "powerups/server/regen.lua"
include "powerups/server/viper.lua"
include "powerups/server/speed.lua"

-- TODO: Automatically include all powerups after including the base powerup
--foundPowerups = file.Find "powerups/server/*.lua", "LUA"

--for powerup in *foundPowerups
--    powerup = "powerups/server/#{powerup}"
--
--    print "Including #{powerup}"
--    include powerup

mapConfigPath = "powerups/config/maps/#{game.GetMap!}.lua"
CFCPowerups.spawnLocations = include mapConfigPath

hook.Add "PlayerInitialSpawn", "CFC_Powerups_PlayerInit", (ply) ->
    timer.Simple, 10, -> ply.Powerups or= {}

hook.Add "PlayerDisconnected", "CFC_Powerups_Cleanup", (ply) ->
    powerup\Remove! for powerup in *ply.Powerups

hook.Add "CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp",(ply) ->
    powerup\Remove! for powerup in *ply.Powerups when powerup.RequiresPvp

hook.Add "PostPlayerDeath", "CFC_Powerups_PlayerDeath", (ply) ->
    powerup\Remove! for powerup in *ply.Powerups when powerup.RemoveOnDeath

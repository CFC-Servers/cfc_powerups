export CFCPowerups
CFCPowerups = {}

include "powerups/config/sv_config.lua"

include "utils/server/sv_powerups_manager.lua"
include "utils/server/sv_powerups_spawner.lua"

include "powerups/server/base.lua"
include "powerups/server/cluster_combine_ball.lua"
include "powerups/server/regen.lua"
include "powerups/server/viper.lua"

-- TODO: Automatically include all powerups after including the base powerup
--foundPowerups = file.Find "powerups/server/*.lua", "LUA"

--for powerup in *foundPowerups
--    powerup = "powerups/server/#{powerup}"
--
--    print "Including #{powerup}"
--    include powerup

mapConfigPath = "powerups/config/maps/#{game.GetMap!}.lua"
CFCPowerups.spawnLocations = include mapConfigPath

playerInit = (ply) ->
    ply.Powerups or= {}

hook.Remove "PlayerInitialSpawn", "CFC_Powerups_PlayerInit"
hook.Add "PlayerInitialSpawn", "CFC_Powerups_PlayerInit", playerInit

playerLeave = (ply) ->
    for _, powerup in pairs ply.Powerups
        powerup\Remove!

hook.Remove "PlayerDisconnected", "CFC_Powerups_Cleanup"
hook.Add "PlayerDisconnected", "CFC_Powerups_Cleanup", playerLeave

playerExitPvp = (ply) ->
    for _, powerup in pairs ply.Powerups
        if powerup.RequiresPvp
            powerup\Remove!

hook.Remove "CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp"
hook.Add "CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp", playerExitPvp

playerDied = (ply) ->
    for _, powerup in pairs ply.Powerups
        if powerup.RemoveOnDeath
            powerup\Remove!

hook.Remove "PostPlayerDeath", "CFC_Powerups_PlayerDeath"
hook.Add "PostPlayerDeath", "CFC_Powerups_PlayerDeath", playerDied

include "utils/server/sv_powerups_manager.lua"

foundPowerups = file.Find "powerups/*.lua", "LUA"

for powerup in *foundPowerups
    print "Including #{powerup}"
    include powerup

export CFCPowerups
CFCPowerups or= {}

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

playerInit = (ply) ->
    ply.Powerups or= {}

hook.Remove "PlayerInitialSpawn", "CFC_Powerups_PlayerInit"
hook.Add "PlayerInitialSpawn", "CFC_Powerups_PlayerInit", playerInit

playerLeave = (ply) ->
    [powerup.RemovePowerup! for powerup in *ply\Powerups]

hook.Remove "PlayerDisconnected", "CFC_Powerups_Cleanup"
hook.Add "PlayerDisconnected", "CFC_Powerups_Cleanup", playerLeave

playerExitPvp = (ply) ->
    [powerup.RemovePowerup! for powerup in *ply\Powerups when powerup.RequiresPvp]

hook.Remove "CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp"
hook.Add "CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp", playerExitPvp

playerDied = (ply) ->
    [powerup.RemovePowerup! for powerup in *ply\Powerups when powerup.RemoveOnDeath]

hook.Remove "PostPlayerDeath", "CFC_Powerups_PlayerDeath"
hook.Add "PostPlayerDeath", "CFC_Powerups_PlayerDeath", playerDied

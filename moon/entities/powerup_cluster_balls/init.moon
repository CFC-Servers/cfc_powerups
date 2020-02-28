AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

CLUSTER_DELAY = 0.3 -- How long after firing will it cluster?
BALLS_PER_CLUSTER = 15 -- How many balls per cluster?
MIN_BALL_SPEED = 1500
MAX_BALL_SPEED = 1500
MAX_BALL_BOUNCES = 30 -- How many bounces until the clustered balls explode?
CLUSTER_BALL_COLOR = Color 255, 0, 0

CLUSTER_LAUNCH_SOUND = "beams/beamstart5.wav"
CLUSTER_LAUNCH_VOLUME = 500 -- 0-511

configureClusterBall = (ball) ->
    ball\SetSaveValue "m_bHeld", true -- Visual effects won't apply unless the ball is "held"
    ball\SetColor CLUSTER_BALL_COLOR

    util.SpriteTrail ball, 0, CLUSTER_BALL_COLOR, true, 10, 1, 1, 1, "trails/laser"

    ball.IsClusteredBall = true

makeClusterFor = (parent, owner) ->
    spawner = ents.Create "point_combine_ball_launcher"

    spawner\SetPos parent\GetPos!
    spawner\SetKeyValue "minspeed", MIN_BALL_SPEED
    spawner\SetKeyValue "maxspeed", MAX_BALL_SPEED
    spawner\SetKeyValue "ballradius", "15"
    spawner\SetKeyValue "ballcount", "0" -- Disable auto-spawning of balls
    spawner\SetKeyValue "maxballbounces", tostring MAX_BALL_BOUNCES
    spawner\SetKeyValue "launchconenoise", 360

    spawner\Spawn!
    spawner\SetOwner owner

    for _ in *count
        spawner\Fire "LaunchBall"
        parent\EmitSound CLUSTER_LAUNCH_SOUND, CLUSTER_LAUNCH_VOLUME

    timer.Simple 0.2, ->
        spawner\Fire "kill", "", 0

-- Is the given ball a cluster created by owner?
isClusteredBy = (ball, owner) ->
    -- The ball keeps a reference to the spawner that made it
    spawner = ball\GetSaveTable!["m_hSpawner"]
    if not IsValid spawner return false

    if spawner\GetOwner! == owner return true

-- Result passed into OnEntityCreated hook
createWatcherFor = (ply) ->
    (thing) ->
        if thing\GetClass! ~= "prop_combine_ball" return
        if thing.IsClusteredBall return

        -- Small delay to wait for owner to be set
        timer.Simple 0, ->
            if isClusteredBy thing, owner
                return configureClusterBall thing

            -- FiredBy implemented by CFC PvP
            ballOwner = thing.FiredBy or thing\GetOwner!

            if ballOwner ~= ply return

            makeClusterFor thing, ply

            existingPowerup = ply\GetPowerup ENT.PowerupName
            existingPowerup.RemainingClusterBalls -= 1

            if existingPowerup.RemainingClusterBalls <= 0
                existingPowerup.RemovePowerup!

ENT.PowerupEffect = (ply) =>
    plySteamID = ply\GetSteamID64!
    powerupHookName = "CFC_Powerups_ClusterBalls-#{plySteamID}"
    plyClusterWatcher = createWatcherFor ply

    hook.Remove "OnEntityCreated", powerupHookName
    hook.Add "OnEntityCreated", powerupHookName, plyClusterWatcher

    @PowerupInfo.RemainingClusterBalls = MAX_BALLS_TO_CLUSTER
    @PowerupInfo.RemovePowerup = ->
        hook.Remove "OnEntityCreated", powerupHookName
        ply\ChatPrint "You've lost the Cluster Powerup"

ENT.PowerupRefresh = (ply) =>
    existingPowerup = ply\GetPowerup @PowerupName

    existingPowerup.RemainingClusterBalls += MAX_BALLS_TO_CLUSTER

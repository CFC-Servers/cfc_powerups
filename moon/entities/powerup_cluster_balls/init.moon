AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

BALLS_PER_CLUSTER = 15
MIN_BALL_SPEED = 1500
MAX_BALL_SPEED = 1500
MAX_BALL_BOUNCES = "30" -- Must be a string
CLUSTER_BALL_COLOR = Color 255, 0, 0

CLUSTER_LAUNCH_SOUND = "beams/beamstart5.wav"
CLUSTER_LAUNCH_VOLUME = 500 -- 0-511

-- The only way to find these new balls is to check in a small radius around the spawner
-- :(
-- TODO: Check if the balls keep the spawner as an owner if we don't remove the spawner until after the balls init
findClusteredBalls = (parent) ->
    findRadius = 50
    things = ents.FindInSphere parent\GetPos!, findRadius

    [thing for thing in *things when thing\GetClass! == "prop_combine_ball"]

configureClusterBall = (ball) ->
    ball\SetColor CLUSTER_BALL_COLOR
    ball\Activate!

    ball.IsClusteredBall = true

makeClusterFor = (parent, owner) ->
    spawner = ents.Create "point_combine_ball_launcher"

    spawner\SetAngles parent\GetAngles!
    spawner\SetPos parent\GetPos!
    spawner\SetKeyValue "minspeed", MIN_BALL_SPEED
    spawner\SetKeyValue "maxspeed", MAX_BALL_SPEED
    spawner\SetKeyValue "ballradius", "15"
    spawner\SetKeyValue "ballcount", "1"
    spawner\SetKeyValue "maxballbounces", MAX_BALL_BOUNCES
    spawner\SetKeyValue "launchconenoise", 360

    spawner\Spawn!
    spawner\Activate!
    spawner\SetOwner owner

    for i in *count
        spawner\Fire "LaunchBall"
        parent\EmitSound CLUSTER_LAUNCH_SOUND, CLUSTER_LAUNCH_VOLUME

    -- Small delay to wait for the balls to actually init
    timer.Simple 0.01, ->
        balls = findClusteredBalls parent

        for ball in *balls
            ball\SetOwner owner
            configureClusterBall ball

        spawner\Fire "kill", "", 0

-- Result passed into OnEntityCreated hook
createWatcherFor = (ply) ->
    (thing) ->
        if thing\GetClass! ~= "prop_combine_ball" return
        if thing.IsClusteredBall return

        -- Small delay to wait for owner to be set
        -- TODO: do we have to wait longer?
        timer.Simple 0, ->
            if thing\GetOwner! ~= ply return

            makeClusterFor thing, ply
            ply.RemainingClusterBalls -= 1

            if ply.RemainingClusterBalls <= 0
                ply.RemovePowerup!

ENT.PowerupEffect = (ply) =>
    plySteamID = ply\GetSteamID64!
    powerupHookName = "CFC_Powerups_ClusterBalls-#{plySteamID}"
    plyClusterWatcher = createWatcherFor ply

    -- If the player picks up another of these powerups, it should just refresh it?
    hook.Remove "OnEntityCreated", powerupHookName
    hook.Add "OnEntityCreated", powerupHookName, plyClusterWatcher

    ply.RemainingClusterBalls = MAX_BALLS_TO_CLUSTER

    ply.RemovePowerup = =>
        hook.Remove "OnEntityCreated", powerupHookName
        @RemainingClusterBalls = nil

        @ChatPrint "You've lost the Cluster Powerup"

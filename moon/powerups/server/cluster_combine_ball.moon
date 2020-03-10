include "base.lua"

POWERUP_ID = "cluster-combine-balls"

CLUSTER_DELAY        = 0.3 -- How long after firing will it cluster?
BALLS_PER_CLUSTER    = 15  -- How many balls per cluster?
MAX_BALLS_TO_CLUSTER = 3   -- How many uses of the powerup?
MIN_BALL_SPEED       = 1500
MAX_BALL_SPEED       = 1500
MAX_BALL_BOUNCES     = 8   -- How many bounces until the clustered balls explode?
CLUSTER_BALL_COLOR = Color 255, 0, 0

CLUSTER_LAUNCH_SOUND = "cfc/seismic-charge-bass.wav"
CLUSTER_LAUNCH_VOLUME = 500 -- 0-511

TIGHTNESS         = 100
HORIZONTAL_SPREAD = 20
VERTICAL_SPREAD   = 10

getRandomizedVelocity = (original) ->
    x = TIGHTNESS
    y = math.random -HORIZONTAL_SPREAD, HORIZONTAL_SPREAD
    z = math.random -VERTICAL_SPREAD, VERTICAL_SPREAD

    newVel = Vector x, y, z

    newVel\Rotate original\Angle!
    newVel\Normalize!

    newVel

setClusterVelocity = (ball, parentVel) ->
    newVel = getRandomizedVelocity parentVel

    ball\GetPhysicsObject!\SetVelocity newVel*MAX_BALL_SPEED

configureClusterBall = (ball) ->
    ball\SetSaveValue "m_bHeld", true -- Visual effects won't apply unless the ball is "held"
    ball\SetColor CLUSTER_BALL_COLOR

    util.SpriteTrail ball, 0, CLUSTER_BALL_COLOR, true, 10, 1, 1, 1, "trails/laser"

    ball.IsClusteredBall = true

    ball\EmitSound CLUSTER_LAUNCH_SOUND, CLUSTER_LAUNCH_VOLUME

export ClusterBallPowerup
class ClusterBallPowerup extends BasePowerup
    new: (ply) =>
        super ply

        ownerSteamID = @owner\SteamID64!

        @PowerupHookName = "CFC_Powerups_ClusterBalls-#{ownerSteamID}"
        @RemainingClusterBalls = MAX_BALLS_TO_CLUSTER

        @ApplyEffect!

    -- Is the given ball a cluster created by owner?
    IsClusteredByOwner: (ball) =>
        -- The ball keeps a reference to the spawner that made it
        spawner = ball\GetSaveTable!["m_hSpawner"]
        if not IsValid spawner return false

        if spawner\GetOwner! == @owner return true

    MakeClusterFor: (parent) =>
        spawner = ents.Create "point_combine_ball_launcher"

        spawner\SetPos parent\GetPos!
        spawner\SetKeyValue "minspeed", MIN_BALL_SPEED
        spawner\SetKeyValue "maxspeed", MAX_BALL_SPEED
        spawner\SetKeyValue "ballradius", "15"
        spawner\SetKeyValue "ballcount", "0" -- Disable auto-spawning of balls
        spawner\SetKeyValue "maxballbounces", tostring MAX_BALL_BOUNCES
        spawner\SetKeyValue "launchconenoise", 360

        spawner\Spawn!
        spawner\SetOwner @owner

        for _ = 0, BALLS_PER_CLUSTER
            spawner\Fire "LaunchBall"

        -- Small delay so we can reference the spawner later
        timer.Simple 0.15, ->
            spawner\Fire "kill", "", 0

    -- Passed into OnEntityCreated
    ClusterBallWatcher: =>
        return (thing) ->
            if thing\GetClass! ~= "prop_combine_ball" return
            if thing.IsClusteredBall return

            -- Small delay to wait for owner to be set
            timer.Simple 0, ->
                if @IsClusteredByOwner thing
                    setClusterVelocity thing, @ParentBallVelocity
                    return configureClusterBall thing

                -- FiredBy implemented by CFC PvP
                ballOwner = thing.FiredBy or thing\GetOwner!

                if ballOwner ~= @owner return

                timer.Simple CLUSTER_DELAY, ->
                    -- Always hold on to the last parent ball's velocity
                    @ParentBallVelocity = thing\GetPhysicsObject!\GetVelocity!

                    @MakeClusterFor thing

                @RemainingClusterBalls -= 1

                if @RemainingClusterBalls <= 0
                    -- TODO: How to tell PowerupManager to also remove?
                    -- whose responsibility is it?
                    timer.Simple 0.25, -> @Remove!
                    return

    ApplyEffect: =>
        hook.Remove "OnEntityCreated", @PowerupHookName

        watcher = @ClusterBallWatcher!
        hook.Add "OnEntityCreated", @PowerupHookName, watcher

    Refresh: =>
        @RemainingClusterBalls += MAX_BALLS_TO_CLUSTER
        @owner\ChatPrint "You've gained #{MAX_BALLS_TO_CLUSTER} more uses of the Cluster Combine balls. (Total: #{@RemainingClusterBalls})"

    Remove: =>
        @owner\ChatPrint "You've lost the Cluster Powerup"

        hook.Remove "OnEntityCreated", @PowerupHookName

        if not IsValid(@owner) return

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[POWERUP_ID] = nil

CFCPowerups[POWERUP_ID] = ClusterBallPowerup

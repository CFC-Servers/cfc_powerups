{get: getConf} = CFCPowerups.Config

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
    maxSpeed = getConf "cball_speed"

    ball\GetPhysicsObject!\SetVelocity newVel * maxSpeed

configureClusterBall = (ball) ->
    ball\SetSaveValue "m_bHeld", true -- Visual effects won't apply unless the ball is "held"
    ball\SetColor CLUSTER_BALL_COLOR

    util.SpriteTrail ball, 0, CLUSTER_BALL_COLOR, true, 10, 1, 1, 1, "trails/laser"

    ball.IsClusteredBall = true

    ball\EmitSound CLUSTER_LAUNCH_SOUND, CLUSTER_LAUNCH_VOLUME

export ClusterBallPowerup
class ClusterBallPowerup extends BasePowerup
    @powerupID: "powerup_cluster_balls"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        ownerSteamID = @owner\SteamID64!

        @PowerupHookName = "CFC_Powerups_ClusterBalls-#{ownerSteamID}"
        @RemainingClusterBalls = getConf "cball_uses"

        @ApplyEffect!

    -- Is the given ball a cluster created by owner?
    IsClusteredByOwner: (ball) =>
        -- The ball keeps a reference to the spawner that made it
        spawner = ball\GetSaveTable!["m_hSpawner"]
        if not IsValid spawner return false

        if spawner\GetOwner! == @owner return true

    MakeClusterFor: (parent) =>
        spawner = ents.Create "point_combine_ball_launcher"

        speed = getConf "cball_speed"
        maxBounces = getConf "cball_bounces"

        spawner\SetPos parent\GetPos!
        spawner\SetKeyValue "minspeed", speed
        spawner\SetKeyValue "maxspeed", speed
        spawner\SetKeyValue "ballradius", "15"
        spawner\SetKeyValue "ballcount", "0" -- Disable auto-spawning of balls
        spawner\SetKeyValue "maxballbounces", tostring maxBounces
        spawner\SetKeyValue "launchconenoise", 360

        spawner\Spawn!
        spawner\SetOwner @owner

        for _ = 0, getConf "cball_balls_per_cluster"
            spawner\Fire "LaunchBall"

        -- Small delay so we can reference the spawner later
        timer.Simple 0.15, ->
            spawner\Fire "kill", "", 0

        if @RemainingClusterBalls <= 0
            -- TODO: How to tell PowerupManager to also remove?
            -- whose responsibility is it?
            timer.Simple 0.15, -> @Remove!

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

                clusterDelay = getConf "cball_cluster_delay"

                timer.Simple clusterDelay, ->
                    -- Always hold on to the last parent ball's velocity
                    @ParentBallVelocity = thing\GetPhysicsObject!\GetVelocity!

                    @MakeClusterFor thing

                @RemainingClusterBalls -= 1

    ApplyEffect: =>
        hook.Remove "OnEntityCreated", @PowerupHookName

        watcher = @ClusterBallWatcher!
        hook.Add "OnEntityCreated", @PowerupHookName, watcher

    Refresh: =>
        ballsToCluster = getConf "cball_uses"
        
        @RemainingClusterBalls += ballsToCluster
        @owner\ChatPrint "You've gained #{ballsToCluster} more uses of the Cluster Combine balls. (Total: #{@RemainingClusterBalls})"

    Remove: =>
        @owner\ChatPrint "You've lost the Cluster Powerup"

        hook.Remove "OnEntityCreated", @PowerupHookName

        if not IsValid(@owner) return

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

get: getConf = CFCPowerups.Config

import FindByClass from ents

export PowerupSpawner
PowerupSpawner =
    spawnIntervalTimerName: "CFC_Powerups_SpawnInterval"
    pickupWatcherName: "CFC_Powerups_PickupWatcher"

    findAllPowerups: -> FindByClass "powerup_*"

    removeAllPowerups: -> ent\Remove! for ent in *PowerupSpawner.findAllPowerups! when ent.spawnedAutomatically

    getRandomPowerup: (tier) ->
        CFCBasePowerup = CFCPowerups["base_cfc_powerup"]

        sumOfWeights = CFCBasePowerup.powerupTotalWeights[tier] - 1
        randomIndex = math.random 0, sumOfWeights

        for powerup in *CFCBasePowerup.powerupList
            if randomIndex < powerup.powerupWeights[tier]
                return powerup

            randomIndex -= powerup.powerupWeights[tier]

    getShuffledSpawnLocations: (tier) ->
        spawnLocations = table.Copy CFCPowerups.spawnLocations[tier]

        for i = #spawnLocations, 2, -1
            j = math.random i
            spawnLocations[i], spawnLocations[j] = spawnLocations[j], spawnLocations[i]

        spawnLocations

    getRandomSpawnLocations: (tier) ->
        tierSpawnDivider =
            tier1: 2
            tier2: 3
            tier3: 4
            tier4: 5

        allSpawnLocations = PowerupSpawner.getShuffledSpawnLocations tier
        spawnCount = math.floor #allSpawnLocations / tierSpawnDivider[tier]

        spawnLocations = {}

        for i = 1, spawnCount
            table.insert spawnLocations, allSpawnLocations[i]

        spawnLocations

    spawnPowerup: (powerupClass, position) ->
        with powerup = ents.Create powerupClass
            .spawnedAutomatically = true
            .originalPos = position
            \SetPos position + Vector 0, 0, getConf "spawn_height"
            \Spawn!

            \EmitSound getConf "spawn_sound", 90

            hook.Run "CFC_Powerups_PowerupSpawned", powerup

    spawnRandomPowerups: ->
        PowerupSpawner.removeAllPowerups!

        for tier = 1, 4
            tierName = "tier#{tier}"

            spawnLocations = PowerupSpawner.getRandomSpawnLocations tierName

            for location in *spawnLocations
                powerupClass = PowerupSpawner.getRandomPowerup( tierName ).powerupID

                PowerupSpawner.spawnPowerup powerupClass, location

    watchForPickup: ->
        for ply in *player.GetAll!
            for powerup in *PowerupSpawner.findAllPowerups!
                distance = powerup\GetPos!\DistToSqr ply\GetPos!
                threshold = powerup.PickupDistance * powerup.PickupDistance

                continue unless distance < threshold

                powerup\GivePowerup ply

    stop: =>
        timer.Remove @spawnIntervalTimerName

    start: (forceSpawner=false) =>
        spawnDelay = getConf "spawn_delay"
        shouldStartSpawner = forceSpawner or GetConVar("cfc_powerups_spawner_enabled")\GetBool!

        if shouldStartSpawner
            timer.Create @spawnIntervalTimerName, spawnDelay, 0, PowerupSpawner.spawnRandomPowerups

        timer.Create @pickupWatcherName, 0.25, 0, PowerupSpawner.watchForPickup

concommand.Add "cfc_powerups_enable_spawner", -> PowerupSpawner\start true
concommand.Add "cfc_powerups_disable_spawner", -> PowerupSpawner\stop!

CreateConVar "cfc_powerups_spawner_enabled", 1, FCVAR_ARCHIVE, "Whether or not powerups automatically spawn on the map", 0, 1
PowerupSpawner\start!

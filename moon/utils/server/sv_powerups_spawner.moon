get: getConf = CFCPowerups.Config

import FindByClass from ents

export PowerupSpawner
PowerupSpawner =
    findAllPowerups: -> FindByClass "powerup_*"

    removeAllPowerups: -> ent\Remove! for ent in *@findAllPowerups

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
        powerup = ents.Create powerupClass
        powerup.originalPos = position
        powerup\SetPos position
        powerup\Spawn!

        powerup\EmitSound getConf("spawn_sound"), 90

    spawnRandomPowerups: ->
        PowerupSpawner.removeAllPowerups!

        for tier = 1, 4
            tierName = "tier#{tier}"

            spawnLocations = PowerupSpawner.getRandomSpawnLocations tierName

            for location in *spawnLocations
                powerupClass = PowerupSpawner.getRandomPowerup( tierName ).powerupID

                PowerupSpawner.spawnPowerup powerupClass, location

    watchForPickup: ->
        for ply in ply.GetAll!
            for powerup in *PowerupSpawner.findAllPowerups
                distance = powerup\GetPos!\DistToSqr ply\GetPos!
                threshold = powerup.PickupDistance * powerup.PickupDistance

                continue unless distance < threshold

                powerup.GivePowerup ply
                break

    start: ->
        spawnDelay = getConf "spawn_delay"

        timer.Create "CFC_Powerups_SpawnInterval", delay, 0, PowerupSpawner.spawnRandomPowerups
        timer.Create "CFC_Powerups_PickupWatcher", 0.1, 0, PowerupSpawner.watchForPickup

PowerupSpawner.start!

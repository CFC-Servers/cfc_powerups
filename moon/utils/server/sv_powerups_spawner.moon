export PowerupSpawner
PowerupSpawner =
    removeAllPowerups: ->
        for _, ent in pairs ents.FindByClass( "powerup_*" )
            ent\Remove!

    getRandomPowerup: (tier) ->
        CFCBasePowerup = CFCPowerups["base_cfc_powerup"]

        sumOfWeights = CFCBasePowerup.powerupTotalWeights[tier] - 1
        randomIndex = math.random 0, sumOfWeights

        for name, powerup in pairs CFCBasePowerup.powerupList
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
        tierSpawnDivider = {
            tier1: 2
            tier2: 3
            tier3: 4
            tier4: 5
        }

        allSpawnLocations = PowerupSpawner.getShuffledSpawnLocations tier
        spawnCount = math.floor #allSpawnLocations / tierSpawnDivider[tier]

        spawnLocations = {}

        for i = 1, spawnCount
            table.insert spawnLocations, allSpawnLocations[i]

        spawnLocations

    spawnRandomPowerups: ->
        PowerupSpawner.removeAllPowerups!

        for tier = 1, 4
            tierName = "tier" .. tostring tier

            spawnLocations = PowerupSpawner.getRandomSpawnLocations tierName

            for _, location in ipairs spawnLocations
                powerupClass = PowerupSpawner.getRandomPowerup( tierName ).powerupID

                powerup = ents.Create powerupClass
                powerup\SetPos location
                powerup\Spawn!

    startSpawnTimer: (delay) ->
        timer.Create "cfc_powerup_spawn", delay, 0, PowerupSpawner.spawnRandomPowerups

PowerupSpawner.startSpawnTimer CFCPowerups.Config.spawnDelay
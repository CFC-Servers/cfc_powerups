export PowerupManager
PowerupManager =
    hasPowerup: (ply, powerupId) ->
        ply.Powerups[powerupId] ~= nil

    givePowerup: (ply, powerupId) ->
        existingPowerup = ply.Powerups[powerupId]

        if existingPowerup
            return existingPowerup\Refresh!

        ply.Powerups[powerupId] = CFCPowerups[powerupId](ply)

    plyCanGetPowerup: (ply, powerupId) ->
        existingPowerup = ply.Powerups[powerupId]

        if not existingPowerup return true

        if existingPowerup.RequiresPvP and ply\GetNWBool("CFC_PvP_Mode", false) == false
            return false

        if not ply\Alive! return false

        true

    refreshPowerup: (ply, powerupId) ->
        existingPowerup = ply.Powerups[powerupId]

        if existingPowerup
            existingPowerup\Refresh!

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
        allSpawnLocations = PowerupManager.getShuffledSpawnLocations tier
        spawnCount = math.floor #allSpawnLocations / (tier + 1)

        spawnLocations = {}

        for i = 1, spawnCount
            table.insert spawnLocations, allSpawnLocations[i]

        spawnLocations

    spawnRandomPowerups: ->
        for tier = 1, 4 do
            spawnLocations = PowerupManager.getRandomSpawnLocations tier

            for _, location in ipairs spawnLocations
                powerupClass = PowerupManager.getRandomPowerup!.powerupID

                powerup = ents.Create powerupClass
                powerup\SetPos location
                powerup\Spawn!

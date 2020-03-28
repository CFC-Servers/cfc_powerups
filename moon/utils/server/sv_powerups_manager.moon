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

    getRandomPowerup: ->
        sumOfWeights = CFCPowerups["cfc-base-powerup"].powerupTotalWeight - 1

        randomIndex = math.random 0, sumOfWeights

        for name, powerup in pairs CFCPowerups["cfc-base-powerup"].powerupList
            if randomIndex < powerup.powerupWeight
                return powerup

            randomIndex -= powerup.powerupWeight

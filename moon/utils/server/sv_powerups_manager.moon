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
        isInPvp = ply\GetNWBool("CFC_PvP_Mode", false)
        powerupBase = CFCPowerups[powerupId]
        existingPowerup = ply.Powerups[powerupId]

        if existingPowerup
            return existingPowerup.IsRefreshable

        baseRequiresPvp = powerupBase.RequiresPvp

        return true unless baseRequiresPvp
        return true if isInPvp

        false

    refreshPowerup: (ply, powerupId) ->
        existingPowerup = ply.Powerups[powerupId]

        return unless existingPowerup

        existingPowerup\Refresh!

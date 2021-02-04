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
        powerupBase = CFCPowerups[powerupId]
        existingPowerup = ply.Powerups[powerupId]

        canGet = hook.Run "CFC_Powerups_PlyCanGetPowerup", ply, powerupBase, existingPowerup
        return canGet if canGet ~= nil

        if existingPowerup
            return existingPowerup.IsRefreshable

        false

    refreshPowerup: (ply, powerupId) ->
        existingPowerup = ply.Powerups[powerupId]

        return unless existingPowerup

        existingPowerup\Refresh!

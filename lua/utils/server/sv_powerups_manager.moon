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

        -- Note that existingPowerup may or may not be nil
        blocked, denyReason = hook.Run "CFC_Powerups_DisallowGetPowerup", ply, powerupId, existingPowerup
        return false, denyReason if blocked == true

        if existingPowerup
            refreshable = existingPowerup.IsRefreshable

            return true if refreshable
            return false, "This powerup cannot be refreshed"

        baseRequiresPvp = powerupBase.RequiresPvp

        return true unless baseRequiresPvp
        return true if ply\IsInPvp!

        false, "This powerup requires PvP mode"

    refreshPowerup: (ply, powerupId) ->
        existingPowerup = ply.Powerups[powerupId]

        return unless existingPowerup

        existingPowerup\Refresh!

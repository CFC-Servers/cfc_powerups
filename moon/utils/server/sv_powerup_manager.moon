require "cfclogger"

export PowerupManager
PowerupManager =
    logger: CFCLogger "PowerupManager",
    givePowerup: (ply, powerup) =>
        if ply\HasPowerup powerup
            existingPowerup = ply\GetPowerup powerup

            return existingPowerup\Refresh!

        ply.Powerups[powerup.ID] = powerup ply

    plyCanGetPowerup: (ply, powerup) =>
        if powerup.RequiresPvP and ply\GetNWBool("CFC_PvP_Mode", false) == false
            return false

        if ply\IsDead! return false

        true

    refreshPowerup: (ply, powerup) =>
        existingPowerup = ply.Powerups[powerup.ID]
        existingPowerup\Refresh!

    getMetaPowerup: (powerupId) =>
        return CFCPowerups[powerupId]

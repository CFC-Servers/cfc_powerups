POWERUP_ID = "base-cfc-powerup"

export BasePowerup
class BasePowerup
    new: (ply, removeOnDeath=true, requiresPvp=true, isRefreshable=true) =>
        @owner = ply

        @RemoveOnDeath = removeOnDeath
        @RequiresPvp = requiresPvp
        @IsRefreshable = isRefreshable

    ApplyEffect: =>
        @owner\ChatPrint "Powerup Get!"
        @owner\Kill!

    Refresh: =>
        @owner\ChatPrint "Powerup Refreshed!"
        @owner\Kill!

    Remove: =>
        @owner\ChatPrint "Powerup Removed!"
        @owner\Kill!

CFCPowerups[POWERUP_ID] = BasePowerup

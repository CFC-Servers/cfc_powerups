POWERUP_ID = "base-cfc-powerup"

export BasePowerup
class BasePowerup
    @powerupList: {}
    @powerupTotalWeight: 0

    @powerupWeight: 0

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

    __inherited: ( child ) =>
        table.insert @powerupList, child
        @powerupTotalWeight += child.powerupWeight

CFCPowerups[POWERUP_ID] = BasePowerup

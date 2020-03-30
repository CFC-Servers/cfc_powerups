export BasePowerup
class BasePowerup
    @powerupList: {}

    @powerupID: "base_cfc_powerup"
    
    @powerupTotalWeights: {0, 0, 0, 0}
    @powerupWeights: {0, 0, 0, 0}

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
        
        CFCPowerups[child.powerupID] = child

        for tier = 1, 4
            @powerupTotalWeights[tier] += child.powerupWeights[tier]

CFCPowerups[BasePowerup.powerupID] = BasePowerup

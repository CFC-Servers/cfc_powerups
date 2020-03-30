export BasePowerup
class BasePowerup
    @powerupList: {}

    @powerupID: "base_cfc_powerup"
    
    @powerupTotalWeights: {
        tier1: 0
        tier2: 0
        tier3: 0
        tier4: 0
    }
    @powerupWeights: {
        tier1: 0
        tier2: 0
        tier3: 0
        tier4: 0
    }

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

    @__inherited: ( child ) =>
        table.insert @powerupList, child
        
        CFCPowerups[child.powerupID] = child

        for tier = 1, 4
            tierName = "tier" .. tostring tier

            @powerupTotalWeights[tierName] += child.powerupWeights[tierName]

CFCPowerups[BasePowerup.powerupID] = BasePowerup

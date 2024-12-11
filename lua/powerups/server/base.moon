export BasePowerup
class BasePowerup
    @powerupList: {}

    @powerupID: "base_cfc_powerup"

    @powerupTotalWeights:
        tier1: 0
        tier2: 0
        tier3: 0
        tier4: 0

    @powerupWeights:
        tier1: 0
        tier2: 0
        tier3: 0
        tier4: 0

    @RemoveOnDeath = true
    @RequiresPvp = true
    @IsRefreshable = true

    new: (ply) =>
        @owner = ply
        @RemoveOnDeath = @@RemoveOnDeath
        @RequiresPvp = @@RequiresPvp
        @IsRefreshable = @@IsRefreshable

    ApplyEffect: =>
        @owner\SetNWBool "HasPowerup", true
        hook.Run "CFC_Powerups_PowerupApplied", @owner, @powerupID
        nil

    Refresh: =>
        hook.Run "CFC_Powerups_PowerupRefreshed", @owner, @powerupID
        nil

    Remove: =>
        @owner\SetNWBool "HasPowerup", false
        hook.Run "CFC_Powerups_PowerupRemoved", @owner, @powerupID
        nil

    @__inherited: ( child ) =>
        table.insert @powerupList, child

        CFCPowerups[child.powerupID] = child

        for tier = 1, 4
            tierName = "tier#{tier}"

            @powerupTotalWeights[tierName] += child.powerupWeights[tierName]

CFCPowerups[BasePowerup.powerupID] = BasePowerup

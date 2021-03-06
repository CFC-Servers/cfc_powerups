get: getConf = CFCPowerups.Config

export AmmoPowerup
class AmmoPowerup extends BasePowerup
    @powerupID: "powerup_ammo"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply
        @ApplyEffect!

    ApplyEffect: =>
        super self
        duration = getConf "ammo_duration"
        refreshInterval = getConf "ammo_refresh_interval"

        @ensureAmmoTimer = "CFC_Powerups-Ammo-EnsureAmmo-#{@owner\SteamID64!}"
        timer.Create @ensureAmmoTimer, refreshInterval, 0, -> @RefreshAmmo!

        @durationTimer = "CFC_Powerups-Ammo-#{@owner\SteamID64!}"
        timer.Create @durationTimer, duration, 1, -> @Remove!

        @owner\ChatPrint "You've gained #{duration} seconds of the Ammo Powerup"

    RefreshAmmo: =>
        return unless IsValid @owner
        return unless @owner\Alive!

        giveThreshold = getConf "ammo_secondary_min"
        secondaryGiveAmount = getConf "ammo_secondary_refresh_amount"

        ownerWeapon = @owner\GetActiveWeapon!

        return unless IsValid ownerWeapon

        ammo2 = ownerWeapon\GetSecondaryAmmoType!
        canSetAmmo2 = ammo2 and ammo2 ~= -1
        shouldSetAmmo2 = canSetAmmo2 and @owner\GetAmmoCount(ammo2) < giveThreshold
        @owner\GiveAmmo(secondaryGiveAmount, ammo2, false) if shouldSetAmmo2

        ownerWeapon\SetClip1 100

    Refresh: =>
        super self
        timer.Start @ensureAmmoTimer
        @owner\ChatPrint "You've refreshed the duration of the Ammo Powerup"

    Remove: =>
        super self
        timer.Remove @ensureAmmoTimer
        timer.Remove @durationTimer

        return unless IsValid @owner

        for wep in *@owner\GetWeapons!
            wep\SetClip1 wep\GetMaxClip1!
            
            ammo2 = wep\GetSecondaryAmmoType!
            continue if ammo2 == -1

            @owner\SetAmmo 0, ammo2

        @owner\ChatPrint "You've lost the Ammo Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

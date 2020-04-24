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

        duration = getConf "ammo_duration"

        @ensureAmmoTimer = "CFC_Powerups-Ammo-EnsureAmmo-#{@owner\SteamID64!}"
        timer.Create @ensureAmmoTimer, 0.1, 0, -> @EnsureFullAmmo!

        @durationTimer = "CFC_Powerups-Ammo-#{@owner\SteamID64!}"
        timer.Create @durationTimer, duration, 1, -> @Remove!

        @owner\ChatPrint "You've gained #{timerDuration} seconds of the Ammo Powerup"

    EnsureFullAmmo: =>
        return unless IsValid @owner

        giveThreshold = getConf "ammo_secondary_min"
        ownerWeapon = @owner\GetActiveWeapon!

        ammo2 = ownerWeapon\GetSecondaryAmmoType!
        canSetAmmo2 = ammo2 ~= -1
        shouldSetAmmo2 = canSetAmmo2 and @owner\GetAmmoCount(ammo2) < giveThreshold
        @owner\GiveAmmo(1, ammo2) if shouldSetAmmo2

        ownerWeapon\SetClip1 100

    Refresh: =>
        timer.Start @ensureAmmoTimer
        @owner\ChatPrint "You've refreshed the duration of the Ammo Powerup"

    Remove: =>
        timer.Remove @ensureAmmoTimer
        timer.Remove @durationTimer

        return unless IsValid @owner

        for wep in *@owner\GetWeapons!
            wep\SetClip1 wep\GetMaxClip1!
            
            ammo2 = wep\GetSecondaryAmmoType!
            continue if ammo2 == -1

            @owner\SetAmmo 0

        @owner\ChatPrint "You've lost the Ammo Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

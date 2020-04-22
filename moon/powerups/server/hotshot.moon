get: getConf = CFCPowerups.Config

export HotshotPowerup
class HotshotPowerup extends BasePowerup
    @powerupID: "powerup_hotshot"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @timerName = "CFC_Powerups-Hotshot-#{ply\SteamID64!}"

        duration = getConf "hotshot_duration"

        timer.Create @timerName, interval, timerDuration, @PowerupTick!

        @owner\ChatPrint "You've gained #{timerDuration} seconds of the Hotshot Powerup"

    CalculateIgniteDuration = (damageInfo) =>
        damageInfo\GetDamage! * getConf "hotshot_ignite_multiplier"
    
    DamageWatcher: =>
        owner = @owner

        (ent, damageInfo, tookDamage) ->
            return unless damageInfo\GetAttacker! == owner
            return unless tookDamage

            shouldIgnite = hook.Run "CFC_Powerups_Hotshot_ShouldIgnite"
            return if shouldIgnite == false

            igniteDuration = @CalculateIgniteDuration damageInfo

            ent\Ignite igniteDuration

    ApplyEffect: =>
        -- Timer name is appropriate for our hook name
        hook.Add "PostEntityTakeDamage", @timerName, @DamageWatcher!

    Refresh: =>
        timer.Start @timerName
        @owner\ChatPrint "You've refreshed the duration of the Hotshot Powerup"

    Remove: =>
        timer.Remove @timerName
        hook.Remove "PostEntityTakeDamage", @timerName

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Hotshot Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

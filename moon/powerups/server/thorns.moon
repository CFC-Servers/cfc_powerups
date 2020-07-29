{get: getConf} = CFCPowerups.Config

import Round from math

export ThornsPowerup
class ThornsPowerup
    @powerupID: "powerup_thorns"
    
    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @TimerName = "CFC-Powerups_Thorns-#{ply\SteamID64!}"
        @HookName = @TimerName

        @ApplyEffect!

    DamageWatcher: =>
        (ent, dmg, took) ->
            return unless ent == @owner
            return unless took

            originalAttacker = dmg\GetAttacker!
            return unless IsValid originalAttacker
            return unless originalAttacker\IsPlayer!

            damageAmount = dmg\GetDamage!
            damageScale = getConf "thorns_return_percentage"
            damageScale = damageScale / 100

            -- Now we modify the damage and return it to the originalAttacker
            dmg\SetAttacker @owner
            dmg\ScaleDamage damageScale

            newDamageAmount = damageAmount * damageScale
            originalAttacker\TakeDamageInfo dmg
            originalAttacker\ChatPrint "[CFC Powerups] You took #{Round newDamageAmount} reflected damage!"

    ApplyEffect: =>
        super self

        duration = getConf "thorns_duration"

        hook.Add "PostEntityTakeDamage", @HookName, @DamageWatcher!
        timer.Create @TimerName, duration, 1, -> @Remove!

        @owner\ChatPrint "You've gained #{duration} seconds of the Thorns Powerup"

    Refresh: =>
        super self
        timer.Start @TimerName

        @owner\ChatPrint "You've refreshed the duration of your Thorns Powerup"

    Remove: =>
        super self

        hook.Remove "PostEntityTakeDamage", @HookName
        timer.Remove @TimerName

        @owner\ChatPrint "You've lost the Thorns Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

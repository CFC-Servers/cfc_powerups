get: getConf = CFCPowerups.Config
import Clamp from math

explodeWatcher = (ply, inflictor, attacker) ->
    return unless IsValid ply
    return unless ply.hotshotStacks

    playerPos = ply\GetPos!
    explosionDuration = getConf "hotshot_explosion_ignite_duration"
    explosionRadius = getConf "hotshot_explosion_radius"
    explosionSound = getConf "hotshot_explosion_sound"
    explosionLevel = getConf "hotshot_explosion_sound_level"
    explosionPitch = 100
    explosionVolume = 1

    sound.Play explosionSound, playerPos, explosionLevel, explosionPitch, explosionVolume
    ply\Ignite explosionDuration, explosionRadius
hook.Add "PlayerDeath", "CFC_Powerups_Hotshot_OnPlayerDeath", explodeWatcher

fireDamageWatcher = (ent, damageInfo) ->
    return unless IsValid ent

    stacks = ent.hotshotStacks
    return unless stacks

    inflictor = damageInfo\GetInflictor!\GetClass!
    return unless inflictor == "entityflame"

    maxStacks = getConf "hotshot_max_stacks"

    newStacks = Clamp stacks + 1, 0, maxStacks
    ent.hotshotStacks = newStacks

    damageInfo\AddDamage newStacks
hook.Add "EntityTakeDamage", "CFC_Powerups_Hotshot_OnFireDamage", fireDamageWatcher

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
        timerDuration = getConf "hotshot_duration"

        timer.Create @timerName, timerDuration, 1, -> @Remove!

        @owner\ChatPrint "You've gained #{timerDuration} seconds of the Hotshot Powerup"

        @ApplyEffect!

    CalculateIgniteDuration = (damageInfo) =>
        damageInfo\GetDamage! * getConf "hotshot_ignite_multiplier"

    IgniteWatcher: =>
        owner = @owner

        (ent, damageInfo, tookDamage) ->
            return unless IsValid ent
            return unless damageInfo\GetAttacker! == owner
            return unless tookDamage
            return if damageInfo\GetInflictor!\GetClass! == "entityflame"

            shouldIgnite = hook.Run "CFC_Powerups_Hotshot_ShouldIgnite"
            return if shouldIgnite == false

            igniteDuration = @CalculateIgniteDuration damageInfo
            ent\Ignite igniteDuration

            ent.hotshotStacks or= 0

            timerIndex = ent\IsPlayer! and ent\SteamID64! or ent\EntIndex!
            timerName = "CFC_Powerups-Hotshot-OnExtinguish-#{timerIndex}"

            timer.Create timerName, igniteDuration, 1, ->
                ent.hotshotStacks = nil
                timer.Remove timerName

    ApplyEffect: =>
        -- Timer name is appropriate for our hook name
        hook.Add "PostEntityTakeDamage", @timerName, @IgniteWatcher!

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

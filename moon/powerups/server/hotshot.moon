get: getConf = CFCPowerups.Config
import Clamp from math

explodeWatcher = (ply, inflictor, attacker) ->
    -- TODO: Fix the sound stuff here
    return unless IsValid ply
    return unless ply.hotshotBurningDamage

    playerPos = ply\GetPos!
    explosionDuration = getConf "hotshot_explosion_ignite_duration"
    explosionRadius = getConf "hotshot_explosion_radius"
    explosionSound = "ambient/fire/gascan_ignite1.wav"
    explosionLevel = getConf "hotshot_explosion_sound_level"
    explosionPitch = 100
    explosionVolume = 1

    effectName = "HelicopterMegaBomb"
    effectData = EffectData!
    with effectData
        \SetOrigin playerPos
        \SetMagnitude 5
        \SetScale 3

    util.Effect effectName, effectData, true, true
    sound.Play explosionSound, playerPos, 120, explosionPitch, explosionVolume

    e\Ignite explosionDuration for e in *ents.FindInSphere playerPos, explosionRadius

hook.Add "PlayerDeath", "CFC_Powerups_Hotshot_OnPlayerDeath", explodeWatcher

fireDamageWatcher = (ent, damageInfo) ->
    return unless IsValid ent

    burningDamage = ent.hotshotBurningDamage
    return unless burningDamage

    inflictor = damageInfo\GetInflictor!\GetClass!
    return unless inflictor == "entityflame"

    damageInfo\AddDamage burningDamage
hook.Add "EntityTakeDamage", "CFC_Powerups_Hotshot_OnFireDamage", fireDamageWatcher

calculateBurnDamage = (damageInfo) ->
    damageInfo\GetDamage! * getConf "hotshot_ignite_multiplier"

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

    IgniteWatcher: =>
        (ent, damageInfo, tookDamage) ->
            return unless IsValid ent
            return unless damageInfo\GetAttacker! == @owner and damageInfo\GetInflictor! == @owner
            return unless tookDamage
            return if damageInfo\GetInflictor!\GetClass! == "entityflame"

            shouldIgnite = hook.Run "CFC_Powerups_Hotshot_ShouldIgnite"
            return if shouldIgnite == false

            igniteDuration = getConf "hotshot_ignite_duration"
            ent\Ignite igniteDuration

            addedFireDamage = calculateBurnDamage damageInfo

            ent.hotshotBurningDamage or= 0
            ent.hotshotBurningDamage += addedFireDamage

            timerIndex = ent\IsPlayer! and ent\SteamID64! or ent\EntIndex!
            timerName = "CFC_Powerups-Hotshot-OnExtinguish-#{timerIndex}"

            timer.Create timerName, igniteDuration + 0.5, 1, ->
                ent.hotshotBurningDamage = nil
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

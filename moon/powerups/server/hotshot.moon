get: getConf = CFCPowerups.Config
import Clamp from math
import Effect from util

allowedToIgnite =
    "prop_physics": true
    "player": true

playExplosionSound = (pos) ->
    explosionSound = "ambient/fire/gascan_ignite1.wav"
    explosionPitch = 100
    explosionVolume = 1

    sound.Play explosionSound, pos, 100, explosionPitch, explosionVolume

playExplosionEffect = (pos) ->
    effectName = "HelicopterMegaBomb"
    effectData = EffectData!
    effectData\SetOrigin pos

    Effect effectName, effectData, true, true

explodeWatcher = (ply) ->
    return unless IsValid ply
    return unless ply.affectedByHotshot

    playerPos = ply\GetPos!
    burningDamage = ply.hotshotBurningDamage + (ply.hotshotExplosionBurningDamage or 0)

    baseRadius = getConf "hotshot_explosion_base_radius"
    baseDamage = getConf "hotshot_explosion_base_damage"

    maxExplosionRadius = getConf "hotshot_explosion_max_radius"
    maxExplosionDamage = getConf "hotshot_explosion_max_damage"
    maxExplosionBurnDuration = getConf "hotshot_explosion_max_burn_duration"

    scaledRadius = Clamp baseRadius * burningDamage, 1, maxExplosionRadius
    scaledDamage = Clamp baseDamage * burningDamage, 10, maxExplosionDamage
    scaledDuration = Clamp burningDamage, 1, maxExplosionBurnDuration

    playExplosionEffect ply\GetPos!
    CFCPowerups.Logger\info "Exploding #{ply\Nick!} with a radius of #{scaledRadius} units. (#{scaledDamage} extra burning damage)"

    nearbyEnts = ents.FindInSphere playerPos, scaledRadius
    goodEnts = [ent for ent in *nearbyEnts when allowedToIgnite[ent\GetClass!] and ent ~= ply]

    damageInfo = DamageInfo!
    with damageInfo
        \SetDamage scaledDamage
        \SetDamageType DMG_BLAST
        \SetAttacker ply
        \SetInflictor ply

    for ent in *goodEnts
        playExplosionSound ent\GetPos!

        with ent
            \Ignite scaledDuration
            \TakeDamageInfo damageInfo
            .hotshotExplosionBurningDamage = burningDamage

    timer.Simple scaledDuration, ->
        for ent in *goodEnts
            continue unless IsValid ent
            ent.hotshotExplosionBurningDamage = nil

hook.Add "PostPlayerDeath", "CFC_Powerups_Hotshot_OnPlayerDeath", explodeWatcher

fireDamageWatcher = (ent, damageInfo) ->
    return unless IsValid ent

    inflictor = damageInfo\GetInflictor!\GetClass!
    return unless inflictor == "entityflame"

    burningDamage = ent.hotshotBurningDamage
    explosionBurningDamage = ent.hotshotExplosionBurningDamage
    return unless burningDamage or explosionBurningDamage

    addedDamage = (burningDamage or 0) + (explosionBurningDamage or 0)

    --if ent\IsPlayer!
    --    ent\ChatPrint "You took an extra #{addedDamage} damage from fire damage due to Hotshot Stacks"

    damageInfo\AddDamage addedDamage

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
            return if ent == @owner
            return if damageInfo\GetInflictor!\GetClass! == "entityflame"

            shouldIgnite = hook.Run "CFC_Powerups_Hotshot_ShouldIgnite"
            return if shouldIgnite == false

            igniteDuration = getConf "hotshot_ignite_duration"
            ent\Ignite igniteDuration

            addedFireDamage = calculateBurnDamage damageInfo

            ent.affectedByHotshot = true
            ent.hotshotBurningDamage or= 0
            ent.hotshotBurningDamage += addedFireDamage

            timerIndex = ent\IsPlayer! and ent\SteamID64! or ent\EntIndex!
            timerName = "CFC_Powerups-Hotshot-OnExtinguish-#{timerIndex}"

            timer.Create timerName, igniteDuration + 0.5, 1, ->
                ent.affectedByHotshot = nil
                ent.hotshotBurningDamage = nil
                timer.Remove timerName

    ApplyEffect: =>
        super self
        -- Timer name is appropriate for our hook name
        hook.Add "PostEntityTakeDamage", @timerName, @IgniteWatcher!

    Refresh: =>
        super self
        timer.Start @timerName
        @owner\ChatPrint "You've refreshed the duration of the Hotshot Powerup"

    Remove: =>
        super self
        timer.Remove @timerName
        hook.Remove "PostEntityTakeDamage", @timerName

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Hotshot Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

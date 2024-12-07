get: getConf = CFCPowerups.Config
import Clamp from math
import Effect from util
import IsValid from _G

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

    powerup = ply.latestHotshotPowerup
    return unless powerup and not powerup.expired

    playerPos = ply\GetPos!
    burningDamage = ply.hotshotBurningDamage + (ply.hotshotExplosionBurningDamage or 0)

    baseRadius = getConf "hotshot_explosion_base_radius"
    baseDamage = getConf "hotshot_explosion_base_damage"

    maxExplosionRadius = getConf "hotshot_explosion_max_radius"
    maxExplosionDamage = getConf "hotshot_explosion_max_damage"

    scaledRadius = Clamp baseRadius * burningDamage, 1, maxExplosionRadius
    scaledDamage = Clamp baseDamage * burningDamage, 10, maxExplosionDamage

    playExplosionEffect ply\GetPos!
    CFCPowerups.Logger\info "Exploding #{ply\Nick!} with a radius of #{scaledRadius} units. (#{scaledDamage} extra burning damage)"

    nearbyEnts = ents.FindInSphere playerPos, scaledRadius
    goodEnts = [ent for ent in *nearbyEnts when allowedToIgnite[ent\GetClass!] and ent ~= ply and ( ent.Powerups == nil or ent.Powerups.powerup_hotshot == nil )]
    explosionPos = ply\GetPos!

    -- If a pvp system exists, exclude players who are not in pvp (props will be included regardless)
    if ply.IsInPvp
        goodEnts = [ent for ent in *goodEnts when ent.IsInPvp == nil or ent\IsInPvp!]

    for ent in *goodEnts
        playExplosionSound ent\GetPos!

        with ent
            damageInfo = DamageInfo! -- Needs to be a new damaginfo per ent since each receives a different damage amount
            with damageInfo
                \SetDamageType DMG_BLAST
                \SetAttacker powerup.owner
                \SetInflictor powerup.damageInflictor

                -- Reduce damage based on distance from the explosion
                dist = explosionPos\Distance ent\GetPos!
                mult = 1 - dist / scaledRadius
                damageInfo\SetDamage scaledDamage * Clamp mult, 0, 1

            \TakeDamageInfo damageInfo

hook.Add "PostPlayerDeath", "CFC_Powerups_Hotshot_OnPlayerDeath", explodeWatcher

fireDamageWatcher = (ent, damageInfo) ->
    return unless IsValid ent

    powerup = ent.latestHotshotPowerup
    return unless powerup and not powerup.expired

    inflictor = damageInfo\GetInflictor!
    return unless IsValid inflictor

    inflictorClass = inflictor\GetClass!
    return unless inflictorClass == "entityflame"

    burningDamage = ent.hotshotBurningDamage
    return unless burningDamage

    addedDamage = (burningDamage or 0)

    --if ent\IsPlayer!
    --    ent\ChatPrint "You took an extra #{addedDamage} damage from fire damage due to Hotshot Stacks"

    -- Use our own inflictor for its custom killfeed icon, tracking the kill correctly, and bypassing anything that normally blocks fire damage.
    damageInfo\SetInflictor powerup.damageInflictor
    damageInfo\SetAttacker powerup.owner
    damageInfo\AddDamage addedDamage

    return nil

hook.Add "EntityTakeDamage", "CFC_Powerups_Hotshot_OnFireDamage", fireDamageWatcher, HOOK_HIGH

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

        with @damageInflictor = ents.Create "cfc_powerup_hotshot_inflictor"
            \SetOwner @owner
            \Spawn!

        @ApplyEffect!

    IgniteWatcher: =>
        (ent, damageInfo, tookDamage) ->
            return unless IsValid ent
            return unless tookDamage
            return if ent == @owner
            return unless damageInfo\GetAttacker! == @owner

            -- Only allow if it's from the owner shooting directly with a SWEP, or if it's from the hotshot death explosion
            inflictor = damageInfo\GetInflictor!
            return unless inflictor == @owner or (damageInfo\IsExplosionDamage! and inflictor\GetClass! == "cfc_powerup_hotshot_inflictor")            

            shouldIgnite = hook.Run "CFC_Powerups_Hotshot_ShouldIgnite"
            return if shouldIgnite == false

            igniteDuration = getConf "hotshot_ignite_duration"
            ent\Ignite igniteDuration

            addedFireDamage = calculateBurnDamage damageInfo

            ent.affectedByHotshot = true
            ent.latestHotshotPowerup = self
            ent.hotshotBurningDamage or= 0
            ent.hotshotBurningDamage += addedFireDamage

            timerIndex = ent\IsPlayer! and ent\SteamID64! or ent\EntIndex!
            timerName = "CFC_Powerups-Hotshot-OnExtinguish-#{timerIndex}"

            timer.Create timerName, igniteDuration + 0.5, 1, ->
                ent.affectedByHotshot = nil
                ent.latestHotshotPowerup = nil
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

        @expired = true

        if IsValid @damageInflictor
            @damageInflictor\Remove!

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Hotshot Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

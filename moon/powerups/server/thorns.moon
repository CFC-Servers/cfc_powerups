{get: getConf} = CFCPowerups.Config

import AddNetworkString, Effect from util
import random, Round from math

AddNetworkString "CFC_Powerups-PlyTookThornsDamage"

export ThornsPowerup
class ThornsPowerup extends BasePowerup
    @powerupID: "powerup_thorns"
    
    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @holo = @MakeHolo!
        @aoeEffect = @MakeAoeEffect!

        @passiveSoundPath = "ambient/energy/force_field_loop1.wav"
        @passiveSound = CreateSound @holo, @passiveSoundPath
        @passiveSound\SetSoundLevel 100

        @TimerName = "CFC-Powerups_Thorns-#{ply\SteamID64!}"
        @HookName = @TimerName
        @ZapperName = "#{@TimerName}-Zapper"

        @ApplyEffect!

    MakeAoeEffect: =>
        effect = EffectData!
        with effect
            \SetEntity @holo
            \SetScale 1
            \SetMagnitude 12
            \SetRadius 20

        effect

    MakeHolo: =>
        holo = ents.Create "base_anim"

        -- Hip
        parentAttachment = 6

        with holo
            \SetModel "models/hunter/blocks/cube025x025x025.mdl"
            \SetPos @owner\GetPos! + Vector(0, 0, 50)
            \SetParent @owner, parentAttachment
            \SetRenderMode RENDERMODE_NONE
            \DrawShadow false
            \Spawn!
            \CallOnRemove "CleanupOnRemove", ->
                @passiveSound\Stop!

        holo

    GetSparkSound: =>
        sparkNumber = random 1, 11
        "ambient/energy/newspark#{string.format "%02d", sparkNumber}.wav"

    PlaySparkSound: (target) =>
        sparkSound = @GetSparkSound!
        target\EmitSound sparkSound, 75, 100, 0.6

    BroadcastDamage: (attacker, amount) =>
        net.Start "CFC_Powerups-PlyTookThornsDamage"
        net.WriteEntity @owner
        net.WriteEntity attacker
        net.WriteFloat amount
        net.Broadcast!

    DamageWatcher: =>
        (ent, dmg, took) ->
            return unless ent == @owner
            return if took == false

            originalAttacker = dmg\GetAttacker!
            return unless IsValid originalAttacker
            --return unless originalAttacker\IsPlayer!
            return if ent == originalAttacker

            damageAmount = dmg\GetDamage!

            return unless damageAmount > 0

            damageScale = getConf "thorns_return_percentage"
            damageScale = damageScale / 100

            -- Now we modify the damage and return it to the originalAttacker
            dmg\SetAttacker @owner
            dmg\ScaleDamage damageScale

            newDamageAmount = damageAmount * damageScale
            @BroadcastDamage originalAttacker, newDamageAmount

            originalAttacker\TakeDamageInfo dmg
            @PlaySparkSound originalAttacker

            --originalAttacker\ChatPrint "[CFC Powerups] You took #{Round newDamageAmount} reflected damage!"

    ApplyEffect: =>
        super self

        duration = getConf "thorns_duration"

        damageWatcher = @DamageWatcher!
        hook.Add "PostEntityTakeDamage", @HookName, damageWatcher
        hook.Add "DoPlayerDeath", @HookName, (ply, _, dmg ) ->
            damageWatcher ply, dmg

        timer.Create @TimerName, duration, 1, -> @Remove!
        timer.Create @ZapperName, 0.1, duration * 10, ->
            Effect("TeslaHitboxes", @aoeEffect, true, true )

        @passiveSound\Play!
        @passiveSound\ChangeVolume 0.1

        @owner\SetNWBool "CFC_Powerups-HasThorns", true

        @owner\ChatPrint "You've gained #{duration} seconds of the Thorns Powerup"

    Refresh: =>
        super self
        timer.Start @TimerName

        @owner\ChatPrint "You've refreshed the duration of your Thorns Powerup"

    Remove: =>
        super self

        hook.Remove "PostEntityTakeDamage", @HookName
        hook.Remove "DoPlayerDeath", @HookName
        timer.Remove @TimerName
        timer.Remove @ZapperName
        @passiveSound\Stop!
        @holo\Remove!

        return unless IsValid @owner

        @owner\SetNWBool "CFC_Powerups-HasThorns", false

        @owner\ChatPrint "You've lost the Thorns Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

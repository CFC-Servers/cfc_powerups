{get: getConf} = CFCPowerups.Config

import AddNetworkString, Compress, Effect, TableToJSON from util
import random, Round from math
import Count, insert from table

AddNetworkString "CFC_Powerups-ThornsDamage"

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

        -- We batch up damage broadcasts to lessen the network load
        -- Interval is in seconds
        @LastDamageBroadcast = CurTime!
        @BroadcastQueue = {}
        @BroadcastInterval = 0.5
        @BroadcastQueueLimit = 75
        @BroadcastQueueSize = ->
            count = 0
            for ply, targets in pairs @BroadcastQueue
                count += Count targets

            count

        @passiveSoundPath = "ambient/energy/force_field_loop1.wav"
        @passiveSound = CreateSound @holo, @passiveSoundPath
        @passiveSound\SetSoundLevel 100

        @TimerName = "CFC-Powerups_Thorns-#{ply\SteamID64!}"
        @HookName = @TimerName
        @ZapperName = "#{@TimerName}-Zapper"

        with @damageInflictor = ents.Create "cfc_powerup_thorns_inflictor"
            \SetOwner @owner
            \Spawn!

        @ApplyEffect!

    PlayAoeEffect: =>
        with effect = EffectData!
            \SetEntity @holo
            \SetScale 1
            \SetMagnitude 12

            Effect "TeslaHitboxes", effect, true, true

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

    BroadcastDamage: =>
        net.Start "CFC_Powerups-ThornsDamage"
        net.WriteTable @BroadcastQueue
        net.Broadcast!

        @LastDamageBroadcast = CurTime!
        @BroadcastQueue = {}

    QueueDamageForBroadcast: (attacker, amount) =>
        @BroadcastQueue[@owner] or= {}
        ownerToAttacker = @BroadcastQueue[@owner][attacker]

        if ownerToAttacker
            @BroadcastQueue[@owner][attacker] += amount
        else
            @BroadcastQueue[@owner][attacker] = amount

        now = CurTime!
        diff = now - @LastDamageBroadcast

        overLimit = @BroadcastQueueSize! > @BroadcastQueueLimit
        expired = diff >= @BroadcastInterval

        if expired or overLimit
            @BroadcastDamage!

    DamageWatcher: =>
        (ent, dmg, took) ->
            return unless ent == @owner
            return if took == false

            attacker = dmg\GetAttacker!
            return unless IsValid attacker
            --return unless attacker\IsPlayer!
            return if ent == attacker

            inflictor = dmg\GetInflictor!
            return if IsValid(inflictor) and inflictor\GetClass! == "cfc_powerup_thorns_inflictor"

            damageAmount = dmg\GetDamage!

            return unless damageAmount > 0
            --return unless attacker\Alive! -- TODO: Does this actually prevent reflect damage being reflected?

            damageScale = getConf "thorns_return_percentage"
            damageScale = damageScale / 100
            reflectedAmount = math.ceil damageAmount * damageScale
            thornsInflictor = @damageInflictor

            -- CTakeDamageInfo is a singleton, need to deal damage in a timer otherwise it'll break other PED hook listeners
            timer.Simple 0, ->
                return unless IsValid attacker
                return unless IsValid ent
                return unless IsValid thornsInflictor

                with refDmg = DamageInfo!
                    \SetAttacker ent
                    \SetInflictor thornsInflictor
                    \SetDamage reflectedAmount
                    \SetDamageType DMG_GENERIC

                    attacker\TakeDamageInfo refDmg

            @QueueDamageForBroadcast attacker, reflectedAmount

            --attacker\ChatPrint "[CFC Powerups] You took #{Round newDamageAmount} reflected damage!"

            return nil

    ApplyEffect: =>
        super self

        @duration = getConf "thorns_duration"

        damageWatcher = @DamageWatcher!
        hook.Add "PostEntityTakeDamage", @HookName, damageWatcher
        hook.Add "DoPlayerDeath", @HookName, (ply, _, dmg ) ->
            damageWatcher ply, dmg

        timer.Create @TimerName, @duration, 1, -> @Remove!
        timer.Create @ZapperName, 0.1, @duration * 10, -> @PlayAoeEffect!

        @passiveSound\Play!
        @passiveSound\ChangeVolume 0.1

        @owner\SetNWBool "CFC_Powerups-HasThorns", true

        @owner\ChatPrint "You've gained #{duration} seconds of the Thorns Powerup"

    Refresh: =>
        super self
        timer.Start @TimerName
        timer.Create @ZapperName, 0.1, @duration * 10, -> @PlayAoeEffect!

        @owner\ChatPrint "You've refreshed the duration of your Thorns Powerup"

    Remove: =>
        super self

        hook.Remove "PostEntityTakeDamage", @HookName
        hook.Remove "DoPlayerDeath", @HookName
        timer.Remove @TimerName
        timer.Remove @ZapperName

        @passiveSound\Stop!
        damageInflictor = @damageInflictor

        if IsValid @holo
            @holo\Remove!

        -- Remove damageInflictor after a decent delay to ensure all damage reflections finish first.
        -- There's no harm in having it exist for a little longer, and overlaps aren't a problem, so this is safe.
        timer.Simple 0.5, ->
            return unless IsValid damageInflictor

            damageInflictor\Remove!

        return unless IsValid @owner

        @owner\SetNWBool "CFC_Powerups-HasThorns", false
        @owner\ChatPrint "You've lost the Thorns Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

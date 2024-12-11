get: getConf = CFCPowerups.Config

import Rand, cos, sin from math
import Create from ents
import SpriteTrail from util

export PhoenixPowerup
class PhoenixPowerup extends BasePowerup
    @powerupID: "powerup_phoenix"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @UsesRemaining = getConf "phoenix_uses"
        @reviveHealth = getConf "phoenix_revive_health"
        @reviveArmor = getConf "phoenix_revive_armor"
        @immunityDamageMult = getConf "phoenix_immunity_damage_multiplier"
        @immunityDuration = getConf "phoenix_immunity_duration"

        @ApplyEffect!

    Revive: =>
        @UsesRemaining = @UsesRemaining - 1
        @immune = true

        with @owner
            \SetHealth @reviveHealth
            \SetArmor @reviveArmor
            \ChatPrint "You've been revived by the Phoenix spirit! (#{@UsesRemaining} uses remaining)"

        with eff = EffectData!
            eff\SetOrigin @owner\GetPos!

            util.Effect "VortDispel", eff, true, true

        with eff = EffectData!
            eff\SetOrigin @owner\GetPos!
            eff\SetMagnitude 1
            eff\SetScale 1
            eff\SetFlags 0x4 + 0x8 + 0x80

            util.Effect "Explosion", eff, true, true

        for i = 0, 5
            pitch = Lerp i / 5, 80, 140
            @owner\EmitSound "ambient/fire/gascan_ignite1.wav", 75, pitch, 0.5

        @owner\EmitSound "ambient/levels/labs/teleport_rings_loop2.wav", 75, 230, 0.75

        timer.Create @timerName, @immunityDuration, 1, ->
            @immune = false

            if IsValid @owner
                @owner\StopSound "ambient/levels/labs/teleport_rings_loop2.wav"
                @owner\EmitSound "ambient/energy/newspark09.wav", 75, 90, 1

            if @UsesRemaining <= 0
                @Remove!

    DamageWatcher: =>
        (victim, damageInfo) ->
            if @immune
                return true if victim == @owner -- Block all damage while immune

                -- Multiplier of outgoing damage while the owner is immune
                damageInfo\ScaleDamage @immunityDamageMult
                return

            return unless victim == @owner
            return unless victim\Alive!

            newHealth = math.floor victim\Health! - damageInfo\GetDamage!
            return unless newHealth <= 0

            -- In case another addon intentionally blocks the damage in HOOK_LOW after us
            -- (e.g. cfc_pvp_weapons using damage events to check if a grenade's special effect can be applied)
            shouldIgnore = hook.Run "CFC_Powerups-Phoenix-ShouldIgnoreDamage", victim, damageInfo
            return if shouldIgnore == true

            @Revive!

            return true

    -- We need EF_NO_DISSOLVE to prevent combine balls from bypassing the revive,
    --  but it also makes them not create a damage event, so we need a collision listener
    --  to deduct uses when the player is hit by a combine ball.
    CollisionListener: =>
        (_, colData) ->
            otherEnt = colData.HitEntity
            return unless IsValid otherEnt
            return unless otherEnt\GetClass! == "prop_combine_ball"
            return if otherEnt._cfcPowerups_phoenix_alreadyHit

            -- Remove the combine ball, and add a flag to account for multiple collisions happening in the same tick.
            otherEnt._cfcPowerups_phoenix_alreadyHit = true
            otherEnt\Remove!

            if not @immune
                @Revive!
                    

    ApplyEffect: =>
        super self
        steamID = @owner\SteamID64!

        @damageWatcherName = "CFC_Powerups-Phoenix-DamageWatcher-#{steamID}"
        @timerName = "CFC_Powerups-Phoenix-Timer-#{steamID}"
        @collisionListenerID = @owner\AddCallback "PhysicsCollide", @CollisionListener!

        hook.Add "EntityTakeDamage", @damageWatcherName, @DamageWatcher!, HOOK_LOW -- Low so we go after any other damage modifiers or blockers

        @hadNoDissolve = @owner\IsEFlagSet EFL_NO_DISSOLVE

        @owner\AddEFlags EFL_NO_DISSOLVE -- Prevent combine balls from bypassing the revive
        @owner\ChatPrint "You've gained #{@UsesRemaining} Phoenix rounds"

    Refresh: =>
        super self

        usesGained = getConf "phoenix_uses"
        maxUses = getConf "phoenix_max_uses"
        oldUses = @UsesRemaining
        newUses = math.min oldUses + usesGained, maxUses

        @UsesRemaining = newUses
        @owner\ChatPrint "You've gained #{newUses - oldUses} extra Phoenix rounds (total: #{@UsesRemaining})"

    Remove: =>
        super self

        timer.Remove @timerName
        hook.Remove "EntityTakeDamage", @damageWatcherName

        return unless IsValid @owner

        @owner\RemoveCallback "PhysicsCollide", @collisionListenerID

        if not @hadNoDissolve
            @owner\RemoveEFlags EFL_NO_DISSOLVE

        if @UsesRemaining == 0
            @owner\ChatPrint "You've lost the Phoenix Powerup"
        else
            -- The owner died directly from :Kill() or something else
            @owner\ChatPrint "The Phoenix spirit tried, but your body was unrecoverable..."

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

hook.Add "CFC_Powerups_DisallowGetPowerup", "CFC_Powerups-Phoenix-EnforceUseLimit", (_, powerupId, existingPowerup) ->
    return unless powerupId == "powerup_phoenix"
    return unless existingPowerup

    maxUses = getConf "phoenix_max_uses"
    return unless existingPowerup.UsesRemaining >= maxUses

    return true, "You're maxed out on Phoenix uses"

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

        maxRegenHealth = math.min @reviveHealth, @owner\GetMaxHealth!
        maxRegenArmor = math.min @reviveArmor, @owner\GetMaxArmor!

        with @owner
            \SetHealth 1
            \SetArmor maxRegenArmor == 0 and 0 or 1
            \ChatPrint "Like a phoenix, you rise from the ashes! (#{@UsesRemaining} uses remaining)"

            splodePitch = math.random 80, 90
            \EmitSound "ambient/levels/labs/electric_explosion4.wav", 75, splodePitch, 1
            \ScreenFade SCREENFADE.IN, (Color 255, 240, 230, 150), 2, 0.1

            util.ScreenShake \GetPos!, 10, 20, 2.5, 1500
            util.ScreenShake \GetPos!, 40, 40, 0.5, 500

        with eff = EffectData!
            eff\SetOrigin @owner\GetPos!
            eff\SetNormal Vector 0, 0, 1

            util.Effect "VortDispel", eff, true, true
            util.Effect "HL1GaussWallImpact2", eff, true, true

        with eff = EffectData!
            eff\SetOrigin @owner\WorldSpaceCenter!
            eff\SetNormal Vector 0, 0, -1
            eff\SetMagnitude 50

            util.Effect "HL1GaussWallPunchExit", eff, true, true

        with eff = EffectData!
            eff\SetOrigin @owner\GetPos!
            eff\SetMagnitude 1
            eff\SetScale 1

            util.Effect "cball_explode", eff, true, true

        @owner\CreateRagdoll

        with @holyMusic = CreateSound @owner, "music/hl2_song10.mp3"
            songPitch = math.random 140, 160
            \PlayEx 1, songPitch
            \FadeOut @immunityDuration

        with @heartbeatSound = CreateSound @owner, "player/heartbeat1.wav"
            \Play 75, 80

        -- slowly regen health + armor from 0
        timer.Create @regenTimerName, 0.1, 0, ->
            bad = not @immune or not IsValid @owner

            if bad then
                timer.Remove @regenTimerName
                return

            with @owner
                health = \Health!
                if health < maxRegenHealth then
                    addHealth = math.random 1, 5
                    newHealth = math.Clamp health + addHealth, 0, maxRegenHealth

                    \SetHealth newHealth

                armor = \Armor!
                if armor < maxRegenArmor
                    addArmor = math.random 1, 5
                    newArmor = math.Clamp armor + addArmor, 0, maxRegenArmor

                    \SetArmor newArmor

        timer.Create @timerName, @immunityDuration, 1, ->
            @immune = false
            timer.Remove @regenTimerName

            if IsValid @owner
                @holyMusic\Stop!
                @holyMusic = nil
                @heartbeatSound\Stop!
                @heartbeatSound = nil

                for i = 1, 5
                    pitch = Lerp i / 5, 80, 140
                    @owner\EmitSound "ambient/machines/thumper_hit.wav", 75, pitch, 0.5

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
        @regenTimerName = "CFC_Powerups-Phoenix-Regen-Timer-#{steamID}"
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
        timer.Remove @regenTimerName
        hook.Remove "EntityTakeDamage", @damageWatcherName

        return unless IsValid @owner

        @owner\RemoveCallback "PhysicsCollide", @collisionListenerID

        if not @hadNoDissolve
            @owner\RemoveEFlags EFL_NO_DISSOLVE

        if @holyMusic
            @holyMusic\Stop!

        if @heartbeatSound
            @heartbeatSound\Stop!

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

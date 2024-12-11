get: getConf = CFCPowerups.Config

TERMINAL_VELOCITY = 3500
EASE_FUNC = math.ease.InQuad
BAD_MOVETYPES = {
    MOVETYPE_NONE: true
    MOVETYPE_NOCLIP: true
    MOVETYPE_LADDER: true
    MOVETYPE_OBSERVER: true
}

FALL_SOUND_FADE_IN = 0.5
FALL_SOUND_FADE_OUT = 0.5

TRAIL_ENABLED = true
TRAIL_INTERVAL = 0.1
TRAIL_LENGTH = 2
TRAIL_SPEED = 2
TRAIL_OFFSET_SPREAD = 30
TRAIL_AMOUNT = 5

export GroundpoundPowerup
class GroundpoundPowerup extends BasePowerup
    @powerupID: "powerup_groundpound"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @hookName = "CFC_Powerups-Groundpound-#{ply\SteamID64!}"
        @hookNameVictim = "CFC_Powerups-Groundpound-Victim-#{ply\SteamID64!}"
        @nextTrailTime = 0
        @fastFalling = false

        @UsesRemaining = getConf "groundpound_uses"
        @accel = getConf "groundpound_acceleration"
        @minSpeed = getConf "groundpound_min_speed"
        @speedDivide = getConf "groundpound_speed_divide"
        @damageMult = getConf "groundpound_damage_multiplier"
        @damageMax = getConf "groundpound_damage_max"
        @radiusMult = getConf "groundpound_radius_multiplier"
        @radiusMax = getConf "groundpound_radius_max"
        @knockbackMult = getConf "groundpound_knockback_multiplier"
        @knockbackMax = getConf "groundpound_knockback_max"

        rf = RecipientFilter!
        rf\AddAllPlayers!

        with @damageInflictor = ents.Create "cfc_powerup_groundpound_inflictor"
            \SetOwner ply
            \Spawn!

        with @fallSound = CreateSound ply, "ambient/machines/machine6.wav", rf
            \PlayEx 0, 100

        @ApplyEffect!

    CreateOwnerDamageWatcher: =>
        (victim, damageInfo) ->
            return unless victim == @owner
            return true if damageInfo\IsFallDamage! -- Block fall damage

            return unless damageInfo\GetAttacker! == victim -- Only block groundpounds from the owner

            inflictor = damageInfo\GetInflictor!
            return unless IsValid inflictor
            return unless inflictor\GetClass! == "cfc_powerup_groundpound_inflictor"

            -- Block damage from own shockwave
            return true

    CreateVictimDamageWatcher: =>
        (victim, damageInfo) ->
            return if victim == @owner
            return unless damageInfo\GetAttacker! == @owner

            inflictor = damageInfo\GetInflictor!
            return unless IsValid inflictor
            return unless inflictor\GetClass! == "cfc_powerup_groundpound_inflictor"

            physObj = victim\GetPhysicsObject!
            return unless victim\IsPlayer! or ( ( IsValid physObj ) and physObj\IsMotionEnabled! )

            -- Apply knockback to victims
            knockback = math.min @knockbackMult * damageInfo\GetDamage!, @knockbackMax
            dir = victim\WorldSpaceCenter! - @owner\GetPos!

            -- Force the direction to have a significant upwards angle
            -- Otherwise, it's a coin flip between barely any movement and way too much, because of Source shenanigans
            ang = dir\Angle!
            pitch = -math.Rand 40, 60
            dir = ( Angle pitch, ang.yaw, 0 )\Forward!

            if victim\IsPlayer!
                velToAdd = dir * knockback + Vector 0, 0, 250 -- Still need to add some minumum upwards velocity to counteract ground stickiness

                victim\SetVelocity velToAdd
                damageInfo\SetDamageForce velToAdd * 100 -- Apply forces to the death ragdoll, in case the player dies
            else
                up = 300 * math.pow physObj\GetMass!, 0.95 -- Added up strength, now with partial mass scaling so heavy objects still move a bit
                force = dir * knockback + Vector 0, 0, up

                physObj\ApplyForceCenter force

            -- Make hitmarkers correctly display at the victim's position
            damageInfo\SetDamagePosition victim\WorldSpaceCenter!

            return nil -- Moon moment

    CreateFallDamageWatcher: =>
        (ply, speed) ->
            return unless ply == @owner
            return unless speed >= @minSpeed
            return unless @owner\KeyDown IN_DUCK -- Only trigger when crouched

            scaledSpeed = EASE_FUNC speed / @speedDivide
            damage = math.min scaledSpeed * @damageMult, @damageMax
            radius = math.min scaledSpeed * @radiusMult, @radiusMax

            util.BlastDamage @damageInflictor, @owner, @owner\WorldSpaceCenter!, radius, damage

            @UsesRemaining -= 1
            @owner\ChatPrint "You have #{math.max @UsesRemaining, 0} Groundpound uses remaining"

            ownerPos = @owner\GetPos!

            -- The player's feet are just above the ground, so we need to do a trace downwards
            tr = util.TraceLine {
                start: ownerPos + Vector 0, 0, 10
                endpos: ownerPos - Vector 0, 0, 100
                mask: MASK_PLAYERSOLID,
                filter: @owner,
            }

            sound.Play "physics/metal/metal_canister_impact_soft2.wav", ownerPos, 85, 60, 1
            sound.Play "physics/metal/metal_computer_impact_bullet2.wav", ownerPos, 85, 30, 1
            sound.Play "physics/concrete/concrete_break2.wav", ownerPos, 85, 100, 1
            sound.Play "physics/concrete/concrete_break3.wav", ownerPos, 85, 100, 1

            if speed > TERMINAL_VELOCITY * 0.65
                sound.Play "ambient/explosions/explode_3.wav", ownerPos, 90, 95, 1

            if speed >= TERMINAL_VELOCITY
                sound.Play "npc/env_headcrabcanister/explosion.wav", ownerPos, 90, 100, 1
                sound.Play "npc/dog/car_impact1.wav", ownerPos, 90, 90, 1

            with eff = EffectData!
                scaledSpeedClamped = math.min scaledSpeed, 1
                \SetOrigin tr.HitPos + tr.HitNormal
                \SetMagnitude 2.5 * scaledSpeedClamped
                \SetScale 1.75 * scaledSpeedClamped
                \SetRadius radius * 0.5
                \SetNormal tr.HitNormal
                util.Effect "Sparks", eff, true, true

                \SetScale Lerp scaledSpeed / 8, 100, 200
                util.Effect "ThumperDust", eff, true, true

                \SetFlags 0x4
                util.Effect "WaterSurfaceExplosion", eff, true, true

            if @UsesRemaining < 1
                @Remove!

            return 0

    CreateThinkWatcher: =>
        () ->
            owner = @owner

            checkCantFastFall = () ->
                return true unless owner\Alive!
                return true if owner\InVehicle!
                return true if owner\IsOnGround!
                return true if BAD_MOVETYPES[owner\GetMoveType!]
                return true unless owner\KeyDown IN_DUCK

                return false
            
            cantFastFall = checkCantFastFall!

            if cantFastFall
                if @fastFalling
                    @fastFalling = false
                    @fallSound\ChangeVolume 0, FALL_SOUND_FADE_OUT

                return

            if not @fastFalling
                @fastFalling = true
                @fallSound\ChangeVolume 1, FALL_SOUND_FADE_IN

            dt = FrameTime!
            vel = owner\GetVelocity!

            -- Downwards acceleration
            change = -@accel * dt
            vel.z = vel.z + change
            velToAdd = Vector 0, 0, change

            speedFrac = math.max -vel.z / TERMINAL_VELOCITY, 0 -- 0 to 1 based on how close to terminal velocity we are
            fallSoundPitch = Lerp speedFrac, 100, 255
            fallSoundLevel = Lerp speedFrac, 75, 100

            @owner\SetVelocity velToAdd
            @fallSound\ChangePitch fallSoundPitch, dt
            @fallSound\SetSoundLevel fallSoundLevel

            -- Rushing wind trail
            return unless TRAIL_ENABLED
            return if vel.z > -@minSpeed

            now = CurTime!
            return if now < @nextTrailTime

            @nextTrailTime = now + TRAIL_INTERVAL

            startPos = owner\GetPos! + owner\OBBCenter!
            endPos = startPos + owner\GetVelocity! * TRAIL_INTERVAL * TRAIL_LENGTH

            with eff = EffectData!
                \SetScale vel\Length! * TRAIL_SPEED
                \SetFlags 0 

                for _ = 1, TRAIL_AMOUNT
                    offset = VectorRand -TRAIL_OFFSET_SPREAD, TRAIL_OFFSET_SPREAD

                    \SetStart startPos + offset
                    \SetOrigin endPos + offset

                    util.Effect "GaussTracer", eff, true, true

            return nil -- Moon moment

    ApplyEffect: =>
        super self

        hook.Add "EntityTakeDamage", @hookName, @CreateOwnerDamageWatcher!, HOOK_HIGH -- Need to block self-damage before rocket jump addons detect the shockwave explosion
        hook.Add "EntityTakeDamage", @hookNameVictim, @CreateVictimDamageWatcher! -- Keep victim listener on normal priority, so we don't run before pvp damage blockers, etc
        hook.Add "GetFallDamage", @hookName, @CreateFallDamageWatcher!, HOOK_HIGH -- Handle shockwave before any addons mess with fall damage values and end the hook chain
        hook.Add "Think", @hookName, @CreateThinkWatcher!

        @owner\ChatPrint "You've gained #{@UsesRemaining} Groundpound uses"

    Refresh: =>
        super self

        usesGained = getConf "groundpound_uses"

        @UsesRemaining += usesGained
        @owner\ChatPrint "You've gained #{usesGained} extra Groundpound uses (total: #{@UsesRemaining})"

    Remove: =>
        super self

        hook.Remove "EntityTakeDamage", @hookName
        hook.Remove "EntityTakeDamage", @hookNameVictim
        hook.Remove "GetFallDamage", @hookName
        hook.Remove "Think", @hookName

        if IsValid @damageInflictor
            @damageInflictor\Remove!

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Groundpound Powerup"
        @fallSound\Stop!

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

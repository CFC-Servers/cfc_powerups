get: getConf = CFCPowerups.Config

TERMINAL_VELOCITY = 3500
EASE_FUNC = math.ease.InQuad
BAD_MOVETYPES = {
    MOVETYPE_NONE: true
    MOVETYPE_NOCLIP: true
    MOVETYPE_LADDER: true
    MOVETYPE_OBSERVER: true
}

FALL_SOUND_FADE_IN = 0.75
FALL_SOUND_FADE_OUT = 0.01

RADIUS_PER_DAMAGE = 2.5

-- this is applied to whatever we land on, on top of the first blastdamage
DIRECTHIT_DMG_MUL = 1 -- so 1, 2x damage  2, 3x damage, etc

TERMINAL_EXTRABLAST_DMGMUL = 75
TERMINAL_EXTRABLAST_RADIUS_MUL = 0.25

TRAIL_ENABLED = true
TRAIL_INTERVAL = 0.1
TRAIL_LENGTH = 2
TRAIL_SPEED = 2
TRAIL_OFFSET_SPREAD = 30
TRAIL_AMOUNT = 5

UP_VECTOR = Vector 0, 0, 1 

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
        @nextUpToSpeedSound = 0
        @nextUpToTerminalSpeedSound = 0
        @nextCrouchSound = 0
        @fastFalling = false
        @upToSpeedSound = false
        @upToTerminalSpeedSound

        @UsesRemaining = getConf "groundpound_uses"
        @accel = getConf "groundpound_acceleration"
        @minSpeed = getConf "groundpound_min_speed"
        @baseDamage = getConf "groundpound_base_damage"
        @addedDamage = getConf "groundpound_added_damage"
        @knockbackMult = getConf "groundpound_knockback_multiplier"
        @knockbackMax = getConf "groundpound_knockback_max"

        rf = RecipientFilter!
        rf\AddAllPlayers!

        with @damageInflictor = ents.Create "cfc_powerup_groundpound_inflictor"
            \SetOwner ply
            \Spawn!

        with @fallSound = CreateSound ply, "weapons/physcannon/superphys_hold_loop.wav", rf
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
            knockback = @knockbackMult * damageInfo\GetDamage!
            dir = victim\WorldSpaceCenter! - @owner\GetPos!

            -- Force the direction to have a significant upwards angle
            -- Otherwise, it's a coin flip between barely any movement and way too much, because of Source shenanigans
            ang = dir\Angle!
            pitch = -math.Rand 40, 60
            dir = Angle(pitch, ang.yaw, 0)\Forward!

            if victim\IsPlayer!
                clampedKnockback = math.min knockback, @knockbackMax
                velToAdd = dir * knockback + Vector 0, 0, 250 -- Still need to add some minumum upwards velocity to counteract ground stickiness

                victim\SetVelocity velToAdd
                damageInfo\SetDamageForce velToAdd * 100 -- Apply forces to the death ragdoll, in case the player dies
            else
                up = 5 * math.pow physObj\GetMass!, 0.97 -- Added up strength, now with partial mass scaling so heavy objects still move a bit
                force = dir * knockback + UP_VECTOR * up

                physObj\ApplyForceCenter force

            -- Make hitmarkers correctly display at the victim's position
            damageInfo\SetDamagePosition victim\WorldSpaceCenter!

            return nil -- Moon moment

    CreateFallDamageWatcher: =>
        (ply, speed) ->
            return unless ply == @owner
            return unless speed >= @minSpeed
            return unless @owner\KeyDown IN_DUCK -- Only trigger when crouched

            @nextUpToSpeedSound = 0
            @nextUpToTerminalSpeedSound = 0

            speedClamped = math.min speed, TERMINAL_VELOCITY
            speedZeroToOne = speedClamped / TERMINAL_VELOCITY
            speedOneToZero = 1 - speedZeroToOne

            speedOneToZero = EASE_FUNC speedOneToZero
            speedZeroToOne = EASE_FUNC speedZeroToOne

            speedAbove = speedClamped - @minSpeed
            damage = @baseDamage
            damageAdd = speedAbove * @addedDamage
            damage = damage + damageAdd

            radius = damage * RADIUS_PER_DAMAGE 

            ownersPos = @owner\WorldSpaceCenter!

            util.BlastDamage @damageInflictor, @owner, ownersPos, radius, damage

            @UsesRemaining -= 1
            @owner\ChatPrint "You have #{math.max @UsesRemaining, 0} Groundpound uses remaining"

            util.ScreenShake ownersPos, speedZeroToOne * 40, 4, 2, 1000 -- big shake close
            util.ScreenShake ownersPos, 1, 5, 5, damage * 2 -- small shake far away

            with @owner
                -- double damage for whatever we directly land on
                groundEntity = @owner\GetGroundEntity!
                if IsValid groundEntity
                    damageInfo = DamageInfo!
                    with damageInfo
                        \SetAttacker @owner
                        \SetInflictor @damageInflictor
                        \SetDamage damage * DIRECTHIT_DMG_MUL
                        \SetDamageType DMG_BLAST
                        \SetDamageForce Vector 0, 0, -damage * 10
                        \SetDamagePosition ownersPos

                    groundEntity\TakeDamageInfo damageInfo

                thumpPitch = 110 + -( speedZeroToOne * 20 )
                thumpLvl = 75 + ( speedZeroToOne * 60 )
                \EmitSound "ambient/machines/thumper_hit.wav", thumpLvl, thumpPitch, 0.5, CHAN_STATIC

                if speedClamped < TERMINAL_VELOCITY * 0.35 -- low speed hit
                    \EmitSound "ambient/machines/thumper_dust.wav", 90, 62, 1, CHAN_STATIC 

                if speedClamped > TERMINAL_VELOCITY * 0.35 -- medium speed hit
                    hitPitch = 175 + -( speedZeroToOne * 125 )
                    hitLvl = 90 + ( speedZeroToOne * 50 )
                    \EmitSound "weapons/mortar/mortar_explode2.wav", hitLvl, hitPitch

                if speedClamped > TERMINAL_VELOCITY * 0.65 -- high speed hit
                    crashPitch = 110 + -( speedZeroToOne * 40 )
                    crashLvl = 85 + ( speedZeroToOne * 60 )
                    \EmitSound "ambient/machines/wall_crash1.wav", crashLvl, crashPitch, 0.5

                if speedClamped > TERMINAL_VELOCITY * 0.9 -- all powerful hit!
                    \EmitSound "ambient/explosions/exp2.wav", 110, 30, 0.5 -- echo
                    util.BlastDamage @damageInflictor, @owner, ownersPos, radius * TERMINAL_EXTRABLAST_RADIUS_MUL, damage * TERMINAL_EXTRABLAST_DMGMUL -- OP blastdamage in a tiny, tiny radius

            timer.Simple 0, -> -- prediction...
                return unless IsValid @owner

                if speedClamped > TERMINAL_VELOCITY * 0.9
                    effDat = EffectData!
                    with effDat
                        \SetOrigin ownersPos
                        \SetEntity @owner

                        \SetScale 1
                        util.Effect "powerups_groundpound_shockwave", effDat

                        \SetScale 4
                        \SetNormal UP_VECTOR
                        util.Effect "powerups_groundpound_shockwave_huge", effDat

                else
                    effDat = EffectData!
                    effScale = speedZeroToOne * 0.5
                    effScale = effScale + 0.2
                    with effDat
                        \SetOrigin ownersPos
                        \SetNormal UP_VECTOR
                        \SetScale effScale
                        util.Effect "powerups_groundpound_shockwave", effDat

            @Remove! unless @UsesRemaining > 0

            return 0

    CantFastFall: =>
        owner = @owner

        return true unless owner\Alive!
        return true if owner\InVehicle!
        return true if owner\IsOnGround!
        return true if BAD_MOVETYPES[owner\GetMoveType!]
        return true unless owner\KeyDown IN_DUCK

        return false

    HandleFastFallChange: (cantFastFall) =>
        return if cantFastFall == @fastFalling -- No change

        if @fastFalling -- Stop fast-falling
            @fastFalling = false
            @upToSpeedSound = false
            @upToTerminalSpeedSound = false
            @fallSound\ChangeVolume 0, FALL_SOUND_FADE_OUT
        else -- Start fast-falling
            @fastFalling = true
            @fallSound\ChangeVolume 1, FALL_SOUND_FADE_IN

            now = CurTime!

            if @nextCrouchSound <= now -- sound when starting the groundpound
                @owner\EmitSound "ambient/machines/thumper_top.wav", 78, 110, 1
                @nextCrouchSound = now + 0.75 -- cooldown

    DoWindTrail: =>
        return unless TRAIL_ENABLED

        now = CurTime!
        return if now < @nextTrailTime

        @nextTrailTime = now + TRAIL_INTERVAL

        startPos = @owner\GetPos! + @owner\OBBCenter!
        endPos = startPos + @owner\GetVelocity! * TRAIL_INTERVAL * TRAIL_LENGTH

        with eff = EffectData!
            \SetScale vel\Length! * TRAIL_SPEED
            \SetFlags 0 

            for _ = 1, TRAIL_AMOUNT
                offset = VectorRand -TRAIL_OFFSET_SPREAD, TRAIL_OFFSET_SPREAD

                \SetStart startPos + offset
                \SetOrigin endPos + offset

                util.Effect "GaussTracer", eff, true, true

    DoSpeedSounds: (speed) =>
        if not @upToSpeedSound -- sound when starting to deal damage
            @upToSpeedSound = true
            if @nextUpToSpeedSound < CurTime! -- block spamming this sound
                @owner\EmitSound "weapons/mortar/mortar_shell_incomming1.wav", 120, 100, 0.5

            @nextUpToSpeedSound = CurTime! + 15
        if speed <= TERMINAL_VELOCITY and not @upToTerminalSpeedSound -- sound when hitting terminal velocity
            @upToTerminalSpeedSound = true
            if @nextUpToTerminalSpeedSound < CurTime!
                filter = RecipientFilter!
                filter\AddAllPlayers!
                @owner\EmitSound "weapons/mortar/mortar_shell_incomming1.wav", 150, 60, 0.5, CHAN_AUTO, 0, 0, filter

            @nextUpToSpeedSound = CurTime! + 15

    CreateThinkWatcher: =>
        () ->
            cantFastFall = @CantFastFall!
            @HandleFastFallChange cantFastFall

            return if cantFastFall

            dt = FrameTime!
            vel = @owner\GetVelocity!

            -- Downwards acceleration
            change = -@accel * dt
            vel.z = vel.z + change
            velToAdd = Vector 0, 0, change

            speedFrac = math.max -vel.z / TERMINAL_VELOCITY, 0 -- 0 to 1 based on how close to terminal velocity we are
            fallSoundPitch = Lerp speedFrac, 100, 200
            fallSoundLevel = Lerp speedFrac, 75, 150

            @owner\SetVelocity velToAdd
            @fallSound\ChangePitch fallSoundPitch, dt
            @fallSound\SetSoundLevel fallSoundLevel

            return if vel.z > -@minSpeed

            @DoSpeedSounds -vel.z
            @DoWindTrail!

            return nil -- Moon moment

    ApplyEffect: =>
        super self

        hook.Add "EntityTakeDamage", @hookName, @CreateOwnerDamageWatcher!, HOOK_HIGH -- Need to block self-damage before rocket jump addons detect the shockwave explosion
        hook.Add "EntityTakeDamage", @hookNameVictim, @CreateVictimDamageWatcher! -- Keep victim listener on normal priority, so we don't run before pvp damage blockers, etc
        hook.Add "GetFallDamage", @hookName, @CreateFallDamageWatcher!, HOOK_HIGH -- Handle shockwave before any addons mess with fall damage values and end the hook chain
        hook.Add "Think", @hookName, @CreateThinkWatcher!

        @owner\ChatPrint "You've gained #{@UsesRemaining} Groundpound uses, crouch in the air to activate"

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

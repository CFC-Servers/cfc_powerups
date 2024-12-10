get: getConf = CFCPowerups.Config

EASE_FUNC = math.ease.InQuad
BAD_MOVETYPES = {
    MOVETYPE_NONE: true
    MOVETYPE_NOCLIP: true
    MOVETYPE_LADDER: true
    MOVETYPE_OBSERVER: true
}

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

        with @damageInflictor = ents.Create "cfc_powerup_groundpound_inflictor"
            \SetOwner @owner
            \Spawn!

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

            if @UsesRemaining < 1
                @Remove!

            return 0

    CreateThinkWatcher: =>
        () ->
            owner = @owner

            return unless owner\Alive!
            return if owner\InVehicle!
            return if owner\IsOnGround!
            return if BAD_MOVETYPES[owner\GetMoveType!]
            return unless owner\KeyDown IN_DUCK

            dt = FrameTime!
            vel = owner\GetVelocity!

            -- Downwards acceleration
            change = -@accel * dt
            vel.z = vel.z + change
            velToAdd = Vector 0, 0, change

            @owner\SetVelocity velToAdd

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

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

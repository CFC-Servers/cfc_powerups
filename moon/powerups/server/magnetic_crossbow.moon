{get: getConf} = CFCPowerups.Config

import IsValid from _G
import SpriteTrail from util
import cos, rad from math
import FindInCone from ents
import insert, SortByMember from table

class WatchedBolt
    new: (bolt) =>
        @bolt = bolt
        @boltShooter = @bolt\GetSaveTable!["m_hOwnerEntity"]
        @holo = @createHolo!

        @movementHandler = "CFC-Powerups-TrackedBolt-#{bolt\EntIndex!}"
        @soundPath = getConf "magnetic_crossbow_magnet_sound"
        @soundId = nil

        -- A player's center of mass is ~36 units above their position
        @targetOffset = Vector 0, 0, 36
        @findAngle = cos rad 35

        @addTrail!

        timer.Create @movementHandler, 0, 0, ->
            @handleMovement!

        @bolt\CallOnRemove "CFC-Powerups-Remove-Handler", ->
            @cleanup!

    createHolo: =>
        holo = ents.Create "base_anim"
        with holo
            \SetPos @bolt\GetPos!
            \SetModel ""
            \SetRenderMode RENDERMODE_NONE
            \SetMoveType MOVETYPE_NONE
            \DrawShadow false
            \Spawn!
            \SetParent @bolt

        holo

    startSound: =>
        return if @soundId
        @soundId = @holo\StartLoopingSound @soundPath

    stopSound: =>
        return unless @soundId
        @holo\StopLoopingSound @soundId

    addTrail: =>
        lingerTime = getConf "magnetic_crossbow_effect_linger_time"
        color = Color 255, 0, 0
        texture = "trails/plasma"

        attachmentId = 0
        additive = false
        startWidth = 15
        endWidth = 1
        textureRes = 1 / ( startWidth + endWidth ) * 0.5

        SpriteTrail @holo,
                    attachmentId,
                    color,
                    additive,
                    startWidth,
                    endWidth,
                    lingerTime,
                    textureRes,
                    texture

    pointTowardsTarget: (target) =>
        targetPos = target\GetPos! + @targetOffset

        newVel = targetPos - @bolt\GetPos!
        -- We can either modify the current velocity with the difference, or halt it and start it again
        --velDiff = newVel - @bolt\GetVelocity!

        -- Halt the velocity
        @bolt\SetVelocity @bolt\GetVelocity! * -1

        -- Reset the velocity a short delay after
        timer.Simple 0.01, ->
            @bolt\SetVelocity newVel * getConf "magnetic_crossbow_speed_multiplier"

    canTargetPlayer: (ply) =>
        return false if ply == @boltShooter
        return false unless ply\IsPlayer!
        return false unless ply\Alive!
        return false unless ply\IsInPvp!
        return false unless @bolt\TestPVS ply
        true

    canTargetEnt: (ent) =>
        return false unless IsValid ent

        isValidNPC = ent\IsNPC! and ent\Health! > 0
        isValidPlayer = @canTargetPlayer ent

        isValidNPC or isValidPlayer

    -- Sorted by distance
    getPotentialTargets: =>
        origin = @bolt\GetPos!
        -- TODO: Get normalized?
        normal = @bolt\GetVelocity!
        range = getConf "magnetic_crossbow_cone_range"
        angle = cos rad getConf "magnetic_crossbow_cone_arc"

        -- TODO: Figure out if we can use range and angle in here
        potentialTargets = FindInCone origin, normal, 300, @findAngle
        eligableTargets = {}

        for target in *potentialTargets
            continue unless @canTargetEnt target
            insert eligableTargets,
                :target,
                distanceSqr: @bolt\GetPos!\DistToSqr target\WorldSpaceCenter!

        SortByMember eligableTargets, "distanceSqr"

        eligableTargets

    handleMovement: =>
        return unless IsValid @bolt
        @holo\SetPos @bolt\GetPos!

        targets = @getPotentialTargets!
        return unless targets and #targets > 0

        closestTarget = targets[1].target
        return unless IsValid closestTarget

        timer.Remove @movementHandler
        --@startSound!

        point = ->
            return unless IsValid @bolt
            return unless IsValid closestTarget
            @pointTowardsTarget closestTarget

        point!

        -- Do a second adjustment slightly after the initial adjustment
        timer.Simple 0.1, point

    cleanup: =>
        @stopSound!

        -- We delay the removal of our holo until the trails dissipate
        lingerTime = getConf "magnetic_crossbow_effect_linger_time"
        timer.Simple lingerTime, ->
            @holo\Remove!


export MagneticCrossbowPowerup
class MagneticCrossbowPowerup extends BasePowerup
    @powerupID: "powerup_magnetic_crossbow"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @PowerupHookName = "CFC-Powerups_MagneticCrossbow-#{@owner\SteamID64!}"
        @UsesRemaining = getConf "crossbow_uses"

        @ApplyEffect!

    CreateWatchedBolt: (bolt) =>
        @UsesRemaining -= 1

        WatchedBolt bolt

        if @UsesRemaining == 0
            @Remove!

    CrossbowWatcher: =>
        (ent) ->
            return unless IsValid ent
            return unless ent\GetClass! == "crossbow_bolt"

            -- Wait for it to initialize fully
            timer.Simple 0, ->
                return unless IsValid ent
                return unless ent\GetSaveTable!["m_hOwnerEntity"] == @owner

                @CreateWatchedBolt ent

    ApplyEffect: =>
        super self

        hook.Add "OnEntityCreated", @PowerupHookName, @CrossbowWatcher!

        @owner\ChatPrint "You've gained #{@UsesRemaining} Magnetic Crossbow Bolts"

    Refresh: =>
        super self

        usesGained = getConf "crossbow_uses"

        @UsesRemaining += usesGained
        @owner\ChatPrint "You've gained #{usesGained} extra Magnetic Crossbow Bolts (total: #{@UsesRemaining})"

    Remove: =>
        super self

        hook.Remove "OnEntityCreated", @PowerupHookName

        @owner\ChatPrint "You've lost the Magnetic Crossbow Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

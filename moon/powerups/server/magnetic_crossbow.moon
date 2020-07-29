{get: getConf} = CFCPowerups.Config

import SpriteTrail from util
import cos, rad from math
import FindInCone from ents
import insert, SortByMember from table

class WatchedBolt
    new: (bolt) =>
        @bolt = bolt
        @timerName = "CFC-Powerups-TrackedBolt-#{bolt\EntIndex!}"

        @addTrail!

        timer.Create @timerName, 0, 0, ->
            @handleMovement!

        bolt\CallOnRemove "CFC-Powerups-Remove-Handler", ->
            @stopWatcher!

    getBoltShooter: =>
        @bolt\GetSaveTable!["m_hOwnerEntity"]

    addTrail: =>
        SpriteTrail @bolt,
                    0,
                    Color( 255, 0, 0 ),
                    false,
                    15,
                    1,
                    4,
                    1 / (15 + 1) * 0.5,
                    "trails/plasma"

    pointTowardsTarget: (target) =>
        newVel = target\EyePos! - Vector(0, 0, 10) - @bolt\GetPos!
        velDiff = newVel - @bolt\GetVelocity!

        @bolt\SetVelocity @boly\GetVelocity! * -1

        timer.Simple 0.01, ->
            @bolt\SetVelocity newVel * getConf "magnetic_crossbow_speed_multiplier"

    canTargetPlayer: (ply) =>
        return false unless ply\IsPlayer!
        return false unless ply\Alive!
        return false unless ply\GetNWBool "CFC_PvP_Mode"
        return false if ply == @getBoltShooter!
        true

    canTargetEnt: (ent) ->
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

        potentialTargets = FindInCone origin, normal, range, angle
        eligableTargets = {}
        for target in *potentialTargets
            continue unless @canTargetEnt target
            insert eligableTargets,
                :target,
                distanceSqr: @bolt\GetPos!\DistToSqr target\EyePos!

        SortByMember eligableTargets, "distanceSqr"

        eligableTargets

    handleMovement: =>
        targets = @getPotentialTargets!
        return unless targets

        closestTarget = targets[1]
        return unless IsValid closestTarget

        @stopWatcher!

        @pointTowardsTarget closestTarget
        timer.Simple 0.1, ->
            @pointTowardsTarget closestEnt

    stopWatcher: =>
        timer.Remove @timerName


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
        @TimerName = @PowerupHookName

        @ApplyEffect!
    
    CrossbowWatcher: =>
        (ent) ->
            return unless IsValid ent
            return unless ent\GetClass! == "crossbow_bolt"
            timer.Simple 0, ->
                WatchedBolt ent

    ApplyEffect: =>
        super self

        duration = getConf "magnetic_crossbow_duration"

        hook.Add "OnEntityCreated", @PowerupHookName, @CrossbowWatcher!
        timer.Create @TimerName, duration, 1, ->
            @Remove

        @owner\ChatPrint "You've gained #{duration} seconds of the Magnetic Crossbow Powerup"

    Refresh: =>
        super self

        timer.Start @TimerName
        @owner\ChatPrint "You've refreshed the duration of the Magnetic Crossbow Powerup"

    Remove: =>
        super self

        hook.Remove "OnEntityCreated", @PowerupHookName
        timer.Remove @TimerName

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

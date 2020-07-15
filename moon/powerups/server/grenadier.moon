get: getConf = CFCPowerups.Config

import Rand, cos, sin from math
import Create from ents
import SpriteTrail from util

export GrenadierPowerup
class GrenadierPowerup extends BasePowerup
    @powerupID: "powerup_grenadier"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        duration = getConf "grenadier_duration"
        @durationTimer = "CFC_Powerups-Grenadier-#{ply\SteamID64!}"
        timer.Create @durationTimer, duration, 1, -> @Remove!

        @ApplyEffect!

    AltFireAdjustor: =>
        altFireDelay = getConf "grenadier_alt_fire_delay"

        activeWeapon = @owner\GetActiveWeapon!
        return unless activeWeapon\GetClass! == "weapon_smg1"
        return unless activeWeapon\GetNextSecondaryFire! > CurTime! + altFireDelay

        activeWeapon\SetNextSecondaryFire CurTime! + altFireDelay

    NewAltFireWatcher: =>
        (ent) ->
            return unless ent\GetClass! == "grenade_ar2"
            return unless ent\GetOwner! == @owner
            return if ent.isClustered
            -- TODO: Apply a trail and maybe a sound

    NewExplosionWatcher: =>
        (ent) ->
            return unless ent\GetClass! == "grenade_ar2"
            return unless ent\GetOwner! == @owner
            return if ent.isClustered

            distanceMin = getConf "grenadier_cluster_min_distance"
            distanceMax = getConf "grenadier_cluster_max_distance"

            heightMin = getConf "grenadier_cluster_min_height"
            heightMax = getConf "grenadier_cluster_max_height"

            clusterDelay = getConf "grenadier_cluster_delay"
            clusterCount = getConf "grenadier_cluster_count"

            impactSound = getConf "grenadier_cluster_impact_sound"
            ent\EmitSound impactSound, 150

            theta = (math.pi * 2) / clusterCount
            entPos = ent\GetPos!

            timer.Simple clusterDelay, ->
                return if ent.isClustered

                for i=1, clusterCount
                    height = Rand heightMin, heightMax
                    ang = theta * i

                    xDistance = Rand distanceMin, distanceMax
                    x = cos(ang) * xDistance

                    yDistance = Rand distanceMin, distanceMax
                    y = sin(ang) * yDistance

                    offset = Vector x, y, height
                    newPos = entPos + offset

                    cluster = Create "grenade_ar2"
                    cluster.isClustered = true
                    cluster\Spawn!
                    cluster\SetOwner @owner

                    SpriteTrail cluster, 0, Color(255, 0, 0), true, 5, 1, 1, 0.8, "smoke"

                    timer.Simple 0.01, -> cluster.isClustered = true

                    cluster\SetPos entPos
                    cluster\SetVelocity (newPos - entPos) * 5

    ApplyEffect: =>
        -- Watch for new smgalts and set trail + properties
        -- Watch for smgalt explosions, create cluster nades
        -- Create timer to reduce smg's altfire delay

        steamID = @owner\SteamID64!

        @explosionWatcher = "CFC_Powerups-Grenadier-ExplosionWatcher-#{steamID}"
        hook.Add "EntityRemoved", @explosionWatcher, @NewExplosionWatcher!

        @altFireWatcher = "CFC_Powerups-Grenadier-AltFireWatcher-#{steamID}"
        hook.Add "OnEntityCreated", @altFireWatcher, @NewAltFireWatcher!

        @adjustorTimer = "CFC_Powerups-Grenadier-AltFireAdjustor-#{steamID}"
        timer.Create @adjustorTimer, 0.1, 0, -> @AltFireAdjustor!

        smg1 = "weapon_smg1"
        smg1ammo = 9

        with @owner
            \Give smg1
            \GiveAmmo 15, smg1ammo, true
            \SelectWeapon smg1
            \ChatPrint "You've gained #{getConf "grenadier_duration"} seconds of the Grenadier Powerup"

    Refresh: =>
        timer.Start @durationTimer
        @owner\ChatPrint "You've refreshed your duration of the Grenadier Powerup"

    Remove: =>
        timer.Remove @durationTimer
        timer.Remove @adjustorTimer
        hook.Remove "EntityRemoved", @explosionWatcher
        hook.Remove "OnEntityCreated", @altFireWatcher

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Grenadier Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

hook.Add "EntityTakeDamage", "CFC_Powerups-Grenadier-PreventChainExplosion", (ent, damageInfo) ->
    return unless ent\GetClass! == "grenade_ar2"
    return unless ent.isClustered

    inflictorClass = damageInfo\GetInflictor!\GetClass!
    return true if inflictorClass == "grenade_ar2"

{get: getConf} = CFCPowerups.Config

import ShotgunPowerupHandler from CFCPowerups.SharedHandlers

util.AddNetworkString "CFC_Powerups-Shotgun-Start"
util.AddNetworkString "CFC_Powerups-Shotgun-Stop"

export ShotgunPowerup
class ShotgunPowerup extends BasePowerup
    @powerupID: "powerup_shotgun"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @ownerSteamID64 = @owner\SteamID64!

        @duration = getConf "shotgun_duration"
        @singleBulletsMin = getConf "shotgun_single_bullets_min"
        @singleBulletsMax = getConf "shotgun_single_bullets_max"
        @singleDamageMult = getConf "shotgun_single_damage_multiplier"
        @singleSpreadMult = getConf "shotgun_single_spread_multiplier"
        @singleSpreadAdd = getConf "shotgun_single_spread_add"
        @multiBulletsMult = getConf "shotgun_multi_bullets_multiplier"
        @multiDamageMult = getConf "shotgun_multi_damage_multiplier"

        @timerName = "CFC-Powerups_Shotgun-#{@ownerSteamID64}"
        @handler = ShotgunPowerupHandler ply, @singleBulletsMin, @singleBulletsMax, @singleDamageMult, @singleSpreadMult, @singleSpreadAdd, @multiBulletsMult, @multiDamageMult

        @ApplyEffect!

    ApplyEffect: =>
        super self

        timer.Create @timerName, @duration, 1, -> @Remove!

        -- Need to network to all clients so they can predict the new bullets correctly.
        -- However, this isn't using NW or NW2, so players who join after won't see it correctly.
        -- But that is preferable to using NW/NW2 slots, a permanent EFB hook listener, and needing to re-check the convars on client.
        net.Start "CFC_Powerups-Shotgun-Start"
        net.WriteString @ownerSteamID64
        net.WriteUInt @singleBulletsMin, 7
        net.WriteUInt @singleBulletsMax, 7
        net.WriteFloat @singleDamageMult
        net.WriteFloat @singleSpreadMult
        net.WriteFloat @singleSpreadAdd
        net.WriteFloat @multiBulletsMult
        net.WriteFloat @multiDamageMult
        net.Broadcast!

        @owner\ChatPrint "You've gained #{@duration} seconds of the Shotgun powerup"

    Remove: =>
        super self

        timer.Remove @timerName

        @handler\Remove!
        @handler = nil

        net.Start "CFC_Powerups-Shotgun-Stop"
        net.WriteString @ownerSteamID64
        net.Broadcast!

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Shotgun powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

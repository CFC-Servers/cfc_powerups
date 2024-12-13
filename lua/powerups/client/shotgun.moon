import ShotgunPowerupHandler from CFCPowerups.SharedHandlers

shotguns = {}

removeShotgun = (ownerSteamID64) ->
    shotgun = shotguns[ownerSteamID64]
    return unless shotgun

    shotgun\Remove!
    shotguns[ownerSteamID64] = nil

net.Receive "CFC_Powerups-Shotgun-Start", ->
    ownerSteamID64 = net.ReadString!
    singleBulletsMin = net.ReadUInt 7
    singleBulletsMax = net.ReadUInt 7
    singleDamageMult = net.ReadFloat!
    singleSpreadMult = net.ReadFloat!
    singleSpreadAdd = net.ReadFloat!
    multiBulletsMult = net.ReadFloat!
    multiDamageMult = net.ReadFloat!

    removeShotgun ownerSteamID64 -- Just in case

    owner = player.GetBySteamID64 ownerSteamID64
    return unless IsValid owner

    shotguns[ownerSteamID64] = ShotgunPowerupHandler owner, singleBulletsMin, singleBulletsMax, singleDamageMult, singleSpreadMult, singleSpreadAdd, multiBulletsMult, multiDamageMult

net.Receive "CFC_Powerups-Shotgun-Stop", ->
    ownerSteamID64 = net.ReadString!

    removeShotgun ownerSteamID64

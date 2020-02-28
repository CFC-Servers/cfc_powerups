
AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

ENT.PowerupEffect = (ply) =>
    maxHp = 150
    powerupDuration = 300
    regenInterval = 0.1
    regenAmount = 3

    timerName = "#{ply\SteamID64!}-Regen-Powerup"

    @PowerupInfo.RegenSound = CreateSound ply, "items/medcharge4.wav"
    @PowerupInfo.PlayingRegenSound = false

    powerupTick = ->
        hp = ply\Health!
        powerup = ply\GetPowerUp @PowerupName

        if hp < maxHp
            if not powerup.PlayingRegenSound
                powerup.RegenSound\Play!
                powerup.PlayingRegenSound = true

            newHp = math.Clamp hp + regenAmount, 0, maxHp

            ply\SetHealth newHp

        else
            if powerup.PlayingRegenSound
                powerup.RegenSound\Stop!
                powerup.PlayingRegenSound = false

    timer.Create timerName, regenInterval, powerupDuration / regenInterval, powerupTick

    @PowerupInfo.RemovePowerup = =>
        timer.Remove timerName

        powerup = ply\GetPowerup ENT.PowerupName
        powerup.RegenSound\Stop!

        ply\ChatPrint "You've lost the Regen Powerup"

    removalTimer = timerName .. "-Removal"
    timer.Create removalTimer, powerupDuration, 1, @PowerupInfo.RemovePowerup

ENT.RefreshPowerup = (ply) =>
    timername = "#{ply\SteamID64!}-Regen-Powerup"

    timer.Start( timerName )

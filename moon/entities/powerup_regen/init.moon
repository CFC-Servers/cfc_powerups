AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

ENT.PowerupEffect = (ply) =>
    maxHp = 150
    powerupDuration = 300
    regenInterval = 0.1
    regenAmount = 3

    timerName = "#{ply\SteamID!}-Regen-Powerup"

    ply.RegenSound = CreateSound ply, "items/medcharge4.wav"
    ply.PlayingRegenSound = false

    powerupTick = ->
        hp = ply\Health!

        if hp < maxHp
            if not ply.PlayingRegenSound
                ply.RegenSound\Play!
                ply.PlayingRegenSound = true

            newHp = math.Clamp hp + regenAmount, 0, maxHp

            ply\SetHealth newHp

        else
            if ply.PlayingRegenSound
                ply.RegenSound\Stop!
                ply.PlayingRegenSound = false

    timer.Create timerName, regenInterval, powerupDuration / regenInterval, powerupTick

    ply.RemovePowerup = =>
        timer.Remove timerName
        @RegenSound = nil
        @PlayingRegenSound = nil
        @RemovePowerup = nil

    removalTimer = timerName .. "-Removal"
    timer.Create removalTimer, powerupDuration, 1, ply.RemovePowerup

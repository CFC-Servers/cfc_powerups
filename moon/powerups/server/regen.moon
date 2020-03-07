include "base.lua"

MAX_HP = 150
POWERUP_DURATION = 300 -- In seconds
REGEN_INTERVAL = 0.1 -- How often to apply the regen, in seconds
REGEN_AMOUNT = 3 -- How much health to apply every REGEN_INTERVAL

export RegenPowerup
class RegenPowerup extends BasePowerup
    ID: "regen-powerup"

    new: (ply) =>
        @owner = ply
        @timerName = "CFC_Powerups-Regen-#{ply\SteamID64!}"

        timerDuration = POWERUP_DURATION / REGEN_INTERVAL
        timer.Create @timerName, REGEN_INTERVAL, timerDuration, @PowerupTick

    PowerupTick: =>
        plyHealth = @owner\Health!

        if plyHealth < MAX_HP
            if not @PlayingRegenSound
                @RegenSound\Play!
                @PlayingRegenSound = true

            newHealth = math.Clamp plyHealth + REGEN_AMOUNT, 0, MAX_HP

            @owner\SetHealth newHealth

        else
            if @PlayingRegenSound
                @RegenSound\Stop!
                @PlayingRegenSound = false

    Refresh: =>
        timer.Start @timerName

    Remove: =>
        @RegenSound\Stop!
        timer.Remove @timerName

        if not IsValid(@owner) return

        -- Make sure they don't have more 100 HP
        plyHealth = @owner\Health!
        if plyHealth > 100
            @owner\SetHealthj 100

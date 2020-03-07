include "base.lua"

POWERUP_ID = "regen-powerup"

MAX_HP = 150
POWERUP_DURATION = 300 -- In seconds
REGEN_INTERVAL = 0.1 -- How often to apply the regen, in seconds
REGEN_AMOUNT = 3 -- How much health to apply every REGEN_INTERVAL

export RegenPowerup
class RegenPowerup extends BasePowerup
    new: (ply) =>
        super ply

        @timerName = "CFC_Powerups-Regen-#{ply\SteamID64!}"

        timerDuration = POWERUP_DURATION / REGEN_INTERVAL
        timer.Create @timerName, REGEN_INTERVAL, timerDuration, @PowerupTick!

    PowerupTick: =>
        powerup = self

        return ->
            plyHealth = powerup.owner\Health!

            if plyHealth < MAX_HP
                if not powerup.PlayingRegenSound
                    powerup.RegenSound\Play!
                    powerup.PlayingRegenSound = true

                newHealth = math.Clamp plyHealth + REGEN_AMOUNT, 0, MAX_HP

                powerup.owner\SetHealth newHealth

            else
                if powerup.PlayingRegenSound
                    powerup.RegenSound\Stop!
                    powerup.PlayingRegenSound = false

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

CFCPowerups[POWERUP_ID] = RegenPowerup

{get: getConf} = CFCPowerups.Config

export RegenPowerup
class RegenPowerup extends BasePowerup
    @powerupID: "powerup_regen"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @timerName = "CFC_Powerups-Regen-#{ply\SteamID64!}"

        duration = getConf "regen_duration"
        interval = getConf "regen_interval"

        timerDuration = duration / interval
        timer.Create @timerName, interval, timerDuration, @PowerupTick!

        @RegenSound = CreateSound @owner, getConf "regen_sound"

    PowerupTick: =>
        powerup = self

        return ->
            plyHealth = powerup.owner\Health!
            maxHP = getConf "regen_max_hp"

            if plyHealth < maxHP
                if not powerup.PlayingRegenSound
                    powerup.RegenSound\Play!
                    powerup.PlayingRegenSound = true

                amount = getConf "regen_amount"
                newHP = plyHealth + amount

                newHealth = math.Clamp newHP, 0, maxHP

                powerup.owner\SetHealth newHealth

            else
                return unless powerup.PlayingRegenSound

                powerup.RegenSound\Stop!
                powerup.PlayingRegenSound = false

    Refresh: =>
        timer.Start @timerName

    Remove: =>
        @RegenSound\Stop!
        timer.Remove @timerName

        return unless IsValid @owner

        -- Make sure they don't have more 100 HP
        plyHealth = @owner\Health!
        @owner\SetHealth 100 if plyHealth > 100

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

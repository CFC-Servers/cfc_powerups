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

        @timerNameTick = "CFC_Powerups-Regen-Tick-#{ply\SteamID64!}"
        @timerNameRemove = "CFC_Powerups-Regen-Remove-#{ply\SteamID64!}"

        @ApplyEffect!

    ApplyEffect: =>
        super self

        duration = getConf "regen_duration"
        interval = getConf "regen_interval"

        repetitions = duration / interval
        timer.Create @timerNameTick, interval, repetitions, @PowerupTick!
        timer.Create @timerNameRemove, duration, 1, -> @Remove!

        @RegenSound = CreateSound @owner, getConf "regen_sound"
        @owner\ChatPrint "You've gained #{duration} seconds of the Regen Powerup"


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
        super self

        duration = getConf "regen_duration"
        interval = getConf "regen_interval"

        -- timer.Start() doesn't reset the repetitions to its original value, the tick timer has to be re-created.
        repetitions = duration / interval
        timer.Create @timerNameTick, interval, repetitions, @PowerupTick!
        timer.Start @timerNameRemove

        @owner\ChatPrint "You've refreshed the duration of the Regen Powerup"

    Remove: =>
        super self
        @RegenSound\Stop!
        timer.Remove @timerNameTick
        timer.Remove @timerNameRemove

        return unless IsValid @owner

        @owner\ChatPrint "You've lost the Regen Powerup"

        -- Make sure they don't have more 100 HP
        plyHealth = @owner\Health!
        @owner\SetHealth 100 if plyHealth > 100

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

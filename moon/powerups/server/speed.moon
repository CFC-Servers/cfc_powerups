{get: getConf} = CFCPowerups.Config

export SpeedPowerup
class SpeedPowerup extends BasePowerup
    @powerupID: "powerup_speed"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @timerNameTick = "CFC_Powerups-Speed-Tick-#{ply\SteamID64!}"
        @timerNameRemove = "CFC_Powerups-Speed-Remove-#{ply\SteamID64!}"

        duration = getConf "speed_duration"
        interval = getConf "speed_interval"

        repetitions = duration / interval
        timer.Create @timerNameTick, interval, repetitions, @PowerupTick!
        timer.Create @timerNameRemove, duration, 1, -> @Remove!

        @baseDuckSpeed = @owner\GetDuckSpeed!
        @baseUnDuckSpeed = @owner\GetUnDuckSpeed!
        @baseCrouchedWalkSpeed = @owner\GetCrouchedWalkSpeed!
        @baseSlowWalkSpeed = @owner\GetSlowWalkSpeed!
        @baseWalkSpeed = @owner\GetWalkSpeed!
        @baseRunSpeed = @owner\GetRunSpeed!
        @baseLadderClimbSpeed = @owner\GetLadderClimbSpeed!
        @baseMaxSpeed = @owner\GetMaxSpeed!

        @ApplyEffect!

    ApplyEffect: =>
        super self
        with @owner
            speedMultiplier = getConf "speed_multiplier"

            \SetDuckSpeed @baseDuckSpeed * speedMultiplier
            \SetUnDuckSpeed @baseUnDuckSpeed * speedMultiplier
            \SetCrouchedWalkSpeed @baseCrouchedWalkSpeed * speedMultiplier
            \SetSlowWalkSpeed @baseSlowWalkSpeed * speedMultiplier
            \SetWalkSpeed @baseWalkSpeed * speedMultiplier
            \SetRunSpeed @baseRunSpeed * speedMultiplier
            \SetLadderClimbSpeed @baseLadderClimbSpeed * speedMultiplier
            \SetMaxSpeed @baseMaxSpeed * speedMultiplier

            \ChatPrint "You've gained #{getConf "speed_duration"} seconds of the Speed Powerup"

    PowerupTick: =>
        powerup = self

        return ->
            -- If the player is back to their normal speed, then re-apply the speed boost
            -- This is to account for other addons that might change the player's speed (weapon weight, charge weapons, etc)
            return unless powerup.owner\GetRunSpeed! == powerup.baseRunSpeed

            powerup.ApplyEffect!

    Refresh: =>
        super self
        
        duration = getConf "speed_duration"
        interval = getConf "speed_interval"

        -- timer.Start() doesn't reset the repetitions to its original value, the tick timer has to be re-created.
        repetitions = duration / interval
        timer.Create @timerNameTick, interval, repetitions, @PowerupTick!
        timer.Start @timerNameRemove

        @owner\ChatPrint "You've refreshed your duration of the Speed Powerup"

    Remove: =>
        super self

        timer.Remove @timerNameTick
        timer.Remove @timerNameRemove

        return unless IsValid @owner

        with @owner
            \SetDuckSpeed @baseDuckSpeed
            \SetUnDuckSpeed @baseUnDuckSpeed
            \SetCrouchedWalkSpeed @baseCrouchedWalkSpeed
            \SetSlowWalkSpeed @baseSlowWalkSpeed
            \SetWalkSpeed @baseWalkSpeed
            \SetRunSpeed @baseRunSpeed
            \SetLadderClimbSpeed @baseLadderClimbSpeed
            \SetMaxSpeed @baseMaxSpeed

            \ChatPrint "You've lost the Speed Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

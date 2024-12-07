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

        @timerName = "CFC_Powerups-Speed-#{ply\SteamID64!}"

        duration = getConf "speed_duration"

        timer.Create @timerName, duration, 1, -> @Remove!

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

    Refresh: =>
        super self
        timer.Start @timerName
        @owner\ChatPrint "You've refreshed your duration of the Speed Powerup"

    Remove: =>
        super self
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

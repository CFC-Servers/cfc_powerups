get: getConf = CFCPowerups.Config

export SpeedPowerup
class SpeedPowerup extends BasePowerup
    @powerupID: "base_cfc_powerup"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @timerName = "CFC_Powerups-Speed-#{ply\SteamID64!}"

        duration = getConf "speed_duration"

        timer.Create @timerName, duration, 1, -> @Remove

    ApplyEffect: =>
        with @owner
            .baseDuckSpeed = @owner\GetDuckSpeed!
            .baseUnduckSpeed = @owner\GetUnduckSpeed!
            .baseCrouchedWalkSpeed = @owner\GetCrouchedWalkSpeed!
            .baseSlowWalkSpeed = @owner\GetSlowWalkSpeed!
            .baseWalkSpeed = @owner\GetWalkSpeed!
            .baseRunSpeed = @owner\GetRunSpeed!
            .baseLadderClimbSpeed = @owner\GetladderClimbSpeed!
            .baseMaxSpeed = @owner\GetMaxSpeed!

            speedMultiplier = getConf "speed_multiplier"

            \SetDuckSpeed .baseDuckSpeed * speedMultiplier
            \SetUnuckSpeed .baseUnduckSpeed * speedMultiplier
            \SetCrouchedWalkSpeed .baseCrouchedWalkSpeed * speedMultiplier
            \SetSlowWalkSpeed .baseSlowWalkSpeed * speedMultiplier
            \SetWalkSpeed .baseWalkSpeed * speedMultiplier
            \SetRunSpeed .baseRunSpeed * speedMultiplier
            \SetLadderClimbSpeed .baseLadderClimbSpeed * speedMultiplier
            \SetMaxSpeed .baseMaxSpeed * speedMultiplier

    Refresh: =>
        timer.Start @timerName

    Remove: =>
        with @owner
            \SetDuckSpeed .baseDuckSpeed
            \SetUnuckSpeed .baseUnduckSpeed
            \SetCrouchedWalkSpeed .baseCrouchedWalkSpeed
            \SetSlowWalkSpeed .baseSlowWalkSpeed
            \SetWalkSpeed .baseWalkSpeed
            \SetRunSpeed .baseRunSpeed
            \SetLadderClimbSpeed .baseLadderClimbSpeed
            \SetMaxSpeed .baseMaxSpeed
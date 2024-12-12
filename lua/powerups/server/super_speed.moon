{get: getConf} = CFCPowerups.Config

export SuperSpeedPowerup
class SuperSpeedPowerup extends BasePowerup
    @powerupID: "powerup_super_speed"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        -- Super Speed overtake Speed
        speedPowerup = ply.Powerups.powerup_speed
        speedPowerup\Remove! if speedPowerup

        @timerNameTick = "CFC_Powerups-SuperSpeed-Tick-#{ply\SteamID64!}"
        @timerNameRemove = "CFC_Powerups-SuperSpeed-Remove-#{ply\SteamID64!}"

        duration = getConf "super_speed_duration"
        interval = getConf "super_speed_interval"

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

        @owner\ChatPrint "You've gained #{duration} seconds of the Super Speed Powerup"

        @ApplyEffect!

    ApplyEffect: =>
        super self
        with @owner
            super_speedMultiplier = getConf "super_speed_multiplier"

            \SetDuckSpeed @baseDuckSpeed * super_speedMultiplier
            \SetUnDuckSpeed @baseUnDuckSpeed * super_speedMultiplier
            \SetCrouchedWalkSpeed @baseCrouchedWalkSpeed * super_speedMultiplier
            \SetSlowWalkSpeed @baseSlowWalkSpeed * super_speedMultiplier
            \SetWalkSpeed @baseWalkSpeed * super_speedMultiplier
            \SetRunSpeed @baseRunSpeed * super_speedMultiplier
            \SetLadderClimbSpeed @baseLadderClimbSpeed * super_speedMultiplier
            \SetMaxSpeed @baseMaxSpeed * super_speedMultiplier

    PowerupTick: =>
        powerup = self

        return ->
            -- If the player is back to their normal super_speed, then re-apply the super_speed boost
            -- This is to account for other addons that might change the player's super_speed (weapon weight, charge weapons, etc)
            return unless powerup.owner\GetRunSpeed! == powerup.baseRunSpeed

            powerup\ApplyEffect!

    Refresh: =>
        super self
        
        duration = getConf "super_speed_duration"
        interval = getConf "super_speed_interval"

        -- timer.Start() doesn't reset the repetitions to its original value, the tick timer has to be re-created.
        repetitions = duration / interval
        timer.Create @timerNameTick, interval, repetitions, @PowerupTick!
        timer.Start @timerNameRemove

        @owner\ChatPrint "You've refreshed your duration of the Super Speed Powerup"

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

            \ChatPrint "You've lost the Super Speed Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

hook.Add "CFC_Powerups_DisallowGetPowerup", "CFC_Powerups-SuperSpeed-BlockSpeed", (_, powerupId) ->
    return unless powerupId == "powerup_speed"
    superSpeedPowerup = ply.Powerups.powerup_super_speed
    return unless superSpeedPowerup

    return true, "Super Speed cannot be replaced with Speed"

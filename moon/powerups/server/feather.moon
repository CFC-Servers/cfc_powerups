get: getConf = CFCPowerups.Config

export FeatherPowerup
class FeatherPowerup extends BasePowerup
    @powerupID: "powerup_feather"

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    new: (ply) =>
        super ply

        @timerName = "CFC_Powerups-Feather-#{ply\SteamID64!}"

        duration = getConf "feather_duration"

        timer.Create @timerName, duration, 1, -> @Remove

        @ApplyEffect!

    CreateDamageWatcher: =>
        (ply, damageInfo) ->
            return unless ply == @owner
            return unless damageInfo\IsFallDamage!

            -- Blocks fall damage
            return true

    ApplyEffect: =>
        gravityMult = getConf "feather_gravity_multiplier"
        baseGravity = @owner\GetGravity!

        newGravity = baseGravity * gravityMult

        hook.Add "EntityTakeDamage", @timerName, @CreateDamageWatcher!

        with @owner
            .baseGravity = baseGravity
            \SetGravity newGravity
            \ChatPrint "You've gained #{getConf "feather_duration"} seconds of the Feather Powerup"

    Refresh: =>
        timer.Start @timerName
        @owner\ChatPrint "You've refreshed your duration of the Feather Powerup"

    Remove: =>
        timer.Remove @timerName
        hook.Remove "EntityTakeDamage", @timerName

        return unless IsValid @owner

        with @owner
            \SetGravity .baseGravity

        @owner\ChatPrint "You've lost the Feather Powerup"

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

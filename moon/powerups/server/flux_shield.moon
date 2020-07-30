export FluxShieldPowerup
class FluxShieldPowerup extends BasePowerup
    @powerupID: "flux_shield_powerup"
    
    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    @IsRefreshable = false

    new: (ply) =>
        super ply

        @damageScale = 1
        @scaleDirection = "increasing"

        @duration = getConf "flux_shield_duration"
        @maxReduction = getConf "flux_shield_max_reduction"
        @tickInterval = getConf "flux_shield_tick_interval"
        @totalTicks = @duration / @tickInterval
        @changePerTick = ( @maxReduction / ( @totalTicks / 2 ) ) / 100

        @durationTimer = "CFC-Powerups_FluxShield-#{@owner\SteamID64!}"
        @tickTimer = "#{@durationTimer}-tick"
        @flipTimer = "#{@durationTimer}-flipper"
        @hookName = @durationTimer

        @ApplyEffect!

    PowerupTick: =>
        if @scaleDirection == "increasing"
            @damageScale -= @changePerTick
        else
            @damageScale += @changePerTick

        print "New Damage scale: #{@damageScale}"

    DamageWatcher: =>
        (ent, dmg) ->
            return unless ent == @owner

            @owner\ChatPrint "Modifying #{Round dmg\GetDamage!} damage by #{Round @damageScale}"
            dmg\ScaleDamage @damageScale

    ApplyEffect: =>
        super self

        timer.Create @durationTimer, @duration, 1, -> @Remove!
        timer.Create @tickTimer, @tickInterval, @totalTicks, -> @PowerupTick!
        timer.Create @flipTimer, @duration / 2, 1, ->
            @scaleDirection = "decreasing"

        hook.Add "EntityTakeDamage", @hookName, @DamageWatcher!

        @owner\ChatPrint "You've gained #{@duration} seconds of the Flux Armor powerup"

    Remove: =>
        super self

        timer.Remove @durationTimer
        timer.Remove @tickTimer
        timer.Remove @flipTimer
        hook.Remove "EntityTakeDamage", @hookName

        @owner\ChatPrint "You've lost the Flux Armor powerup"

CFCPowerups[BasePowerup.powerupID] = FluxShieldPowerup

{get: getConf} = CFCPowerups.Config

import Clamp, Round from math

util.AddNetworkString "CFC_Powerups-FluxShield-Start"
util.AddNetworkString "CFC_Powerups-FluxShield-Stop"

export FluxShieldPowerup
class FluxShieldPowerup extends BasePowerup
    @powerupID: "powerup_flux_shield"
    
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

    StartScreenEffect: =>
        net.Start "CFC_Powerups-FluxShield-Start"
        net.WriteUInt @duration, 10
        net.WriteUInt @maxReduction, 7
        net.WriteFloat @tickInterval
        net.Send @owner

    StopScreenEffect: =>
        net.Start "CFC_Powerups-FluxShield-Stop"
        net.Send @owner

    PowerupTick: =>
        if @scaleDirection == "increasing"
            @damageScale -= @changePerTick
        else
            @damageScale += @changePerTick

        @damageScale = Clamp @damageScale, 0, 1

        print "New Damage scale: #{@damageScale}"

    DamageWatcher: =>
        (ent, dmg) ->
            return unless ent == @owner

            @owner\ChatPrint "Reducing #{Round dmg\GetDamage!} damage by #{100 - Round(@damageScale * 100)}%"
            dmg\ScaleDamage @damageScale

    ApplyEffect: =>
        super self

        timer.Create @durationTimer, @duration, 1, -> @Remove!
        timer.Create @tickTimer, @tickInterval, @totalTicks, -> @PowerupTick!
        timer.Create @flipTimer, @duration / 2, 1, ->
            @scaleDirection = "decreasing"

        hook.Add "EntityTakeDamage", @hookName, @DamageWatcher!

        @StartScreenEffect!

        @owner\ChatPrint "You've gained #{@duration} seconds of the Flux Armor powerup"

    Remove: =>
        super self

        timer.Remove @durationTimer
        timer.Remove @tickTimer
        timer.Remove @flipTimer
        hook.Remove "EntityTakeDamage", @hookName

        @StopScreenEffect!

        @owner\ChatPrint "You've lost the Flux Armor powerup"
        @owner.Powerups[@@powerupID] = nil

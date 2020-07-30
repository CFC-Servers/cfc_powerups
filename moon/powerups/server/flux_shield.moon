{get: getConf} = CFCPowerups.Config

import Round from math

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

        print @duration, @maxReduction, @tickInterval, @totalTicks, @changePerTick

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

            @owner\ChatPrint "Reducing #{Round dmg\GetDamage!} damage by #{100 - Round(@damageScale * 100)}%"
            dmg\ScaleDamage @damageScale

    ScreenEffect: =>
        () ->
            alpha = (@maxReduction / 100) / @damageScale

			--DrawBloom(alpha * 0.3, alpha * 2, alpha * 8, alpha * 8, 15, 1, 0, 0.8, 1)
			DrawSharpen 0.2 * alpha, 10 * alpha
			DrawSunbeams 1 * alpha, alpha, 0.08 * alpha, 0, 0

			DrawMaterialOverlay "effects/CombineShield/comshieldwall", -0.2 * alpha

			local tab = {}
			tab["$pp_colour_colour"] = alpha
			tab["$pp_colour_contrast"] = math.Clamp(2 * alpha, 1, 2)
			tab["$pp_colour_brightness"] = math.Clamp(-0.3 * alpha, -1, 1)
			tab["$pp_colour_addb"] = 0.3 * alpha
			tab["$pp_colour_addg"] = 0.2 * alpha
			DrawColorModify(tab)


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
        @owner.Powerups[@@powerupID] = nil

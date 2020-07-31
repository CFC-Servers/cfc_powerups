--TODO: Can we DRY this a bit? Lots of overlap with serverside code

import Clamp from math

local currentFluxShield

class FluxShield
    new: (duration, maxReduction, tickInterval) =>
        @damageScale = 1
        @scaleDirection = "increasing"

        @duration = duration
        @maxReduction = maxReduction
        @tickInterval = tickInterval

        @totalTicks = @duration / @tickInterval
        @changePerTick = ( @maxReduction / ( @totalTicks / 2 ) ) / 100

        @durationTimer = "CFC-Powerups_FluxShield"
        @tickTimer = "#{@durationTimer}-tick"
        @flipTimer = "#{@durationTimer}-flipper"
        @hookName = @durationTimer

        @ApplyEffect!

    PowerupTick: =>
        if @scaleDirection == "increasing"
            @damageScale -= @changePerTick
        else
            @damageScale += @changePerTick

        @damageScale = Clamp @damageScale, 0, 1

    DrawOverlay: (alpha) =>
		render.UpdateScreenEffectTexture!

		overlay = Material "effects/combine_binocoverlay"
		clampedAlpha = Clamp alpha, 0, 0.6

		with overlay
            \SetFloat "$alpha", clampedAlpha
            \SetFloat "$envmap", 0
            \SetFloat "$envmaptint", 0
            \SetFloat "$refractamount", 0
            \SetInt "$ignorez", 1

		render.SetMaterial overlay
		render.DrawScreenQuad!

    ScreenEffect: =>
        ->
            alpha = ( 1 - @damageScale ) / ( @maxReduction / 100 )

            --DrawBloom(alpha * 0.3, alpha * 2, alpha * 8, alpha * 8, 15, 1, 0, 0.8, 1)
            DrawSharpen 0.2 * alpha, 5 * alpha
            -- DrawSunbeams 0.1 * alpha, alpha, 0.08 * alpha, 0, 0

            --DrawMaterialOverlay "effects/CombineShield/comshieldwall", -0.4 * alpha
            @DrawOverlay alpha

            minColor = 0.1
            maxContrast = 1.4
            minBrightness = -0.3

            tab = {}
            tab["$pp_colour_colour"] = Clamp 1 - alpha, minColor, 1
            tab["$pp_colour_contrast"] = 1 + alpha, 1, maxContrast
            tab["$pp_colour_brightness"] = Clamp -0.3 * alpha, minBrightness, 1
            --tab["$pp_colour_addb"] = 0.3 * alpha
            --tab["$pp_colour_addg"] = 0.2 * alpha

            DrawColorModify tab

    ApplyEffect: =>
        timer.Create @durationTimer, @duration, 1, -> @Remove!
        timer.Create @tickTimer, @tickInterval, @totalTicks, -> @PowerupTick!
        timer.Create @flipTimer, @duration / 2, 1, ->
            @scaleDirection = "decreasing"

        hook.Add "RenderScreenspaceEffects", @hookName, @ScreenEffect!

    Remove: =>
        timer.Remove @durationTimer
        timer.Remove @tickTimer
        timer.Remove @flipTimer
        hook.Remove "RenderScreenspaceEffects", @hookName

net.Receive "CFC_Powerups-FluxShield-Start", ->
    duration = net.ReadUInt 10
    maxReduction = net.ReadUInt 7
    tickInterval = net.ReadFloat!

    print duration, maxReduction, tickInterval

    currentFluxShield = FluxShield duration, maxReduction, tickInterval

net.Receive "CFC_Powerups-FluxShield-Stop", ->
    return unless currentFluxShield
    currentFluxShield\Remove!
    currentFluxShield = nil

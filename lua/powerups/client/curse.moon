import Clamp from math

EMITTER_INTERVAL = 0.1
EMITTER_LIFE = 5
EMITTER_AMOUNT = 7
EMITTER_GRAVITY = Vector 0, 0, 0
EMITTER_SPREAD_XY = 1.25
EMITTER_SPREAD_Z = 0.75
EMITTER_SPREAD_FROM_TOP = false
EMITTER_SPEED_MIN = 5
EMITTER_SPEED_MAX = 10
EMITTER_AIR_RESISTANCE = 3

EMITTER_OPTIONS = {
    {
        mat: "particle/particle_smokegrenade"
        color: Color 32, 0, 65
        colorIntensityMin: 0
        colorIntensityMax: 1
        startSize: 10
        endSize: 10
        weight: 50
    },
    {
        mat: "sprites/orangeflare1"
        color: Color 50, 0, 200
        colorIntensityMin: 0.75
        colorIntensityMax: 1
        startSize: 0
        endSize: 10
        weight: 5
    },
    {
        mat: "sprites/glow04_noz_gmod"
        color: Color 125, 0, 200
        colorIntensityMin: 0.5
        colorIntensityMax: 1
        startSize: 0
        endSize: 10
        weight: 5
    },
}

BEAM_MAT = Material "sprites/physbeama"
BEAM_WIDTH = 30
BEAM_DURATION = 1.5
BEAM_COLOR = Color 100, 0, 255

ANGLE_ZERO = Angle 0, 0, 0

emitters = {}
emitterOwners = {}
beams = {}
emitterWeightTotals = {}
emitterTotalWeight = 0

for option in *EMITTER_OPTIONS
    emitterTotalWeight = emitterTotalWeight + option.weight
    table.insert emitterWeightTotals, emitterTotalWeight


removeEmitter = (ownerSteamID64) ->
    emitter = emitters[ownerSteamID64]
    return unless emitter

    emitter\Finish!
    emitters[ownerSteamID64] = nil
    emitterOwners[ownerSteamID64] = nil

makeEmitter = (ply, steamID64) ->
    emitter = ParticleEmitter ply\GetPos!, false
    emitters[steamID64] = emitter
    emitterOwners[steamID64] = ply

    emitter\SetNoDraw true

makeBeam = (startPos, endPos) ->
    table.insert beams, {
        startPos: startPos
        endPos: endPos
        startTime: CurTime!
        color: Color BEAM_COLOR.r, BEAM_COLOR.g, BEAM_COLOR.b, 255
    }

net.Receive "CFC_Powerups-Curse-Start", ->
    ownerSteamID64 = net.ReadString!

    removeEmitter ownerSteamID64 -- Just in case

    owner = player.GetBySteamID64 ownerSteamID64
    return unless IsValid owner

    makeEmitter owner, ownerSteamID64

net.Receive "CFC_Powerups-Curse-Stop", ->
    ownerSteamID64 = net.ReadString!

    removeEmitter ownerSteamID64

net.Receive "CFC_Powerups-Curse-CurseHit", ->
    owner = net.ReadPlayer!
    victim = net.ReadPlayer!
    return unless IsValid owner
    return unless IsValid victim

    makeBeam owner\WorldSpaceCenter!, victim\WorldSpaceCenter!


timer.Create "CFC_Powerups-Curse-EmitterThink", EMITTER_INTERVAL, 0, ->
    for ownerSteamID64, emitter in pairs emitters
        owner = emitterOwners[ownerSteamID64]
        if not IsValid owner
            removeEmitter ownerSteamID64
            continue

        obbSize = owner\OBBMaxs!
        spreadX = obbSize.x * EMITTER_SPREAD_XY / 2
        spreadY = obbSize.y * EMITTER_SPREAD_XY / 2
        spreadZ = obbSize.z * EMITTER_SPREAD_Z / 2
        centerPos = EMITTER_SPREAD_FROM_TOP and Vector(0, 0, -spreadZ) or Vector(0, 0, 0)

        for _ = 1, EMITTER_AMOUNT
            pos = centerPos + Vector(math.Rand(-spreadX, spreadX), math.Rand(-spreadY, spreadY), math.Rand(-spreadZ, spreadZ))
            dir = AngleRand!\Forward!

            weight = math.random 1, emitterTotalWeight
            option = nil
            for i, total in ipairs emitterWeightTotals
                if weight <= total
                    option = EMITTER_OPTIONS[i]
                    break

            color = option.color
            intensity = math.Rand option.colorIntensityMin, option.colorIntensityMax

            with part = emitter\Add option.mat, pos
                \SetStartSize option.startSize
                \SetEndSize option.endSize
                \SetDieTime EMITTER_LIFE
                \SetGravity EMITTER_GRAVITY
                \SetColor color.r * intensity, color.g * intensity, color.b * intensity
                \SetVelocity dir * math.Rand EMITTER_SPEED_MIN, EMITTER_SPEED_MAX


hook.Add "PostDrawTranslucentRenderables", "CFC_Powerups-Curse-DrawEmitters", (_, skybox, skybox3d) ->
    return if skybox or skybox3d

    for ownerSteamID64, owner in pairs emitterOwners
        continue unless IsValid owner
        inFirstPerson = owner == LocalPlayer! and not owner\ShouldDrawLocalPlayer!
        continue if inFirstPerson

        emitter = emitters[ownerSteamID64]
        zRaise = owner\OBBMaxs!.z
        zRaise = EMITTER_SPREAD_FROM_TOP and zRaise or (zRaise / 2)
        pos = owner\GetPos! + Vector(0, 0, zRaise)

        -- Make particles follow the emitter
        cam.Start3D WorldToLocal(EyePos!, EyeAngles!, pos, ANGLE_ZERO)
        emitter\Draw!
        cam.End3D!

    return nil

hook.Add "PostDrawTranslucentRenderables", "CFC_Powerups-Curse-DrawBeams", (_, skybox, skybox3d) ->
    return if skybox or skybox3d

    now = CurTime!

    for i = #beams, 1, -1
        beam = beams[i]
        elapsed = now - beam.startTime
        frac = elapsed / BEAM_DURATION

        if frac >= 1
            table.remove( beams, i )
            continue

        color = beam.color
        alpha = 255 - 255 * frac
        color.a = alpha

        scroll = math.Rand 0, 1

        render.SetMaterial BEAM_MAT
        render.DrawBeam beam.startPos, beam.endPos, BEAM_WIDTH, scroll, scroll + 1, color

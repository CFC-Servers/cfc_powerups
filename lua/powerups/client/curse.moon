import Clamp from math

EMITTER_INTERVAL = 0.1
EMITTER_MATERIAL = "particle/particle_smokegrenade"
EMITTER_START_SIZE = 10
EMITTER_END_SIZE = 10
EMITTER_LIFE = 5
EMITTER_AMOUNT = 5
EMITTER_GRAVITY = Vector 0, 0, 0
EMITTER_SPREAD_XY = 1.25
EMITTER_SPREAD_Z = 0.75
EMITTER_SPREAD_FROM_TOP = false
EMITTER_SPEED_MIN = 5
EMITTER_SPEED_MAX = 10
EMITTER_AIR_RESISTANCE = 3
EMMITTER_COLOR_INTENSITY = 65

ANGLE_ZERO = Angle 0, 0, 0

emitters = {}
emitterOwners = {}

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

net.Receive "CFC_Powerups-Curse-Start", ->
    ownerSteamID64 = net.ReadString!

    removeEmitter ownerSteamID64 -- Just in case

    owner = player.GetBySteamID64 ownerSteamID64
    return unless IsValid owner

    makeEmitter owner, ownerSteamID64

net.Receive "CFC_Powerups-Curse-Stop", ->
    ownerSteamID64 = net.ReadString!

    removeEmitter ownerSteamID64


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
            colorIntensity = math.Rand 0, EMMITTER_COLOR_INTENSITY
            with part = emitter\Add EMITTER_MATERIAL, pos
                \SetStartSize EMITTER_START_SIZE
                \SetEndSize EMITTER_END_SIZE
                \SetDieTime EMITTER_LIFE
                \SetGravity EMITTER_GRAVITY
                \SetColor colorIntensity / 2, 0, colorIntensity
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

local Clamp
Clamp = math.Clamp
local EMITTER_INTERVAL = 0.1
local EMITTER_LIFE = 5
local EMITTER_AMOUNT = 7
local EMITTER_GRAVITY = Vector(0, 0, 0)
local EMITTER_SPREAD_XY = 1.25
local EMITTER_SPREAD_Z = 0.75
local EMITTER_SPREAD_FROM_TOP = false
local EMITTER_SPEED_MIN = 5
local EMITTER_SPEED_MAX = 10
local EMITTER_AIR_RESISTANCE = 3
local EMITTER_OPTIONS = {
  {
    mat = "particle/particle_smokegrenade",
    color = Color(32, 0, 65),
    colorIntensityMin = 0,
    colorIntensityMax = 1,
    startSize = 10,
    endSize = 10,
    weight = 50
  },
  {
    mat = "sprites/orangeflare1",
    color = Color(50, 0, 200),
    colorIntensityMin = 0.75,
    colorIntensityMax = 1,
    startSize = 0,
    endSize = 10,
    weight = 5
  },
  {
    mat = "sprites/glow04_noz_gmod",
    color = Color(125, 0, 200),
    colorIntensityMin = 0.5,
    colorIntensityMax = 1,
    startSize = 0,
    endSize = 10,
    weight = 5
  }
}
local BEAM_MAT = Material("sprites/physbeama")
local BEAM_WIDTH = 30
local BEAM_DURATION = 1.5
local BEAM_COLOR = Color(100, 0, 255)
local ANGLE_ZERO = Angle(0, 0, 0)
local emitters = { }
local emitterOwners = { }
local beams = { }
local emitterWeightTotals = { }
local emitterTotalWeight = 0
for _index_0 = 1, #EMITTER_OPTIONS do
  local option = EMITTER_OPTIONS[_index_0]
  emitterTotalWeight = emitterTotalWeight + option.weight
  table.insert(emitterWeightTotals, emitterTotalWeight)
end
local removeEmitter
removeEmitter = function(ownerSteamID64)
  local emitter = emitters[ownerSteamID64]
  if not (emitter) then
    return 
  end
  emitter:Finish()
  emitters[ownerSteamID64] = nil
  emitterOwners[ownerSteamID64] = nil
end
local makeEmitter
makeEmitter = function(ply, steamID64)
  local emitter = ParticleEmitter(ply:GetPos(), false)
  emitters[steamID64] = emitter
  emitterOwners[steamID64] = ply
  return emitter:SetNoDraw(true)
end
local makeBeam
makeBeam = function(startPos, endPos)
  return table.insert(beams, {
    startPos = startPos,
    endPos = endPos,
    startTime = CurTime(),
    color = Color(BEAM_COLOR.r, BEAM_COLOR.g, BEAM_COLOR.b, 255)
  })
end
net.Receive("CFC_Powerups-Curse-Start", function()
  local ownerSteamID64 = net.ReadString()
  removeEmitter(ownerSteamID64)
  local owner = player.GetBySteamID64(ownerSteamID64)
  if not (IsValid(owner)) then
    return 
  end
  return makeEmitter(owner, ownerSteamID64)
end)
net.Receive("CFC_Powerups-Curse-Stop", function()
  local ownerSteamID64 = net.ReadString()
  return removeEmitter(ownerSteamID64)
end)
net.Receive("CFC_Powerups-Curse-CurseHit", function()
  local owner = net.ReadPlayer()
  local victim = net.ReadPlayer()
  if not (IsValid(owner)) then
    return 
  end
  if not (IsValid(victim)) then
    return 
  end
  return makeBeam(owner:WorldSpaceCenter(), victim:WorldSpaceCenter())
end)
timer.Create("CFC_Powerups-Curse-EmitterThink", EMITTER_INTERVAL, 0, function()
  for ownerSteamID64, emitter in pairs(emitters) do
    local _continue_0 = false
    repeat
      local owner = emitterOwners[ownerSteamID64]
      if not IsValid(owner) then
        removeEmitter(ownerSteamID64)
        _continue_0 = true
        break
      end
      local obbSize = owner:OBBMaxs()
      local spreadX = obbSize.x * EMITTER_SPREAD_XY / 2
      local spreadY = obbSize.y * EMITTER_SPREAD_XY / 2
      local spreadZ = obbSize.z * EMITTER_SPREAD_Z / 2
      local centerPos = EMITTER_SPREAD_FROM_TOP and Vector(0, 0, -spreadZ) or Vector(0, 0, 0)
      for _ = 1, EMITTER_AMOUNT do
        local pos = centerPos + Vector(math.Rand(-spreadX, spreadX), math.Rand(-spreadY, spreadY), math.Rand(-spreadZ, spreadZ))
        local dir = AngleRand():Forward()
        local weight = math.random(1, emitterTotalWeight)
        local option = nil
        for i, total in ipairs(emitterWeightTotals) do
          if weight <= total then
            option = EMITTER_OPTIONS[i]
            break
          end
        end
        local color = option.color
        local intensity = math.Rand(option.colorIntensityMin, option.colorIntensityMax)
        do
          local part = emitter:Add(option.mat, pos)
          part:SetStartSize(option.startSize)
          part:SetEndSize(option.endSize)
          part:SetDieTime(EMITTER_LIFE)
          part:SetGravity(EMITTER_GRAVITY)
          part:SetColor(color.r * intensity, color.g * intensity, color.b * intensity)
          part:SetVelocity(dir * math.Rand(EMITTER_SPEED_MIN, EMITTER_SPEED_MAX))
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end)
hook.Add("PostDrawTranslucentRenderables", "CFC_Powerups-Curse-DrawEmitters", function(_, skybox, skybox3d)
  if skybox or skybox3d then
    return 
  end
  for ownerSteamID64, owner in pairs(emitterOwners) do
    local _continue_0 = false
    repeat
      if not (IsValid(owner)) then
        _continue_0 = true
        break
      end
      local inFirstPerson = owner == LocalPlayer() and not owner:ShouldDrawLocalPlayer()
      if inFirstPerson then
        _continue_0 = true
        break
      end
      local emitter = emitters[ownerSteamID64]
      local zRaise = owner:OBBMaxs().z
      zRaise = EMITTER_SPREAD_FROM_TOP and zRaise or (zRaise / 2)
      local pos = owner:GetPos() + Vector(0, 0, zRaise)
      cam.Start3D(WorldToLocal(EyePos(), EyeAngles(), pos, ANGLE_ZERO))
      emitter:Draw()
      cam.End3D()
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return nil
end)
return hook.Add("PostDrawTranslucentRenderables", "CFC_Powerups-Curse-DrawBeams", function(_, skybox, skybox3d)
  if skybox or skybox3d then
    return 
  end
  local now = CurTime()
  for i = #beams, 1, -1 do
    local _continue_0 = false
    repeat
      local beam = beams[i]
      local elapsed = now - beam.startTime
      local frac = elapsed / BEAM_DURATION
      if frac >= 1 then
        table.remove(beams, i)
        _continue_0 = true
        break
      end
      local color = beam.color
      local alpha = 255 - 255 * frac
      color.a = alpha
      local scroll = math.Rand(0, 1)
      render.SetMaterial(BEAM_MAT)
      render.DrawBeam(beam.startPos, beam.endPos, BEAM_WIDTH, scroll, scroll + 1, color)
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end)

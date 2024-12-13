local Clamp
Clamp = math.Clamp
local EMITTER_INTERVAL = 0.1
local EMITTER_MATERIAL = "particle/particle_smokegrenade"
local EMITTER_START_SIZE = 10
local EMITTER_END_SIZE = 10
local EMITTER_LIFE = 5
local EMITTER_AMOUNT = 5
local EMITTER_GRAVITY = Vector(0, 0, 0)
local EMITTER_SPREAD_XY = 1.25
local EMITTER_SPREAD_Z = 0.75
local EMITTER_SPREAD_FROM_TOP = false
local EMITTER_SPEED_MIN = 5
local EMITTER_SPEED_MAX = 10
local EMITTER_AIR_RESISTANCE = 3
local EMMITTER_COLOR_INTENSITY = 65
local ANGLE_ZERO = Angle(0, 0, 0)
local emitters = { }
local emitterOwners = { }
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
        local colorIntensity = math.Rand(0, EMMITTER_COLOR_INTENSITY)
        do
          local part = emitter:Add(EMITTER_MATERIAL, pos)
          part:SetStartSize(EMITTER_START_SIZE)
          part:SetEndSize(EMITTER_END_SIZE)
          part:SetDieTime(EMITTER_LIFE)
          part:SetGravity(EMITTER_GRAVITY)
          part:SetColor(colorIntensity / 2, 0, colorIntensity)
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
return hook.Add("PostDrawTranslucentRenderables", "CFC_Powerups-Curse-DrawEmitters", function(_, skybox, skybox3d)
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

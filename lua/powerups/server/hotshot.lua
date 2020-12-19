local getConf
getConf = CFCPowerups.Config.get
local Clamp
Clamp = math.Clamp
local Effect
Effect = util.Effect
local allowedToIgnite = {
  ["prop_physics"] = true,
  ["player"] = true
}
local playExplosionSound
playExplosionSound = function(pos)
  local explosionSound = "ambient/fire/gascan_ignite1.wav"
  local explosionPitch = 100
  local explosionVolume = 1
  return sound.Play(explosionSound, pos, 100, explosionPitch, explosionVolume)
end
local playExplosionEffect
playExplosionEffect = function(pos)
  local effectName = "HelicopterMegaBomb"
  local effectData = EffectData()
  effectData:SetOrigin(pos)
  return Effect(effectName, effectData, true, true)
end
local explodeWatcher
explodeWatcher = function(ply)
  if not (IsValid(ply)) then
    return 
  end
  if not (ply.affectedByHotshot) then
    return 
  end
  local playerPos = ply:GetPos()
  local burningDamage = ply.hotshotBurningDamage + (ply.hotshotExplosionBurningDamage or 0)
  local baseRadius = getConf("hotshot_explosion_base_radius")
  local baseDamage = getConf("hotshot_explosion_base_damage")
  local maxExplosionRadius = getConf("hotshot_explosion_max_radius")
  local maxExplosionDamage = getConf("hotshot_explosion_max_damage")
  local maxExplosionBurnDuration = getConf("hotshot_explosion_max_burn_duration")
  local scaledRadius = Clamp(baseRadius * burningDamage, 1, maxExplosionRadius)
  local scaledDamage = Clamp(baseDamage * burningDamage, 10, maxExplosionDamage)
  local scaledDuration = Clamp(burningDamage, 1, maxExplosionBurnDuration)
  playExplosionEffect(ply:GetPos())
  CFCPowerups.Logger:info("Exploding " .. tostring(ply:Nick()) .. " with a radius of " .. tostring(scaledRadius) .. " units. (" .. tostring(scaledDamage) .. " extra burning damage)")
  local nearbyEnts = ents.FindInSphere(playerPos, scaledRadius)
  local goodEnts
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #nearbyEnts do
      local ent = nearbyEnts[_index_0]
      if allowedToIgnite[ent:GetClass()] and ent ~= ply then
        _accum_0[_len_0] = ent
        _len_0 = _len_0 + 1
      end
    end
    goodEnts = _accum_0
  end
  local damageInfo = DamageInfo()
  do
    damageInfo:SetDamage(scaledDamage)
    damageInfo:SetDamageType(DMG_BLAST)
    damageInfo:SetAttacker(ply)
    damageInfo:SetInflictor(ply)
  end
  for _index_0 = 1, #goodEnts do
    local ent = goodEnts[_index_0]
    playExplosionSound(ent:GetPos())
    do
      ent:Ignite(scaledDuration)
      ent:TakeDamageInfo(damageInfo)
      ent.hotshotExplosionBurningDamage = burningDamage
    end
  end
  return timer.Simple(scaledDuration, function()
    for _index_0 = 1, #goodEnts do
      local _continue_0 = false
      repeat
        local ent = goodEnts[_index_0]
        if not (IsValid(ent)) then
          _continue_0 = true
          break
        end
        ent.hotshotExplosionBurningDamage = nil
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end)
end
hook.Add("PostPlayerDeath", "CFC_Powerups_Hotshot_OnPlayerDeath", explodeWatcher)
local fireDamageWatcher
fireDamageWatcher = function(ent, damageInfo)
  if not (IsValid(ent)) then
    return 
  end
  local inflictor = damageInfo:GetInflictor():GetClass()
  if not (inflictor == "entityflame") then
    return 
  end
  local burningDamage = ent.hotshotBurningDamage
  local explosionBurningDamage = ent.hotshotExplosionBurningDamage
  if not (burningDamage or explosionBurningDamage) then
    return 
  end
  local addedDamage = (burningDamage or 0) + (explosionBurningDamage or 0)
  return damageInfo:AddDamage(addedDamage)
end
hook.Add("EntityTakeDamage", "CFC_Powerups_Hotshot_OnFireDamage", fireDamageWatcher)
local calculateBurnDamage
calculateBurnDamage = function(damageInfo)
  return damageInfo:GetDamage() * getConf("hotshot_ignite_multiplier")
end
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    IgniteWatcher = function(self)
      return function(ent, damageInfo, tookDamage)
        if not (IsValid(ent)) then
          return 
        end
        if not (damageInfo:GetAttacker() == self.owner and damageInfo:GetInflictor() == self.owner) then
          return 
        end
        if not (tookDamage) then
          return 
        end
        if ent == self.owner then
          return 
        end
        if damageInfo:GetInflictor():GetClass() == "entityflame" then
          return 
        end
        local shouldIgnite = hook.Run("CFC_Powerups_Hotshot_ShouldIgnite")
        if shouldIgnite == false then
          return 
        end
        local igniteDuration = getConf("hotshot_ignite_duration")
        ent:Ignite(igniteDuration)
        local addedFireDamage = calculateBurnDamage(damageInfo)
        ent.affectedByHotshot = true
        ent.hotshotBurningDamage = ent.hotshotBurningDamage or 0
        ent.hotshotBurningDamage = ent.hotshotBurningDamage + addedFireDamage
        local timerIndex = ent:IsPlayer() and ent:SteamID64() or ent:EntIndex()
        local timerName = "CFC_Powerups-Hotshot-OnExtinguish-" .. tostring(timerIndex)
        return timer.Create(timerName, igniteDuration + 0.5, 1, function()
          ent.affectedByHotshot = nil
          ent.hotshotBurningDamage = nil
          return timer.Remove(timerName)
        end)
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      return hook.Add("PostEntityTakeDamage", self.timerName, self:IgniteWatcher())
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.timerName)
      return self.owner:ChatPrint("You've refreshed the duration of the Hotshot Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.timerName)
      hook.Remove("PostEntityTakeDamage", self.timerName)
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:ChatPrint("You've lost the Hotshot Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.timerName = "CFC_Powerups-Hotshot-" .. tostring(ply:SteamID64())
      local timerDuration = getConf("hotshot_duration")
      timer.Create(self.timerName, timerDuration, 1, function()
        return self:Remove()
      end)
      self.owner:ChatPrint("You've gained " .. tostring(timerDuration) .. " seconds of the Hotshot Powerup")
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "HotshotPowerup",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.powerupID = "powerup_hotshot"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  HotshotPowerup = _class_0
  return _class_0
end

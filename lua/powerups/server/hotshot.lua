local getConf
getConf = CFCPowerups.Config.get
local Clamp
Clamp = math.Clamp
local Effect
Effect = util.Effect
local IsValid
IsValid = _G.IsValid
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
  local powerup = ply.latestHotshotPowerup
  if not (powerup) then
    return 
  end
  if powerup.expired then
    return 
  end
  local playerPos = ply:GetPos()
  local burningDamage = ply.hotshotBurningDamage + (ply.hotshotExplosionBurningDamage or 0)
  local baseRadius = getConf("hotshot_explosion_base_radius")
  local baseDamage = getConf("hotshot_explosion_base_damage")
  local maxExplosionRadius = getConf("hotshot_explosion_max_radius")
  local maxExplosionDamage = getConf("hotshot_explosion_max_damage")
  local scaledRadius = Clamp(baseRadius * burningDamage, 1, maxExplosionRadius)
  local scaledDamage = Clamp(baseDamage * burningDamage, 10, maxExplosionDamage)
  playExplosionEffect(ply:GetPos())
  CFCPowerups.Logger:info("Exploding " .. tostring(ply:Nick()) .. " with a radius of " .. tostring(scaledRadius) .. " units. (" .. tostring(scaledDamage) .. " extra burning damage)")
  return util.BlastDamage(powerup.damageInflictor, powerup.owner, ply:WorldSpaceCenter(), scaledRadius, scaledDamage)
end
hook.Add("PostPlayerDeath", "CFC_Powerups_Hotshot_OnPlayerDeath", explodeWatcher)
local fireDamageWatcher
fireDamageWatcher = function(ent, damageInfo)
  if not (IsValid(ent)) then
    return 
  end
  local powerup = ent.latestHotshotPowerup
  if not (powerup) then
    return 
  end
  if powerup.expired then
    return 
  end
  local inflictor = damageInfo:GetInflictor()
  if not (IsValid(inflictor)) then
    return 
  end
  local inflictorClass = inflictor:GetClass()
  if not (inflictorClass == "entityflame") then
    return 
  end
  local burningDamage = ent.hotshotBurningDamage
  if not (burningDamage) then
    return 
  end
  local addedDamage = (burningDamage or 0)
  damageInfo:SetInflictor(powerup.damageInflictor)
  damageInfo:SetAttacker(powerup.owner)
  damageInfo:AddDamage(addedDamage)
  return nil
end
hook.Add("EntityTakeDamage", "CFC_Powerups_Hotshot_OnFireDamage", fireDamageWatcher, HOOK_HIGH)
local fireDamagePVPWatcher
fireDamagePVPWatcher = function(ent, damageInfo)
  if not (IsValid(ent)) then
    return 
  end
  local powerup = ent.latestHotshotPowerup
  if not (powerup) then
    return 
  end
  if powerup.expired then
    return 
  end
  return false
end
hook.Add("CFC_PvP_ShouldBlockFireDamage", "CFC_Powerups_Hotshot_OnFireDamage", fireDamagePVPWatcher)
local explosionImmunityWatcher
explosionImmunityWatcher = function(ent, damageInfo)
  if not (IsValid(ent)) then
    return 
  end
  if not (damageInfo:IsExplosionDamage()) then
    return 
  end
  local inflictor = damageInfo:GetInflictor()
  if not (IsValid(inflictor)) then
    return 
  end
  local inflictorClass = inflictor:GetClass()
  if not (inflictorClass == "cfc_powerup_hotshot_inflictor") then
    return 
  end
  if not (ent.Powerups and ent.Powerups.powerup_hotshot) then
    return 
  end
  return true
end
hook.Add("EntityTakeDamage", "CFC_Powerups_Hotshot_DeathExplosionImmunity", explosionImmunityWatcher, HOOK_HIGH)
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
        if not (tookDamage) then
          return 
        end
        if ent == self.owner then
          return 
        end
        if not (damageInfo:GetAttacker() == self.owner) then
          return 
        end
        if not (allowedToIgnite[ent:GetClass()]) then
          return 
        end
        local inflictor = damageInfo:GetInflictor()
        if not (inflictor == self.owner or (damageInfo:IsExplosionDamage() and inflictor:GetClass() == "cfc_powerup_hotshot_inflictor")) then
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
        ent.latestHotshotPowerup = self
        ent.hotshotBurningDamage = ent.hotshotBurningDamage or 0
        ent.hotshotBurningDamage = ent.hotshotBurningDamage + addedFireDamage
        local timerIndex = ent:IsPlayer() and ent:SteamID64() or ent:EntIndex()
        local timerName = "CFC_Powerups-Hotshot-OnExtinguish-" .. tostring(timerIndex)
        return timer.Create(timerName, igniteDuration + 0.5, 1, function()
          ent.affectedByHotshot = nil
          ent.latestHotshotPowerup = nil
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
      self.expired = true
      if IsValid(self.damageInflictor) then
        self.damageInflictor:Remove()
      end
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
      do
        local _with_0 = ents.Create("cfc_powerup_hotshot_inflictor")
        self.damageInflictor = _with_0
        _with_0:SetOwner(self.owner)
        _with_0:Spawn()
      end
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

local getConf
getConf = CFCPowerups.Config.get
local CLICK_WINDOW = 0.5
local BLACKLISTED_EFFECTS = {
  EntJitter = true,
  EntMagnet = true,
  FreshPaint = true,
  ThanosSnap = true,
  NoclipSpam = true,
  DisableNoclip = true,
  TextScramble = true,
  ColorModifyContinuous = true,
  TextureShuffleContinuous = true,
  JumpExplode = true,
  SprintExplode = true,
  Respawn = true,
  Clumsy = true,
  TheFloorIsLava = true,
  Drunk = true,
  NoInteract = true,
  Lidar = true,
  Ball = true,
  SoundShuffle = true,
  RandomSounds = true,
  WeaponIndecision = true,
  FilmDevelopment = true,
  SanFransisco = true
}
util.AddNetworkString("CFC_Powerups-Curse-Start")
util.AddNetworkString("CFC_Powerups-Curse-Stop")
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    DamageWatcher = function(self)
      return function(victim, damageInfo)
        if not (victim == self.owner) then
          return 
        end
        local attacker = damageInfo:GetAttacker()
        if attacker == victim then
          return 
        end
        if not (IsValid(attacker)) then
          return 
        end
        if not (attacker:IsPlayer()) then
          return 
        end
        local curEffects = CFCUlxCurse.GetCurrentEffects(attacker)
        local hasNoEffects = next(curEffects) == nil
        if hasNoEffects then
          self:Curse(attacker)
        end
        if not (math.random() <= self.chance) then
          return 
        end
        local nextCurseTime = self.nextCurseTimes[attacker] or 0
        if CurTime() < nextCurseTime then
          return 
        end
        self:Curse(attacker)
        return nil
      end
    end,
    Curse = function(self, ply)
      local effectData = CFCUlxCurse.GetRandomEffect(ply, BLACKLISTED_EFFECTS)
      if not (effectData) then
        return 
      end
      local rf = RecipientFilter()
      rf:AddPlayer(ply)
      for i = 0, 4 do
        local pitch = Lerp(i / 5, 80, 130)
        ply:EmitSound("buttons/button19.wav", 75, pitch, 0.65, CHAN_AUTO, 0, 0, rf)
      end
      ply:EmitSound("ambient/levels/prison/radio_random9.wav", 75, 100, 0.5, CHAN_AUTO, 0, 0, rf)
      ply:EmitSound("ambient/levels/prison/radio_random14.wav", 75, 100, 0.5, CHAN_AUTO, 0, 0, rf)
      local duration = math.Rand(self.durationMin, self.durationMax)
      self.nextCurseTimes[ply] = CurTime() + self.ratelimit
      return CFCUlxCurse.ApplyCurseEffect(ply, effectData, duration)
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      self.ownerSteamID64 = self.owner:SteamID64()
      self.hookName = "CFC_Powerups-Curse-" .. tostring(self.ownerSteamID64)
      hook.Add("EntityTakeDamage", self.hookName, self:DamageWatcher())
      timer.Create(self.hookName, self.duration, 1, function()
        return self:Remove()
      end)
      net.Start("CFC_Powerups-Curse-Start")
      net.WriteString(self.ownerSteamID64)
      net.Broadcast()
      return self.owner:ChatPrint("You've gained " .. tostring(self.duration) .. " seconds of the Curse Powerup")
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.hookName)
      return self.owner:ChatPrint("You've refreshed the duration of the Curse Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.hookName)
      hook.Remove("EntityTakeDamage", self.hookName)
      net.Start("CFC_Powerups-Curse-Stop")
      net.WriteString(self.ownerSteamID64)
      net.Broadcast()
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:ChatPrint("You've lost the Curse Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.duration = getConf("curse_duration")
      self.durationMin = getConf("curse_duration_min")
      self.durationMax = getConf("curse_duration_max")
      self.chance = getConf("curse_chance")
      self.ratelimit = getConf("curse_ratelimit")
      self.nextCurseTimes = { }
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "CursePowerup",
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
  self.powerupID = "powerup_curse"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  CursePowerup = _class_0
end
return hook.Add("CFC_Powerups_DisallowGetPowerup", "CFC_Powerups-Curse-CheckDependencies", function(_, powerupId)
  if not (powerupId == "powerup_curse") then
    return 
  end
  if CFCUlxCurse then
    return 
  end
  return true, "The server does not have CFC ULX Commands installed"
end)

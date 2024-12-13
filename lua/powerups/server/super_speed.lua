local getConf
getConf = CFCPowerups.Config.get
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      do
        local _with_0 = self.owner
        local super_speedMultiplier = getConf("super_speed_multiplier")
        _with_0:SetDuckSpeed(self.baseDuckSpeed * super_speedMultiplier)
        _with_0:SetUnDuckSpeed(self.baseUnDuckSpeed * super_speedMultiplier)
        _with_0:SetCrouchedWalkSpeed(self.baseCrouchedWalkSpeed * super_speedMultiplier)
        _with_0:SetSlowWalkSpeed(self.baseSlowWalkSpeed * super_speedMultiplier)
        _with_0:SetWalkSpeed(self.baseWalkSpeed * super_speedMultiplier)
        _with_0:SetRunSpeed(self.baseRunSpeed * super_speedMultiplier)
        _with_0:SetLadderClimbSpeed(self.baseLadderClimbSpeed * super_speedMultiplier)
        _with_0:SetMaxSpeed(self.baseMaxSpeed * super_speedMultiplier)
        return _with_0
      end
    end,
    PowerupTick = function(self)
      local powerup = self
      return function()
        if not (powerup.owner:GetRunSpeed() == powerup.baseRunSpeed) then
          return 
        end
        return powerup:ApplyEffect()
      end
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      local duration = getConf("super_speed_duration")
      local interval = getConf("super_speed_interval")
      local repetitions = duration / interval
      timer.Create(self.timerNameTick, interval, repetitions, self:PowerupTick())
      timer.Start(self.timerNameRemove)
      return self.owner:ChatPrint("You've refreshed your duration of the Super Speed Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.timerNameTick)
      timer.Remove(self.timerNameRemove)
      if not (IsValid(self.owner)) then
        return 
      end
      do
        local _with_0 = self.owner
        _with_0:SetDuckSpeed(self.baseDuckSpeed)
        _with_0:SetUnDuckSpeed(self.baseUnDuckSpeed)
        _with_0:SetCrouchedWalkSpeed(self.baseCrouchedWalkSpeed)
        _with_0:SetSlowWalkSpeed(self.baseSlowWalkSpeed)
        _with_0:SetWalkSpeed(self.baseWalkSpeed)
        _with_0:SetRunSpeed(self.baseRunSpeed)
        _with_0:SetLadderClimbSpeed(self.baseLadderClimbSpeed)
        _with_0:SetMaxSpeed(self.baseMaxSpeed)
        _with_0:ChatPrint("You've lost the Super Speed Powerup")
      end
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      local speedPowerup = ply.Powerups.powerup_speed
      if speedPowerup then
        speedPowerup:Remove()
      end
      self.timerNameTick = "CFC_Powerups-SuperSpeed-Tick-" .. tostring(ply:SteamID64())
      self.timerNameRemove = "CFC_Powerups-SuperSpeed-Remove-" .. tostring(ply:SteamID64())
      local duration = getConf("super_speed_duration")
      local interval = getConf("super_speed_interval")
      local repetitions = duration / interval
      timer.Create(self.timerNameTick, interval, repetitions, self:PowerupTick())
      timer.Create(self.timerNameRemove, duration, 1, function()
        return self:Remove()
      end)
      self.baseDuckSpeed = self.owner:GetDuckSpeed()
      self.baseUnDuckSpeed = self.owner:GetUnDuckSpeed()
      self.baseCrouchedWalkSpeed = self.owner:GetCrouchedWalkSpeed()
      self.baseSlowWalkSpeed = self.owner:GetSlowWalkSpeed()
      self.baseWalkSpeed = self.owner:GetWalkSpeed()
      self.baseRunSpeed = self.owner:GetRunSpeed()
      self.baseLadderClimbSpeed = self.owner:GetLadderClimbSpeed()
      self.baseMaxSpeed = self.owner:GetMaxSpeed()
      self.owner:ChatPrint("You've gained " .. tostring(duration) .. " seconds of the Super Speed Powerup")
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "SuperSpeedPowerup",
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
  self.powerupID = "powerup_super_speed"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SuperSpeedPowerup = _class_0
end
return hook.Add("CFC_Powerups_DisallowGetPowerup", "CFC_Powerups-SuperSpeed-BlockSpeed", function(ply, powerupId)
  if not (powerupId == "powerup_speed") then
    return 
  end
  local superSpeedPowerup = ply.Powerups.powerup_super_speed
  if not (superSpeedPowerup) then
    return 
  end
  return true, "Super Speed cannot be replaced with Speed"
end)

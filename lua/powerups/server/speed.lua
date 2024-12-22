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
        local speedMultiplier = getConf("speed_multiplier")
        _with_0:SetDuckSpeed(self.baseDuckSpeed * speedMultiplier)
        _with_0:SetUnDuckSpeed(self.baseUnDuckSpeed * speedMultiplier)
        _with_0:SetCrouchedWalkSpeed(self.baseCrouchedWalkSpeed * speedMultiplier)
        _with_0:SetSlowWalkSpeed(self.baseSlowWalkSpeed * speedMultiplier)
        _with_0:SetWalkSpeed(self.baseWalkSpeed * speedMultiplier)
        _with_0:SetRunSpeed(self.baseRunSpeed * speedMultiplier)
        _with_0:SetLadderClimbSpeed(self.baseLadderClimbSpeed * speedMultiplier)
        _with_0:SetMaxSpeed(self.baseMaxSpeed * speedMultiplier)
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
      local duration = getConf("speed_duration")
      local interval = getConf("speed_interval")
      local repetitions = duration / interval
      timer.Create(self.timerNameTick, interval, repetitions, self:PowerupTick())
      timer.Start(self.timerNameRemove)
      return self.owner:ChatPrint("You've refreshed your duration of the Speed Powerup")
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
        _with_0:ChatPrint("You've lost the Speed Powerup")
      end
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.timerNameTick = "CFC_Powerups-Speed-Tick-" .. tostring(ply:SteamID64())
      self.timerNameRemove = "CFC_Powerups-Speed-Remove-" .. tostring(ply:SteamID64())
      local duration = getConf("speed_duration")
      local interval = getConf("speed_interval")
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
      self.owner:ChatPrint("You've gained " .. tostring(duration) .. " seconds of the Speed Powerup")
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "SpeedPowerup",
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
  self.powerupID = "powerup_speed"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  SpeedPowerup = _class_0
  return _class_0
end

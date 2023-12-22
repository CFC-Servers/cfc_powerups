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
        _with_0.baseDuckSpeed = self.owner:GetDuckSpeed()
        _with_0.baseUnDuckSpeed = self.owner:GetUnDuckSpeed()
        _with_0.baseCrouchedWalkSpeed = self.owner:GetCrouchedWalkSpeed()
        _with_0.baseSlowWalkSpeed = self.owner:GetSlowWalkSpeed()
        _with_0.baseWalkSpeed = self.owner:GetWalkSpeed()
        _with_0.baseRunSpeed = self.owner:GetRunSpeed()
        _with_0.baseLadderClimbSpeed = self.owner:GetLadderClimbSpeed()
        _with_0.baseMaxSpeed = self.owner:GetMaxSpeed()
        local speedMultiplier = getConf("speed_multiplier")
        _with_0:SetDuckSpeed(_with_0.baseDuckSpeed * speedMultiplier)
        _with_0:SetUnDuckSpeed(_with_0.baseUnDuckSpeed * speedMultiplier)
        _with_0:SetCrouchedWalkSpeed(_with_0.baseCrouchedWalkSpeed * speedMultiplier)
        _with_0:SetSlowWalkSpeed(_with_0.baseSlowWalkSpeed * speedMultiplier)
        _with_0:SetWalkSpeed(_with_0.baseWalkSpeed * speedMultiplier)
        _with_0:SetRunSpeed(_with_0.baseRunSpeed * speedMultiplier)
        _with_0:SetLadderClimbSpeed(_with_0.baseLadderClimbSpeed * speedMultiplier)
        _with_0:SetMaxSpeed(_with_0.baseMaxSpeed * speedMultiplier)
        _with_0:ChatPrint("You've gained " .. tostring(getConf("speed_duration")) .. " seconds of the Speed Powerup")
        return _with_0
      end
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.timerName)
      return self.owner:ChatPrint("You've refreshed your duration of the Speed Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      if not (IsValid(self.owner)) then
        return 
      end
      do
        local _with_0 = self.owner
        _with_0:SetDuckSpeed(_with_0.baseDuckSpeed)
        _with_0:SetUnDuckSpeed(_with_0.baseUnDuckSpeed)
        _with_0:SetCrouchedWalkSpeed(_with_0.baseCrouchedWalkSpeed)
        _with_0:SetSlowWalkSpeed(_with_0.baseSlowWalkSpeed)
        _with_0:SetWalkSpeed(_with_0.baseWalkSpeed)
        _with_0:SetRunSpeed(_with_0.baseRunSpeed)
        _with_0:SetLadderClimbSpeed(_with_0.baseLadderClimbSpeed)
        _with_0:SetMaxSpeed(_with_0.baseMaxSpeed)
      end
      self.owner:ChatPrint("You've lost the Speed Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.timerName = "CFC_Powerups-Speed-" .. tostring(ply:SteamID64())
      local duration = getConf("speed_duration")
      timer.Create(self.timerName, duration, 1, function()
        return self:Remove()
      end)
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

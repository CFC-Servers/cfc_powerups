local getConf
getConf = CFCPowerups.Config.get
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    CreateDamageWatcher = function(self)
      return function(ply, damageInfo)
        if not (ply == self.owner) then
          return 
        end
        if not (damageInfo:IsFallDamage()) then
          return 
        end
        return true
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      local gravityMult = getConf("feather_gravity_multiplier")
      local baseGravity = self.owner:GetGravity()
      local newGravity = baseGravity * gravityMult
      hook.Add("EntityTakeDamage", self.timerName, self:CreateDamageWatcher())
      do
        local _with_0 = self.owner
        _with_0.baseGravity = baseGravity
        _with_0:SetGravity(newGravity)
        _with_0:ChatPrint("You've gained " .. tostring(getConf("feather_duration")) .. " seconds of the Feather Powerup")
        return _with_0
      end
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.timerName)
      return self.owner:ChatPrint("You've refreshed your duration of the Feather Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.timerName)
      hook.Remove("EntityTakeDamage", self.timerName)
      if not (IsValid(self.owner)) then
        return 
      end
      do
        local _with_0 = self.owner
        _with_0:SetGravity(_with_0.baseGravity)
      end
      self.owner:ChatPrint("You've lost the Feather Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.timerName = "CFC_Powerups-Feather-" .. tostring(ply:SteamID64())
      local duration = getConf("feather_duration")
      timer.Create(self.timerName, duration, 1, function()
        return self.Remove
      end)
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "FeatherPowerup",
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
  self.powerupID = "powerup_feather"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  FeatherPowerup = _class_0
  return _class_0
end

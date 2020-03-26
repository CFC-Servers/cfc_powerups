local POWERUP_ID = "base-cfc-powerup"
do
  local _class_0
  local _base_0 = {
    ApplyEffect = function(self)
      self.owner:ChatPrint("Powerup Get!")
      return self.owner:Kill()
    end,
    Refresh = function(self)
      self.owner:ChatPrint("Powerup Refreshed!")
      return self.owner:Kill()
    end,
    Remove = function(self)
      self.owner:ChatPrint("Powerup Removed!")
      return self.owner:Kill()
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, ply, removeOnDeath, requiresPvp, isRefreshable)
      if removeOnDeath == nil then
        removeOnDeath = true
      end
      if requiresPvp == nil then
        requiresPvp = true
      end
      if isRefreshable == nil then
        isRefreshable = true
      end
      self.owner = ply
      self.RemoveOnDeath = removeOnDeath
      self.RequiresPvp = requiresPvp
      self.IsRefreshable = isRefreshable
    end,
    __base = _base_0,
    __name = "BasePowerup"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  BasePowerup = _class_0
end
CFCPowerups[POWERUP_ID] = BasePowerup

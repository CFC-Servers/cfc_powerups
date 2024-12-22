do
  local _class_0
  local _base_0 = {
    ApplyEffect = function(self)
      self.owner:SetNWBool("HasPowerup", true)
      hook.Run("CFC_Powerups_PowerupApplied", self.owner, self.powerupID)
      return nil
    end,
    Refresh = function(self)
      hook.Run("CFC_Powerups_PowerupRefreshed", self.owner, self.powerupID)
      return nil
    end,
    Remove = function(self)
      self.owner:SetNWBool("HasPowerup", false)
      hook.Run("CFC_Powerups_PowerupRemoved", self.owner, self.powerupID)
      return nil
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, ply)
      self.owner = ply
      self.RemoveOnDeath = self.__class.RemoveOnDeath
      self.RequiresPvp = self.__class.RequiresPvp
      self.IsRefreshable = self.__class.IsRefreshable
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
  local self = _class_0
  self.powerupList = { }
  self.powerupID = "base_cfc_powerup"
  self.powerupTotalWeights = {
    tier1 = 0,
    tier2 = 0,
    tier3 = 0,
    tier4 = 0
  }
  self.powerupWeights = {
    tier1 = 0,
    tier2 = 0,
    tier3 = 0,
    tier4 = 0
  }
  self.RemoveOnDeath = true
  self.RequiresPvp = true
  self.IsRefreshable = true
  self.__inherited = function(self, child)
    table.insert(self.powerupList, child)
    CFCPowerups[child.powerupID] = child
    for tier = 1, 4 do
      local tierName = "tier" .. tostring(tier)
      self.powerupTotalWeights[tierName] = self.powerupTotalWeights[tierName] + child.powerupWeights[tierName]
    end
  end
  BasePowerup = _class_0
end
CFCPowerups[BasePowerup.powerupID] = BasePowerup

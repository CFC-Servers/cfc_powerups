local getConf
getConf = CFCPowerups.Config.get
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      local duration = getConf("ammo_duration")
      local refreshInterval = getConf("ammo_refresh_interval")
      self.ensureAmmoTimer = "CFC_Powerups-Ammo-EnsureAmmo-" .. tostring(self.owner:SteamID64())
      timer.Create(self.ensureAmmoTimer, refreshInterval, 0, function()
        return self:RefreshAmmo()
      end)
      self.durationTimer = "CFC_Powerups-Ammo-" .. tostring(self.owner:SteamID64())
      timer.Create(self.durationTimer, duration, 1, function()
        return self:Remove()
      end)
      return self.owner:ChatPrint("You've gained " .. tostring(duration) .. " seconds of the Ammo Powerup")
    end,
    RefreshAmmo = function(self)
      if not (IsValid(self.owner)) then
        return 
      end
      if not (self.owner:Alive()) then
        return 
      end
      local giveThreshold = getConf("ammo_secondary_min")
      local secondaryGiveAmount = getConf("ammo_secondary_refresh_amount")
      local ownerWeapon = self.owner:GetActiveWeapon()
      if not (IsValid(ownerWeapon)) then
        return 
      end
      local ammo2 = ownerWeapon:GetSecondaryAmmoType()
      local canSetAmmo2 = ammo2 and ammo2 ~= -1
      local shouldSetAmmo2 = canSetAmmo2 and self.owner:GetAmmoCount(ammo2) < giveThreshold
      if shouldSetAmmo2 then
        self.owner:GiveAmmo(secondaryGiveAmount, ammo2, false)
      end
      return ownerWeapon:SetClip1(100)
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.ensureAmmoTimer)
      return self.owner:ChatPrint("You've refreshed the duration of the Ammo Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.ensureAmmoTimer)
      timer.Remove(self.durationTimer)
      if not (IsValid(self.owner)) then
        return 
      end
      local _list_0 = self.owner:GetWeapons()
      for _index_0 = 1, #_list_0 do
        local _continue_0 = false
        repeat
          local wep = _list_0[_index_0]
          wep:SetClip1(wep:GetMaxClip1())
          local ammo2 = wep:GetSecondaryAmmoType()
          if ammo2 == -1 then
            _continue_0 = true
            break
          end
          self.owner:SetAmmo(0, ammo2)
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      self.owner:ChatPrint("You've lost the Ammo Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "AmmoPowerup",
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
  self.powerupID = "powerup_ammo"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  AmmoPowerup = _class_0
  return _class_0
end

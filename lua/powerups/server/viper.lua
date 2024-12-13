local getConf
getConf = CFCPowerups.Config.get
local Logger
Logger = CFCPowerups.Logger
local MELEE_WEAPONS = {
  ["m9k_knife"] = true,
  ["m9k_damascus"] = true,
  ["m9k_machete"] = true,
  ["m9k_thrown_knife"] = true,
  ["m9k_harpoon"] = true,
  ["m9k_fists"] = true,
  ["cw_ws_pamachete"] = true,
  ["weapon_fists"] = true,
  ["weapon_crowbar"] = true,
  ["weapon_stunstick"] = true,
  ["cw_extrema_ratio_official"] = true,
  ["tfa_l4d2mw_bat"] = true,
  ["tfa_l4d2mw_baton"] = true,
  ["tfa_l4d2mw_crowbar"] = true,
  ["tfa_l4d2mw_etool"] = true,
  ["tfa_l4d2mw_fireaxe"] = true,
  ["tfa_l4d2mw_golfclub"] = true,
  ["tfa_l4d2mw_katana"] = true,
  ["tfa_l4d2mw_knife"] = true,
  ["tfa_l4d2mw_machete"] = true,
  ["tfa_l4d2mw_metalbat"] = true,
  ["tfa_l4d2mw_pitchfork"] = true,
  ["tfa_l4d2mw_shovel"] = true,
  ["tfa_l4d2mw_sledgehammer"] = true,
  ["cfc_slappers"] = true,
  ["cfc_super_slappers"] = true
}
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    CreateDamageWatcher = function(self)
      return function(recipient, dmg)
        if not (IsValid(recipient) and recipient:IsPlayer()) then
          return 
        end
        local attacker = dmg:GetAttacker()
        if not (IsValid(attacker) and attacker:IsPlayer()) then
          return 
        end
        if not (attacker == self.owner) then
          return 
        end
        local attackerWeapon = attacker:GetActiveWeapon()
        if not (IsValid(attackerWeapon)) then
          return 
        end
        attackerWeapon = attackerWeapon:GetClass()
        if not (MELEE_WEAPONS[attackerWeapon]) then
          return 
        end
        local multiplier = getConf("viper_multiplier")
        Logger:info("Scaling damage by: " .. tostring(multiplier))
        return dmg:ScaleDamage(multiplier)
      end
    end,
    CreateWeaponChangeWatcher = function(self)
      local viperMaterial = getConf("viper_material")
      return function(ply, oldWeapon, newWeapon)
        if not (IsValid(newWeapon)) then
          return 
        end
        if not (ply == self.owner) then
          return 
        end
        local newClass = newWeapon:GetClass()
        if MELEE_WEAPONS[newClass] then
          do
            local _with_0 = self.owner
            _with_0:SetMaterialForced(viperMaterial)
            _with_0:DrawShadow(false)
          end
          return newWeapon:SetMaterial(viperMaterial)
        else
          do
            local _with_0 = self.owner
            _with_0:SetMaterialForced("")
            _with_0:DrawShadow(true)
          end
          if not (IsValid(oldWeapon)) then
            return 
          end
          return oldWeapon:SetMaterial("")
        end
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      local duration = getConf("viper_duration")
      timer.Create(self.timerName, duration, 1, function()
        return self:Remove()
      end)
      local damageWatcher = self:CreateDamageWatcher()
      hook.Add("EntityTakeDamage", self.hookName, damageWatcher)
      local weaponChangeWatcher = self:CreateWeaponChangeWatcher()
      hook.Add("PlayerSwitchWeapon", self.hookName, weaponChangeWatcher)
      return self.owner:ChatPrint("You've gained the Viper Powerup")
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.timerName)
      return self.owner:ChatPrint("You've refreshed the duration of the Viper Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.timerName)
      hook.Remove("EntityTakeDamage", self.hookName)
      hook.Remove("PlayerSwitchWeapon", self.hookName)
      if not (IsValid(self.owner)) then
        return 
      end
      do
        local _with_0 = self.owner
        _with_0:SetMaterialForced("")
        _with_0:DrawShadow(true)
        _with_0:ChatPrint("You've lost the Viper Powerup")
      end
      local _list_0 = self.owner:GetWeapons()
      for _index_0 = 1, #_list_0 do
        local wep = _list_0[_index_0]
        wep:SetMaterial("")
      end
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.timerName = "CFC_Powerups_Viper-" .. tostring(self.owner:SteamID64())
      self.hookName = self.timerName
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "ViperPowerup",
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
  self.powerupID = "powerup_viper"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ViperPowerup = _class_0
  return _class_0
end

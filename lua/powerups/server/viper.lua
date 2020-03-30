include("base.lua")
local DEFAULT_PLAYER_COLOR = Color(255, 255, 255, 255)
local PLAYER_COLOR = Color(255, 255, 255, 1)
local PLAYER_MATERIAL = ""
local POWERUP_DURATION = 300
local MELEE_DAMAGE_MULT = 3
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
  ["weapon_stunstick"] = true
}
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    CreateDamageWatcher = function(self)
      return function(recipient, dmg)
        if not IsValid(recipient) and recipient:IsPlayer() then
          return 
        end
        local attacker = dmg:GetAttacker()
        if not IsValid(attacker) and attacker:IsPlayer() then
          return 
        end
        if attacker ~= self.owner then
          return 
        end
        local attackerWeapon = attacker:GetActiveWeapon()
        if not IsValid(attackerWeapon) then
          return 
        end
        if not MELEE_WEAPONS[attackerWeapon] then
          return 
        end
        return dmg:ScaleDamage(MELEE_DAMAGE_MULT)
      end
    end,
    ApplyEffect = function(self)
      self.owner:SetColor(PLAYER_COLOR)
      timer.Create(self.timerName, POWERUP_DURATION, 1, function()
        return self:Remove()
      end)
      local watcher = self:CreateDamageWatcher()
      return hook.Create("EntityTakeDamage", self.hookName, watcher)
    end,
    Refresh = function(self)
      return timer.Start(self.timerName)
    end,
    Remove = function(self)
      timer.Remove(self.timerName)
      hook.Remove("EntityTakeDamage", self.hookName)
      if not IsValid(self.owner) then
        return 
      end
      return self.owner:SetColor(DEFAULT_PLAYER_COLOR)
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
    1,
    1,
    1,
    1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ViperPowerup = _class_0
  return _class_0
end

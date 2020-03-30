include("base.lua")
local MAX_HP = 150
local POWERUP_DURATION = 300
local REGEN_INTERVAL = 0.1
local REGEN_AMOUNT = 3
local REGEN_SOUND = "items/medcharge4.wav"
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    PowerupTick = function(self)
      local powerup = self
      return function()
        local plyHealth = powerup.owner:Health()
        if plyHealth < MAX_HP then
          if not powerup.PlayingRegenSound then
            powerup.RegenSound:Play()
            powerup.PlayingRegenSound = true
          end
          local newHealth = math.Clamp(plyHealth + REGEN_AMOUNT, 0, MAX_HP)
          return powerup.owner:SetHealth(newHealth)
        else
          if powerup.PlayingRegenSound then
            powerup.RegenSound:Stop()
            powerup.PlayingRegenSound = false
          end
        end
      end
    end,
    Refresh = function(self)
      return timer.Start(self.timerName)
    end,
    Remove = function(self)
      self.RegenSound:Stop()
      timer.Remove(self.timerName)
      if not IsValid(self.owner) then
        return 
      end
      local plyHealth = self.owner:Health()
      if plyHealth > 100 then
        self.owner:SetHealth(100)
      end
      self.owner.Powerups[POWERUP_ID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.timerName = "CFC_Powerups-Regen-" .. tostring(ply:SteamID64())
      local timerDuration = POWERUP_DURATION / REGEN_INTERVAL
      timer.Create(self.timerName, REGEN_INTERVAL, timerDuration, self:PowerupTick())
      self.RegenSound = CreateSound(self.owner, REGEN_SOUND)
    end,
    __base = _base_0,
    __name = "RegenPowerup",
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
  self.powerupID = "powerup_regen"
  self.powerupWeights = {
    1,
    1,
    1,
    1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  RegenPowerup = _class_0
  return _class_0
end

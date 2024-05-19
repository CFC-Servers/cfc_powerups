local getConf
getConf = CFCPowerups.Config.get
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      local duration = getConf("regen_duration")
      local interval = getConf("regen_interval")
      local timerDuration = duration / interval
      timer.Create(self.timerName, interval, timerDuration, self:PowerupTick())
      self.RegenSound = CreateSound(self.owner, getConf("regen_sound"))
      return self.owner:ChatPrint("You've gained " .. tostring(timerDuration) .. " seconds of the Regen Powerup")
    end,
    PowerupTick = function(self)
      local powerup = self
      return function()
        local plyHealth = powerup.owner:Health()
        local maxHP = getConf("regen_max_hp")
        if plyHealth < maxHP then
          if not powerup.PlayingRegenSound then
            powerup.RegenSound:Play()
            powerup.PlayingRegenSound = true
          end
          local amount = getConf("regen_amount")
          local newHP = plyHealth + amount
          local newHealth = math.Clamp(newHP, 0, maxHP)
          return powerup.owner:SetHealth(newHealth)
        else
          if not (powerup.PlayingRegenSound) then
            return 
          end
          powerup.RegenSound:Stop()
          powerup.PlayingRegenSound = false
        end
      end
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.timerName)
      return self.owner:ChatPrint("You've refreshed the duration of the Regen Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      self.RegenSound:Stop()
      timer.Remove(self.timerName)
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:ChatPrint("You've lost the Regen Powerup")
      local plyHealth = self.owner:Health()
      if plyHealth > 100 then
        self.owner:SetHealth(100)
      end
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.timerName = "CFC_Powerups-Regen-" .. tostring(ply:SteamID64())
      return self:ApplyEffect()
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
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  RegenPowerup = _class_0
  return _class_0
end

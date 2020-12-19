local getConf
getConf = CFCPowerups.Config.get
local Clamp, Round
do
  local _obj_0 = math
  Clamp, Round = _obj_0.Clamp, _obj_0.Round
end
util.AddNetworkString("CFC_Powerups-FluxShield-Start")
util.AddNetworkString("CFC_Powerups-FluxShield-Stop")
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    createHolo = function(self)
      local holo = ents.Create("base_anim")
      do
        holo:SetPos(self.owner:GetPos())
        holo:SetParent(self.owner)
        holo:SetModel("")
        holo:SetRenderMode(RENDERMODE_NONE)
        holo:DrawShadow(false)
        holo:Spawn()
      end
      holo:CallOnRemove("StopSoundBeforeRemove", function()
        return self.shieldSound:Stop()
      end)
      return holo
    end,
    StartScreenEffect = function(self)
      net.Start("CFC_Powerups-FluxShield-Start")
      net.WriteUInt(self.duration, 10)
      net.WriteUInt(self.maxReduction, 7)
      net.WriteFloat(self.tickInterval)
      return net.Send(self.owner)
    end,
    StopScreenEffect = function(self)
      net.Start("CFC_Powerups-FluxShield-Stop")
      return net.Send(self.owner)
    end,
    UpdateSound = function(self)
      return self.shieldSound:ChangeVolume(self.peakPercent, self.tickInterval)
    end,
    UpdatePlayerColor = function(self)
      local minColor = 80
      local diff = 255 - minColor
      local newColor = 255 - (diff * self.peakPercent)
      return self.owner:SetColor(Color(newColor, newColor, newColor))
    end,
    PowerupTick = function(self)
      if self.scaleDirection == "increasing" then
        self.damageScale = self.damageScale - self.changePerTick
      else
        self.damageScale = self.damageScale + self.changePerTick
      end
      self.damageScale = Clamp(self.damageScale, 0, 1)
      self.peakPercent = (1 - self.damageScale) / (self.maxReduction / 100)
      self:UpdateSound()
      self:UpdatePlayerColor()
      return print("New Damage scale: " .. tostring(self.damageScale))
    end,
    DamageWatcher = function(self)
      return function(ent, dmg)
        if not (ent == self.owner) then
          return 
        end
        return dmg:ScaleDamage(self.damageScale)
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      timer.Create(self.durationTimer, self.duration, 1, function()
        return self:Remove()
      end)
      timer.Create(self.tickTimer, self.tickInterval, self.totalTicks, function()
        return self:PowerupTick()
      end)
      timer.Create(self.flipTimer, self.duration / 2, 1, function()
        self.scaleDirection = "decreasing"
      end)
      hook.Add("EntityTakeDamage", self.hookName, self:DamageWatcher())
      self.owner:SetSubMaterial(3, "models/props_combine/com_shield001a")
      local soundLevel = getConf("flux_shield_active_sound_level")
      self.shieldSound:Play()
      self.shieldSound:ChangeVolume(0)
      self:StartScreenEffect()
      return self.owner:ChatPrint("You've gained " .. tostring(self.duration) .. " seconds of the Flux Armor powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.durationTimer)
      timer.Remove(self.tickTimer)
      timer.Remove(self.flipTimer)
      hook.Remove("EntityTakeDamage", self.hookName)
      self.shieldSound:Stop()
      self.holo:Remove()
      if not (IsValid(self.owner)) then
        return 
      end
      self:StopScreenEffect()
      self.owner:SetSubMaterial(3, nil)
      self.owner:SetColor(Color(255, 255, 255))
      self.owner:ChatPrint("You've lost the Flux Armor powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.damageScale = 1
      self.scaleDirection = "increasing"
      self.peakPercent = 0
      self.holo = self:createHolo()
      self.soundPath = "ambient/atmosphere/city_beacon_loop1.wav"
      self.shieldSound = CreateSound(self.holo, self.soundPath)
      self.shieldSound:SetSoundLevel(130)
      self.duration = getConf("flux_shield_duration")
      self.maxReduction = getConf("flux_shield_max_reduction")
      self.tickInterval = getConf("flux_shield_tick_interval")
      self.totalTicks = self.duration / self.tickInterval
      self.changePerTick = (self.maxReduction / (self.totalTicks / 2)) / 100
      self.durationTimer = "CFC-Powerups_FluxShield-" .. tostring(self.owner:SteamID64())
      self.tickTimer = tostring(self.durationTimer) .. "-tick"
      self.flipTimer = tostring(self.durationTimer) .. "-flipper"
      self.hookName = self.durationTimer
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "FluxShieldPowerup",
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
  self.powerupID = "powerup_flux_shield"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  self.IsRefreshable = false
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  FluxShieldPowerup = _class_0
  return _class_0
end

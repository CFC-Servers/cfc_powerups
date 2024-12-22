local getConf
getConf = CFCPowerups.Config.get
local ShotgunPowerupHandler
ShotgunPowerupHandler = CFCPowerups.SharedHandlers.ShotgunPowerupHandler
util.AddNetworkString("CFC_Powerups-Shotgun-Start")
util.AddNetworkString("CFC_Powerups-Shotgun-Stop")
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      timer.Create(self.timerName, self.duration, 1, function()
        return self:Remove()
      end)
      net.Start("CFC_Powerups-Shotgun-Start")
      net.WriteString(self.ownerSteamID64)
      net.WriteUInt(self.singleBulletsMin, 7)
      net.WriteUInt(self.singleBulletsMax, 7)
      net.WriteFloat(self.singleDamageMult)
      net.WriteFloat(self.singleSpreadMult)
      net.WriteFloat(self.singleSpreadAdd)
      net.WriteFloat(self.multiBulletsMult)
      net.WriteFloat(self.multiDamageMult)
      net.Broadcast()
      return self.owner:ChatPrint("You've gained " .. tostring(self.duration) .. " seconds of the Shotgun powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.timerName)
      self.handler:Remove()
      self.handler = nil
      net.Start("CFC_Powerups-Shotgun-Stop")
      net.WriteString(self.ownerSteamID64)
      net.Broadcast()
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:ChatPrint("You've lost the Shotgun powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.ownerSteamID64 = self.owner:SteamID64()
      self.duration = getConf("shotgun_duration")
      self.singleBulletsMin = getConf("shotgun_single_bullets_min")
      self.singleBulletsMax = getConf("shotgun_single_bullets_max")
      self.singleDamageMult = getConf("shotgun_single_damage_multiplier")
      self.singleSpreadMult = getConf("shotgun_single_spread_multiplier")
      self.singleSpreadAdd = getConf("shotgun_single_spread_add")
      self.multiBulletsMult = getConf("shotgun_multi_bullets_multiplier")
      self.multiDamageMult = getConf("shotgun_multi_damage_multiplier")
      self.timerName = "CFC-Powerups_Shotgun-" .. tostring(self.ownerSteamID64)
      self.handler = ShotgunPowerupHandler(ply, self.singleBulletsMin, self.singleBulletsMax, self.singleDamageMult, self.singleSpreadMult, self.singleSpreadAdd, self.multiBulletsMult, self.multiDamageMult)
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "ShotgunPowerup",
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
  self.powerupID = "powerup_shotgun"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ShotgunPowerup = _class_0
  return _class_0
end

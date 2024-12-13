local FORCE_MULTI_CLASSES = { }
local FORCE_MULTI_CLASS_STARTS = {
  ["cw_"] = "Shots"
}
local forceMultiClassCache = { }
local lastCommandNum = nil
local commandSeedIncr = 0
local isForcedMulti
isForcedMulti = function(wep)
  local wepClass = wep:GetClass()
  local cached = forceMultiClassCache[wepClass]
  if cached ~= nil then
    return cached
  end
  local getter = FORCE_MULTI_CLASSES[wepClass]
  if not getter then
    for _index_0 = 1, #FORCE_MULTI_CLASS_STARTS do
      local _continue_0 = false
      repeat
        do
          local start, newGetter = FORCE_MULTI_CLASS_STARTS[_index_0]
          if not (string.StartsWith(wepClass, start)) then
            _continue_0 = true
            break
          end
          getter = newGetter
          break
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  if not getter then
    forceMultiClassCache[wepClass] = false
    return false
  end
  local num = (type(getter == "function")) and (getter(wep)) or wep[getter] or 1
  local forcedMulti = num > 1
  forceMultiClassCache[wepClass] = forcedMulti
  return forcedMulti
end
local ShotgunPowerupHandler
do
  local _class_0
  local _base_0 = {
    BulletWatcher = function(self)
      return function(ent, bullet)
        if not (ent == self.owner) then
          return 
        end
        local num = bullet.Num
        if num > 1 then
          bullet.Num = math.ceil(bullet.Num * self.multiBulletsMult)
          bullet.Damage = bullet.Damage * self.multiDamageMult
          return 
        end
        local wep = ent:GetActiveWeapon()
        if not (IsValid(wep)) then
          return 
        end
        local commandNum = lastCommandNum
        if GetPredictionPlayer() == ent then
          commandNum = ent:GetCurrentCommand():CommandNumber()
        end
        if commandNum == lastCommandNum then
          commandSeedIncr = commandSeedIncr + 1
        else
          lastCommandNum = commandNum
          commandSeedIncr = 0
          wep:EmitSound("weapons/shotgun/shotgun_fire6.wav", 75, 100, 1, CHAN_WEAPON)
        end
        local seed = ent:EntIndex() .. commandNum .. commandSeedIncr
        if not isForcedMulti(wep) then
          bullet.Num = util.SharedRandom(seed, self.singleBulletsMin, self.singleBulletsMax)
          bullet.Damage = bullet.Damage * self.singleDamageMult
          local spread = bullet.Spread
          local spreadMult = self.singleSpreadMult
          local spreadAdd = self.singleSpreadAdd
          spread.x = spread.x * spreadMult + spreadAdd
          spread.y = spread.y * spreadMult + spreadAdd
          return 
        end
        bullet.Damage = bullet.Damage * self.multiDamageMult
        local multiBulletsMult = self.multiBulletsMult
        local newNum = math.floor(multiBulletsMult)
        local leftover = multiBulletsMult - newNum
        if leftover > 0 then
          if (util.SharedRandom(seed, 0, 1)) < leftover then
            newNum = newNum + 1
          end
        end
        bullet.Num = newNum
      end
    end,
    ApplyEffect = function(self)
      return hook.Add("EntityFireBullets", self.hookName, self:BulletWatcher())
    end,
    Remove = function(self)
      return hook.Remove("EntityFireBullets", self.hookName)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, owner, singleBulletsMin, singleBulletsMax, singleDamageMult, singleSpreadMult, singleSpreadAdd, multiBulletsMult, multiDamageMult)
      self.owner = owner
      self.singleBulletsMin = singleBulletsMin
      self.singleBulletsMax = singleBulletsMax
      self.singleDamageMult = singleDamageMult
      self.singleSpreadMult = singleSpreadMult
      self.singleSpreadAdd = singleSpreadAdd
      self.multiBulletsMult = multiBulletsMult
      self.multiDamageMult = multiDamageMult
      self.ownerSteamID64 = self.owner:SteamID64()
      self.hookName = "CFC-Powerups_Shotgun-" .. tostring(self.ownerSteamID64)
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "ShotgunPowerupHandler"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ShotgunPowerupHandler = _class_0
end
CFCPowerups.SharedHandlers.ShotgunPowerupHandler = ShotgunPowerupHandler

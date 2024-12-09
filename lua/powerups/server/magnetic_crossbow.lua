local getConf
getConf = CFCPowerups.Config.get
local IsValid
IsValid = _G.IsValid
local SpriteTrail
SpriteTrail = util.SpriteTrail
local cos, rad
do
  local _obj_0 = math
  cos, rad = _obj_0.cos, _obj_0.rad
end
local FindInCone
FindInCone = ents.FindInCone
local insert, SortByMember
do
  local _obj_0 = table
  insert, SortByMember = _obj_0.insert, _obj_0.SortByMember
end
local WatchedBolt
do
  local _class_0
  local _base_0 = {
    createHolo = function(self)
      local holo = ents.Create("base_anim")
      do
        holo:SetPos(self.bolt:GetPos())
        holo:SetModel("")
        holo:SetRenderMode(RENDERMODE_NONE)
        holo:SetMoveType(MOVETYPE_NONE)
        holo:DrawShadow(false)
        holo:Spawn()
        holo:SetParent(self.bolt)
      end
      return holo
    end,
    startSound = function(self)
      if self.soundId then
        return 
      end
      self.soundId = self.holo:StartLoopingSound(self.soundPath)
    end,
    stopSound = function(self)
      if not (self.soundId) then
        return 
      end
      return self.holo:StopLoopingSound(self.soundId)
    end,
    addTrail = function(self)
      local lingerTime = getConf("magnetic_crossbow_effect_linger_time")
      local color = Color(255, 0, 0)
      local texture = "trails/plasma"
      local attachmentId = 0
      local additive = false
      local startWidth = 15
      local endWidth = 1
      local textureRes = 1 / (startWidth + endWidth) * 0.5
      return SpriteTrail(self.holo, attachmentId, color, additive, startWidth, endWidth, lingerTime, textureRes, texture)
    end,
    pointTowardsTarget = function(self, target)
      local targetPos = target:GetPos() + self.targetOffset
      local newVel = targetPos - self.bolt:GetPos()
      self.bolt:SetVelocity(self.bolt:GetVelocity() * -1)
      return timer.Simple(0.01, function()
        return self.bolt:SetVelocity(newVel * getConf("magnetic_crossbow_speed_multiplier"))
      end)
    end,
    canTargetPlayer = function(self, ply)
      if ply == self.boltShooter then
        return false
      end
      if not (ply:IsPlayer()) then
        return false
      end
      if not (ply:Alive()) then
        return false
      end
      if not (ply:IsInPvp()) then
        return false
      end
      if not (self.bolt:TestPVS(ply)) then
        return false
      end
      return true
    end,
    canTargetEnt = function(self, ent)
      if not (IsValid(ent)) then
        return false
      end
      local isValidNPC = ent:IsNPC() and ent:Health() > 0
      local isValidPlayer = self:canTargetPlayer(ent)
      return isValidNPC or isValidPlayer
    end,
    getPotentialTargets = function(self)
      local origin = self.bolt:GetPos()
      local normal = self.bolt:GetVelocity()
      local range = getConf("magnetic_crossbow_cone_range")
      local angle = cos(rad(getConf("magnetic_crossbow_cone_arc")))
      local potentialTargets = FindInCone(origin, normal, 300, self.findAngle)
      local eligableTargets = { }
      for _index_0 = 1, #potentialTargets do
        local _continue_0 = false
        repeat
          local target = potentialTargets[_index_0]
          if not (self:canTargetEnt(target)) then
            _continue_0 = true
            break
          end
          insert(eligableTargets, {
            target = target,
            distanceSqr = self.bolt:GetPos():DistToSqr(target:WorldSpaceCenter())
          })
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
      SortByMember(eligableTargets, "distanceSqr")
      return eligableTargets
    end,
    handleMovement = function(self)
      if not (IsValid(self.bolt)) then
        return 
      end
      self.holo:SetPos(self.bolt:GetPos())
      local targets = self:getPotentialTargets()
      if not (targets and #targets > 0) then
        return 
      end
      local closestTarget = targets[1].target
      if not (IsValid(closestTarget)) then
        return 
      end
      timer.Remove(self.movementHandler)
      local point
      point = function()
        if not (IsValid(self.bolt)) then
          return 
        end
        if not (IsValid(closestTarget)) then
          return 
        end
        return self:pointTowardsTarget(closestTarget)
      end
      point()
      return timer.Simple(0.1, point)
    end,
    cleanup = function(self)
      self:stopSound()
      local lingerTime = getConf("magnetic_crossbow_effect_linger_time")
      return timer.Simple(lingerTime, function()
        return self.holo:Remove()
      end)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, bolt)
      self.bolt = bolt
      self.boltShooter = self.bolt:GetSaveTable()["m_hOwnerEntity"]
      self.holo = self:createHolo()
      self.movementHandler = "CFC-Powerups-TrackedBolt-" .. tostring(bolt:EntIndex())
      self.soundPath = getConf("magnetic_crossbow_magnet_sound")
      self.soundId = nil
      self.targetOffset = Vector(0, 0, 36)
      self.findAngle = cos(rad(35))
      self:addTrail()
      timer.Create(self.movementHandler, 0, 0, function()
        return self:handleMovement()
      end)
      return self.bolt:CallOnRemove("CFC-Powerups-Remove-Handler", function()
        return self:cleanup()
      end)
    end,
    __base = _base_0,
    __name = "WatchedBolt"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  WatchedBolt = _class_0
end
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    CreateWatchedBolt = function(self, bolt)
      self.UsesRemaining = self.UsesRemaining - 1
      WatchedBolt(bolt)
      if self.UsesRemaining == 0 then
        return self:Remove()
      end
    end,
    CrossbowWatcher = function(self)
      return function(ent)
        if not (IsValid(ent)) then
          return 
        end
        if not (ent:GetClass() == "crossbow_bolt") then
          return 
        end
        return timer.Simple(0, function()
          if not (IsValid(ent)) then
            return 
          end
          if not (ent:GetSaveTable()["m_hOwnerEntity"] == self.owner) then
            return 
          end
          return self:CreateWatchedBolt(ent)
        end)
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      hook.Add("OnEntityCreated", self.PowerupHookName, self:CrossbowWatcher())
      return self.owner:ChatPrint("You've gained " .. tostring(self.UsesRemaining) .. " Magnetic Crossbow Bolts")
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      local usesGained = getConf("magnetic_crossbow_uses")
      self.UsesRemaining = self.UsesRemaining + usesGained
      return self.owner:ChatPrint("You've gained " .. tostring(usesGained) .. " extra Magnetic Crossbow Bolts (total: " .. tostring(self.UsesRemaining) .. ")")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      hook.Remove("OnEntityCreated", self.PowerupHookName)
      self.owner:ChatPrint("You've lost the Magnetic Crossbow Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.PowerupHookName = "CFC-Powerups_MagneticCrossbow-" .. tostring(self.owner:SteamID64())
      self.UsesRemaining = getConf("magnetic_crossbow_uses")
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "MagneticCrossbowPowerup",
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
  self.powerupID = "powerup_magnetic_crossbow"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  MagneticCrossbowPowerup = _class_0
  return _class_0
end

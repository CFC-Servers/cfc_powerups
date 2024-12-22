local getConf
getConf = CFCPowerups.Config.get
local CLUSTER_BALL_COLOR = Color(255, 0, 0)
local CLUSTER_LAUNCH_SOUND = "cfc/seismic-charge-bass.wav"
local CLUSTER_LAUNCH_VOLUME = 500
local TIGHTNESS = 100
local HORIZONTAL_SPREAD = 20
local VERTICAL_SPREAD = 10
local getRandomizedVelocity
getRandomizedVelocity = function(original)
  local x = TIGHTNESS
  local y = math.random(-HORIZONTAL_SPREAD, HORIZONTAL_SPREAD)
  local z = math.random(-VERTICAL_SPREAD, VERTICAL_SPREAD)
  local newVel = Vector(x, y, z)
  newVel:Rotate(original:Angle())
  newVel:Normalize()
  return newVel
end
local setClusterVelocity
setClusterVelocity = function(ball, parentVel)
  local newVel = getRandomizedVelocity(parentVel)
  local maxSpeed = getConf("cball_speed")
  return ball:GetPhysicsObject():SetVelocity(newVel * maxSpeed)
end
local configureClusterBall
configureClusterBall = function(ball)
  ball:SetSaveValue("m_bHeld", true)
  ball:SetColor(CLUSTER_BALL_COLOR)
  util.SpriteTrail(ball, 0, CLUSTER_BALL_COLOR, true, 10, 1, 1, 1, "trails/laser")
  ball.IsClusteredBall = true
  return ball:EmitSound(CLUSTER_LAUNCH_SOUND, CLUSTER_LAUNCH_VOLUME)
end
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    GiveAmmo = function(self, count)
      for i = 1, count + 1 do
        self.owner:Give("item_ammo_ar2_altfire")
      end
    end,
    IsClusteredByOwner = function(self, ball)
      if ball:GetOwner() == self.owner then
        return true
      end
      local spawner = ball:GetSaveTable()["m_hSpawner"]
      if not IsValid(spawner) then
        return false
      end
      if spawner:GetOwner() == self.owner then
        return true
      end
    end,
    MakeClusterFor = function(self, parent)
      local spawner = ents.Create("point_combine_ball_launcher")
      local speed = getConf("cball_speed")
      local maxBounces = getConf("cball_bounces")
      spawner:SetPos(parent:GetPos())
      spawner:SetKeyValue("minspeed", speed)
      spawner:SetKeyValue("maxspeed", speed)
      spawner:SetKeyValue("ballradius", "15")
      spawner:SetKeyValue("ballcount", "0")
      spawner:SetKeyValue("maxballbounces", tostring(maxBounces))
      spawner:SetKeyValue("launchconenoise", 360)
      spawner:Spawn()
      spawner:SetOwner(self.owner)
      for _ = 0, getConf("cball_balls_per_cluster") do
        spawner:Fire("LaunchBall")
      end
      timer.Simple(0.15, function()
        return spawner:Fire("kill", "", 0)
      end)
      if self.RemainingClusterBalls <= 0 then
        return timer.Simple(0.15, function()
          return self:Remove()
        end)
      end
    end,
    ClusterBallWatcher = function(self)
      return function(thing)
        if thing:GetClass() ~= "prop_combine_ball" then
          return 
        end
        if thing.IsClusteredBall then
          return 
        end
        return timer.Simple(0, function()
          if self:IsClusteredByOwner(thing) then
            setClusterVelocity(thing, self.ParentBallVelocity)
            thing:SetOwner(self.owner)
            return configureClusterBall(thing)
          end
          local ballOwner = thing.FiredBy or thing:GetOwner()
          if ballOwner ~= self.owner then
            return 
          end
          local clusterDelay = getConf("cball_cluster_delay")
          timer.Simple(clusterDelay, function()
            self.ParentBallVelocity = thing:GetPhysicsObject():GetVelocity()
            return self:MakeClusterFor(thing)
          end)
          self.RemainingClusterBalls = self.RemainingClusterBalls - 1
        end)
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      local ballsToCluster = getConf("cball_uses")
      hook.Remove("OnEntityCreated", self.PowerupHookName)
      local watcher = self:ClusterBallWatcher()
      hook.Add("OnEntityCreated", self.PowerupHookName, watcher)
      local ar2 = "weapon_ar2"
      local ar2Ammo = 2
      do
        local _with_0 = self.owner
        _with_0:Give(ar2)
        _with_0:GiveAmmo(ballsToCluster, ar2Ammo, true)
        _with_0:SelectWeapon(ar2)
        _with_0:ChatPrint("You've gained " .. tostring(ballsToCluster) .. " uses of the Cluster Combine balls.")
        return _with_0
      end
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      local ballsToCluster = getConf("cball_uses")
      self.RemainingClusterBalls = self.RemainingClusterBalls + ballsToCluster
      self:GiveAmmo(ballsToCluster)
      return self.owner:ChatPrint("You've gained " .. tostring(ballsToCluster) .. " more uses of the Cluster Combine balls. (Total: " .. tostring(self.RemainingClusterBalls) .. ")")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      hook.Remove("OnEntityCreated", self.PowerupHookName)
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:ChatPrint("You've lost the Cluster Combine balls Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      local ownerSteamID = self.owner:SteamID64()
      self.PowerupHookName = "CFC_Powerups_ClusterBalls-" .. tostring(ownerSteamID)
      self.RemainingClusterBalls = getConf("cball_uses")
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "ClusterBallPowerup",
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
  self.powerupID = "powerup_cluster_balls"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ClusterBallPowerup = _class_0
  return _class_0
end

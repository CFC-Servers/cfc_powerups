include("base.lua")
local CLUSTER_DELAY = 0.3
local BALLS_PER_CLUSTER = 15
local MAX_BALLS_TO_CLUSTER = 3
local MIN_BALL_SPEED = 1500
local MAX_BALL_SPEED = 1500
local MAX_BALL_BOUNCES = 8
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
  return ball:GetPhysicsObject():SetVelocity(newVel * MAX_BALL_SPEED)
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
    IsClusteredByOwner = function(self, ball)
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
      spawner:SetPos(parent:GetPos())
      spawner:SetKeyValue("minspeed", MIN_BALL_SPEED)
      spawner:SetKeyValue("maxspeed", MAX_BALL_SPEED)
      spawner:SetKeyValue("ballradius", "15")
      spawner:SetKeyValue("ballcount", "0")
      spawner:SetKeyValue("maxballbounces", tostring(MAX_BALL_BOUNCES))
      spawner:SetKeyValue("launchconenoise", 360)
      spawner:Spawn()
      spawner:SetOwner(self.owner)
      for _ = 0, BALLS_PER_CLUSTER do
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
            return configureClusterBall(thing)
          end
          local ballOwner = thing.FiredBy or thing:GetOwner()
          if ballOwner ~= self.owner then
            return 
          end
          timer.Simple(CLUSTER_DELAY, function()
            self.ParentBallVelocity = thing:GetPhysicsObject():GetVelocity()
            return self:MakeClusterFor(thing)
          end)
          self.RemainingClusterBalls = self.RemainingClusterBalls - 1
        end)
      end
    end,
    ApplyEffect = function(self)
      hook.Remove("OnEntityCreated", self.PowerupHookName)
      local watcher = self:ClusterBallWatcher()
      return hook.Add("OnEntityCreated", self.PowerupHookName, watcher)
    end,
    Refresh = function(self)
      self.RemainingClusterBalls = self.RemainingClusterBalls + MAX_BALLS_TO_CLUSTER
      return self.owner:ChatPrint("You've gained " .. tostring(MAX_BALLS_TO_CLUSTER) .. " more uses of the Cluster Combine balls. (Total: " .. tostring(self.RemainingClusterBalls) .. ")")
    end,
    Remove = function(self)
      self.owner:ChatPrint("You've lost the Cluster Powerup")
      hook.Remove("OnEntityCreated", self.PowerupHookName)
      if not IsValid(self.owner) then
        return 
      end
      self.owner.Powerups[POWERUP_ID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      local ownerSteamID = self.owner:SteamID64()
      self.PowerupHookName = "CFC_Powerups_ClusterBalls-" .. tostring(ownerSteamID)
      self.RemainingClusterBalls = MAX_BALLS_TO_CLUSTER
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
    1,
    1,
    1,
    1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ClusterBallPowerup = _class_0
  return _class_0
end

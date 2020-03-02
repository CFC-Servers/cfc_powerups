AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local CLUSTER_DELAY = 0.3
local BALLS_PER_CLUSTER = 15
local MAX_BALLS_TO_CLUSTER = 3
local MIN_BALL_SPEED = 1500
local MAX_BALL_SPEED = 1500
local MAX_BALL_BOUNCES = 8
local CLUSTER_BALL_COLOR = Color(255, 0, 0)
local CLUSTER_LAUNCH_SOUND = "beams/beamstart5.wav"
local CLUSTER_LAUNCH_VOLUME = 500
local configureClusterBall
configureClusterBall = function(ball)
  ball:SetSaveValue("m_bHeld", true)
  ball:SetColor(CLUSTER_BALL_COLOR)
  util.SpriteTrail(ball, 0, CLUSTER_BALL_COLOR, true, 10, 1, 1, 1, "trails/laser")
  ball.IsClusteredBall = true
end
local makeClusterFor
makeClusterFor = function(parent, owner)
  local spawner = ents.Create("point_combine_ball_launcher")
  spawner:SetPos(parent:GetPos())
  spawner:SetKeyValue("minspeed", MIN_BALL_SPEED)
  spawner:SetKeyValue("maxspeed", MAX_BALL_SPEED)
  spawner:SetKeyValue("ballradius", "15")
  spawner:SetKeyValue("ballcount", "0")
  spawner:SetKeyValue("maxballbounces", tostring(MAX_BALL_BOUNCES))
  spawner:SetKeyValue("launchconenoise", 360)
  spawner:Spawn()
  spawner:SetOwner(owner)
  for _ = 0, BALLS_PER_CLUSTER do
    spawner:Fire("LaunchBall")
    parent:EmitSound(CLUSTER_LAUNCH_SOUND, CLUSTER_LAUNCH_VOLUME)
  end
  return timer.Simple(0.2, function()
    return spawner:Fire("kill", "", 0)
  end)
end
local isClusteredBy
isClusteredBy = function(ball, owner)
  local spawner = ball:GetSaveTable()["m_hSpawner"]
  if not IsValid(spawner) then
    return false
  end
  if spawner:GetOwner() == owner then
    return true
  end
end
local createWatcherFor
createWatcherFor = function(ply)
  return function(thing)
    if thing:GetClass() ~= "prop_combine_ball" then
      return 
    end
    if thing.IsClusteredBall then
      return 
    end
    return timer.Simple(0, function()
      if isClusteredBy(thing, ply) then
        return configureClusterBall(thing)
      end
      local ballOwner = thing.FiredBy or thing:GetOwner()
      if ballOwner ~= ply then
        return 
      end
      timer.Simple(CLUSTER_DELAY, function()
        return makeClusterFor(thing, ply)
      end)
      local existingPowerup = ply:GetPowerup(ENT.PowerupName)
      existingPowerup.RemainingClusterBalls = existingPowerup.RemainingClusterBalls - 1
      if existingPowerup.RemainingClusterBalls <= 0 then
        return existingPowerup.RemovePowerup()
      end
    end)
  end
end
ENT.PowerupEffect = function(self, ply)
  local plySteamID = ply:GetSteamID64()
  local powerupHookName = "CFC_Powerups_ClusterBalls-" .. tostring(plySteamID)
  local plyClusterWatcher = createWatcherFor(ply)
  hook.Remove("OnEntityCreated", powerupHookName)
  hook.Add("OnEntityCreated", powerupHookName, plyClusterWatcher)
  self.PowerupInfo.RemainingClusterBalls = MAX_BALLS_TO_CLUSTER
  self.PowerupInfo.RemovePowerup = function()
    hook.Remove("OnEntityCreated", powerupHookName)
    return ply:ChatPrint("You've lost the Cluster Powerup")
  end
end
ENT.PowerupRefresh = function(self, ply)
  local existingPowerup = ply:GetPowerup(self.PowerupName)
  existingPowerup.RemainingClusterBalls = existingPowerup.RemainingClusterBalls + MAX_BALLS_TO_CLUSTER
end

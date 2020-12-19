local getConf
getConf = CFCPowerups.Config.get
local FindByClass
FindByClass = ents.FindByClass
PowerupSpawner = {
  spawnIntervalTimerName = "CFC_Powerups_SpawnInterval",
  pickupWatcherName = "CFC_Powerups_PickupWatcher",
  findAllPowerups = function()
    return FindByClass("powerup_*")
  end,
  removeAllPowerups = function()
    local _list_0 = PowerupSpawner.findAllPowerups()
    for _index_0 = 1, #_list_0 do
      local ent = _list_0[_index_0]
      if ent.spawnedAutomatically then
        ent:Remove()
      end
    end
  end,
  getRandomPowerup = function(tier)
    local CFCBasePowerup = CFCPowerups["base_cfc_powerup"]
    local sumOfWeights = CFCBasePowerup.powerupTotalWeights[tier] - 1
    local randomIndex = math.random(0, sumOfWeights)
    local _list_0 = CFCBasePowerup.powerupList
    for _index_0 = 1, #_list_0 do
      local powerup = _list_0[_index_0]
      if randomIndex < powerup.powerupWeights[tier] then
        return powerup
      end
      randomIndex = randomIndex - powerup.powerupWeights[tier]
    end
  end,
  getShuffledSpawnLocations = function(tier)
    local spawnLocations = table.Copy(CFCPowerups.spawnLocations[tier])
    for i = #spawnLocations, 2, -1 do
      local j = math.random(i)
      spawnLocations[i], spawnLocations[j] = spawnLocations[j], spawnLocations[i]
    end
    return spawnLocations
  end,
  getRandomSpawnLocations = function(tier)
    local tierSpawnDivider = {
      tier1 = 2,
      tier2 = 3,
      tier3 = 4,
      tier4 = 5
    }
    local allSpawnLocations = PowerupSpawner.getShuffledSpawnLocations(tier)
    local spawnCount = math.floor(#allSpawnLocations / tierSpawnDivider[tier])
    local spawnLocations = { }
    for i = 1, spawnCount do
      table.insert(spawnLocations, allSpawnLocations[i])
    end
    return spawnLocations
  end,
  spawnPowerup = function(powerupClass, position)
    do
      local _with_0 = ents.Create(powerupClass)
      _with_0.spawnedAutomatically = true
      _with_0.originalPos = position
      _with_0:SetPos(position)
      _with_0:Spawn()
      _with_0:EmitSound(getConf("spawn_sound", 90))
      return _with_0
    end
  end,
  spawnRandomPowerups = function()
    PowerupSpawner.removeAllPowerups()
    for tier = 1, 4 do
      local tierName = "tier" .. tostring(tier)
      local spawnLocations = PowerupSpawner.getRandomSpawnLocations(tierName)
      for _index_0 = 1, #spawnLocations do
        local location = spawnLocations[_index_0]
        local powerupClass = PowerupSpawner.getRandomPowerup(tierName).powerupID
        PowerupSpawner.spawnPowerup(powerupClass, location)
      end
    end
  end,
  watchForPickup = function()
    local _list_0 = player.GetAll()
    for _index_0 = 1, #_list_0 do
      local ply = _list_0[_index_0]
      local _list_1 = PowerupSpawner.findAllPowerups()
      for _index_1 = 1, #_list_1 do
        local _continue_0 = false
        repeat
          local powerup = _list_1[_index_1]
          local distance = powerup:GetPos():DistToSqr(ply:GetPos())
          local threshold = powerup.PickupDistance * powerup.PickupDistance
          if not (distance < threshold) then
            _continue_0 = true
            break
          end
          powerup:GivePowerup(ply)
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
    end
  end,
  stop = function(self)
    timer.Remove(self.spawnIntervalTimerName)
    return timer.Remove(self.pickupWatcherName)
  end,
  start = function(self)
    local spawnDelay = getConf("spawn_delay")
    timer.Create(self.spawnIntervalTimerName, spawnDelay, 0, PowerupSpawner.spawnRandomPowerups)
    return timer.Create(self.pickupWatcherName, 0.25, 0, PowerupSpawner.watchForPickup)
  end
}
concommand.Add("cfc_powerups_enable_spawner", function()
  return PowerupSpawner:start()
end)
concommand.Add("cfc_powerups_disable_spawner", function()
  return PowerupSpawner:stop()
end)
CreateConVar("cfc_powerups_spawner_enabled", 1, FCVAR_ARCHIVE, "Whether or not powerups automatically spawn on the map", 0, 1)
local shouldStart = GetConVar("cfc_powerups_spawner_enabled")
shouldStart = shouldStart and (shouldStart:GetInt() == 1)
if shouldStart then
  return PowerupSpawner:start()
end

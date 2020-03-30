PowerupManager = {
  hasPowerup = function(ply, powerupId)
    return ply.Powerups[powerupId] ~= nil
  end,
  givePowerup = function(ply, powerupId)
    local existingPowerup = ply.Powerups[powerupId]
    if existingPowerup then
      return existingPowerup:Refresh()
    end
    ply.Powerups[powerupId] = CFCPowerups[powerupId](ply)
  end,
  plyCanGetPowerup = function(ply, powerupId)
    local existingPowerup = ply.Powerups[powerupId]
    if not existingPowerup then
      return true
    end
    if existingPowerup.RequiresPvP and ply:GetNWBool("CFC_PvP_Mode", false) == false then
      return false
    end
    if not ply:Alive() then
      return false
    end
    return true
  end,
  refreshPowerup = function(ply, powerupId)
    local existingPowerup = ply.Powerups[powerupId]
    if existingPowerup then
      return existingPowerup:Refresh()
    end
  end,
  getRandomPowerup = function(tier)
    local CFCBasePowerup = CFCPowerups["base_cfc_powerup"]
    local sumOfWeights = CFCBasePowerup.powerupTotalWeights[tier] - 1
    local randomIndex = math.random(0, sumOfWeights)
    for name, powerup in pairs(CFCBasePowerup.powerupList) do
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
    local allSpawnLocations = PowerupManager.getShuffledSpawnLocations(tier)
    local spawnCount = math.floor(#allSpawnLocations / (tier + 1))
    local spawnLocations = { }
    for i = 1, spawnCount do
      table.insert(spawnLocations, allSpawnLocations[i])
    end
    return spawnLocations
  end,
  spawnRandomPowerups = function()
    for tier = 1, 4 do
      local spawnLocations = PowerupManager.getRandomSpawnLocations(tier)
      for _, location in ipairs(spawnLocations) do
        local powerupClass = PowerupManager.getRandomPowerup().powerupID
        local powerup = ents.Create(powerupClass)
        powerup:SetPos(location)
        powerup:Spawn()
      end
    end
  end
}

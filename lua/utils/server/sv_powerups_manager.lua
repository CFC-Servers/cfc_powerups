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
    local powerupBase = CFCPowerups[powerupId]
    local existingPowerup = ply.Powerups[powerupId]
    if existingPowerup then
      return existingPowerup.IsRefreshable
    end
    local baseRequiresPvp = powerupBase.RequiresPvp
    if not (baseRequiresPvp) then
      return true
    end
    if ply:IsInPvp() then
      return true
    end
    return false
  end,
  refreshPowerup = function(ply, powerupId)
    local existingPowerup = ply.Powerups[powerupId]
    if not (existingPowerup) then
      return 
    end
    return existingPowerup:Refresh()
  end
}

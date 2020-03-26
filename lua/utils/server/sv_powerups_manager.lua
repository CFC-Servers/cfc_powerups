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
  end
}

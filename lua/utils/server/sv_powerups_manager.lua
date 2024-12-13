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
    local blocked, denyReason = hook.Run("CFC_Powerups_DisallowGetPowerup", ply, powerupId, existingPowerup)
    if blocked == true then
      return false, denyReason
    end
    if existingPowerup then
      local refreshable = existingPowerup.IsRefreshable
      if refreshable then
        return true
      end
      return false, "This powerup cannot be refreshed"
    end
    local baseRequiresPvp = powerupBase.RequiresPvp
    if not (baseRequiresPvp) then
      return true
    end
    if ply:IsInPvp() then
      return true
    end
    return false, "This powerup requires PvP mode"
  end,
  refreshPowerup = function(ply, powerupId)
    local existingPowerup = ply.Powerups[powerupId]
    if not (existingPowerup) then
      return 
    end
    return existingPowerup:Refresh()
  end
}

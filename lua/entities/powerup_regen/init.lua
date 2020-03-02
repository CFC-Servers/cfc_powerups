AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.PowerupEffect = function(self, ply)
  local maxHp = 150
  local powerupDuration = 300
  local regenInterval = 0.1
  local regenAmount = 3
  local timerName = tostring(ply:SteamID64()) .. "-Regen-Powerup"
  self.PowerupInfo.RegenSound = CreateSound(ply, "items/medcharge4.wav")
  self.PowerupInfo.PlayingRegenSound = false
  local powerupTick
  powerupTick = function()
    local hp = ply:Health()
    local powerup = ply:GetPowerUp(self.PowerupName)
    if hp < maxHp then
      if not powerup.PlayingRegenSound then
        powerup.RegenSound:Play()
        powerup.PlayingRegenSound = true
      end
      local newHp = math.Clamp(hp + regenAmount, 0, maxHp)
      return ply:SetHealth(newHp)
    else
      if powerup.PlayingRegenSound then
        powerup.RegenSound:Stop()
        powerup.PlayingRegenSound = false
      end
    end
  end
  timer.Create(timerName, regenInterval, powerupDuration / regenInterval, powerupTick)
  self.PowerupInfo.RemovePowerup = function(self)
    timer.Remove(timerName)
    local powerup = ply:GetPowerup(ENT.PowerupName)
    powerup.RegenSound:Stop()
    return ply:ChatPrint("You've lost the Regen Powerup")
  end
  local removalTimer = timerName .. "-Removal"
  return timer.Create(removalTimer, powerupDuration, 1, self.PowerupInfo.RemovePowerup)
end
ENT.RefreshPowerup = function(self, ply)
  local timerName = tostring(ply:SteamID64()) .. "-Regen-Powerup"
  return timer.Start(timerName)
end

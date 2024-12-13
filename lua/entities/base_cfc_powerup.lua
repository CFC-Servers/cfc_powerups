AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")
ENT.Type = "anim"
ENT.PrintName = "Base CFC Powerup"
ENT.Purpose = "Base Powerup for CFC Powerups"
ENT.Author = "CFC"
ENT.Contact = "cfcservers.org/discord"
ENT.Category = "Powerups"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Powerup = "base_cfc_powerup"
ENT.Sounds = {
  Pickup = "vo/npc/female01/hacks01.wav",
  PickupFailed = "common/warning.wav"
}
ENT.Model = "models/cfc/powerups/powerup.mdl"
ENT.Color = Color(255, 255, 255)
ENT.PickupDistance = 50
ENT.FailedPickups = { }
if CLIENT then
  ENT.Draw = function(self)
    return self:DrawModel()
  end
  return 
end
ENT.Initialize = function(self)
  self:SetModel(self.Model)
  self:SetColor(self.Color)
  self:SetMoveType(MOVETYPE_NOCLIP)
  self:PhysicsInit(SOLID_NONE)
  return self:Activate()
end
ENT.GivePowerup = function(self, ply)
  if not (IsValid(ply)) then
    return 
  end
  local alertThreshold = 1
  local lastFailedPickup = self.FailedPickups[ply]
  local canGivePowerup, denyReason = PowerupManager.plyCanGetPowerup(ply, self.Powerup)
  local shouldThrottleMessage = lastFailedPickup and (CurTime() - lastFailedPickup) < alertThreshold
  if not (canGivePowerup) then
    if shouldThrottleMessage then
      return 
    end
    self:EmitSound(self.Sounds.PickupFailed)
    denyReason = denyReason or "Maybe it requires PvP mode or maybe you already have it"
    ply:ChatPrint("You can't use this powerup right now! (" .. tostring(denyReason) .. ")")
    self.FailedPickups[ply] = CurTime()
    return 
  end
  if PowerupManager.hasPowerup(ply, self.Powerup) then
    local existingPowerup = ply.Powerups[self.Powerup]
    if existingPowerup.IsRefreshable then
      self:EmitSound(self.Sounds.Pickup)
      PowerupManager.refreshPowerup(ply, self.Powerup)
      self:Remove()
    else
      self:EmitSound(self.Sounds.PickupFailed)
      ply:ChatPrint("This Powerup cannot be refreshed!")
    end
    return 
  end
  self:EmitSound(self.Sounds.Pickup)
  PowerupManager.givePowerup(ply, self.Powerup)
  return self:Remove()
end

AddCSLuaFile()
DEFINE_BASECLASS("base_gmodentity")
ENT.Type = "anim"
ENT.PrintName = "Base CFC Powerup"
ENT.Purpose = "Base Powerup for CFC Powerups"
ENT.Author = "CFC"
ENT.Contact = "cfcservers.org/discord"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Powerup = "base-cfc-powerup"
ENT.Sounds = {
  Pickup = "vo/npc/female01/hacks01.wav",
  PickupFailed = "common/warning.wav"
}
ENT.Model = "models/powerups/minigun.mdl"
if CLIENT then
  ENT.Draw = function(self)
    return self:DrawModel()
  end
end
if CLIENT then
  return 
end
ENT.Initialize = function(self)
  self:SetModel(self.Model)
  self:SetMoveType(MOVETYPE_NONE)
  return self:PhysicsInit(SOLID_VPHYSICS)
end
ENT.GivePowerup = function(self, ply)
  if not PowerupManager.plyCanGetPowerup(ply, self.Powerup) then
    self:EmitSound(self.Sounds.PickupFailed)
    return 
  end
  if PowerupManager.hasPowerup(ply, self.Powerup) then
    local existingPowerup = ply.Powerups[self.Powerup]
    if existingPowerup.IsRefreshable then
      self:EmitSound(self.Sounds.Pickup)
      PowerupManager.refreshPowerup(ply, self.Powerup)
      self:Remove()
      return 
    else
      self:EmitSound(self.Sounds.PickupFailed)
      ply:ChatPrint("This Powerup cannot be refreshed!")
      return 
    end
  end
  self:EmitSound(self.Sounds.Pickup)
  PowerupManager.givePowerup(ply, self.Powerup)
  return self:Remove()
end
ENT.Use = function(self, activator)
  return self:GivePowerup(activator)
end

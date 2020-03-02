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
ENT.PowerupName = "base-cfc-powerup"
ENT.PickupFailed = "common/warning.wav"
ENT.PickupSound = "vo/npc/female01/hacks01.wav"
ENT.Model = "models/props/cs_assault/money.mdl"
ENT.RemoveOnDeath = true
ENT.RequiresPvp = true
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
  self:PhysicsInit(SOLID_NONE)
  self.PowerupInfo = self.PowerupInfo or { }
  self.PowerupInfo.Name = self.PowerupName
  self.PowerupInfo.RemoveOnDeath = self.RemoveOnDeath
  self.PowerupInfo.RequiresPvp = self.RequiresPvp
end
ENT.PowerupEffect = function(self, ply)
  ply:ChatPrint("Powerup Get!")
  return ply:Kill()
end
ENT.GivePowerup = function(self, ply)
  if self.RequiresPvp and ply:GetNWBool("CFC_PvP_Mode", false) == false then
    self:EmitSound(self.PickupFailed)
    ply:ChatPrint("This Powerup requires PvP mode!")
    return 
  end
  if ply:HasPowerup(self.PowerupName) then
    return self:PowerupRefresh(ply)
  end
  self:EmitSound(self.PickupSound)
  self:PowerupEffect(ply)
  ply:AddPowerup(self.PowerupInfo)
  return self:Remove()
end
ENT.Use = function(self, activator)
  return self:GivePowerup(activator)
end
ENT.RefreshPowerup = function(self, ply)
  self:EmitSound(self.PickupFailed)
  return ply:ChatPrint("You can't pick up this powerup again!")
end

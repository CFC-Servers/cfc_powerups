AddCSLuaFile!

DEFINE_BASECLASS "base_gmodentity"

ENT.Type          = "anim"
ENT.PrintName     = "Base CFC Powerup"
ENT.Purpose       = "Base Powerup for CFC Powerups"
ENT.Author        = "CFC"
ENT.Contact       = "cfcservers.org/discord"
ENT.RenderGroup	  = RENDERGROUP_OPAQUE

ENT.Spawnable     = false
ENT.AdminOnly     = false

ENT.Powerup       = "base_cfc_powerup"

ENT.Sounds        = {
    Pickup: "vo/npc/female01/hacks01.wav",
    PickupFailed: "common/warning.wav"
}

ENT.Model         = "models/powerups/minigun.mdl"

-- Client --

if CLIENT
   ENT.Draw = =>
       @DrawModel!

-- Shared --

if CLIENT return

ENT.Initialize = =>
    @SetModel @Model
    @SetMoveType MOVETYPE_NONE
    @PhysicsInit SOLID_VPHYSICS

ENT.GivePowerup = (ply) =>
    if not PowerupManager.plyCanGetPowerup ply, @Powerup
        @EmitSound @Sounds.PickupFailed
        return

    if PowerupManager.hasPowerup ply, @Powerup
        existingPowerup = ply.Powerups[@Powerup]

        if existingPowerup.IsRefreshable
            @EmitSound @Sounds.Pickup
            PowerupManager.refreshPowerup ply, @Powerup
            @Remove!

            return
        else
            @EmitSound @Sounds.PickupFailed
            ply\ChatPrint "This Powerup cannot be refreshed!"

            return

    @EmitSound @Sounds.Pickup

    PowerupManager.givePowerup ply, @Powerup

    @Remove!

ENT.Use = (activator) =>
    @GivePowerup activator

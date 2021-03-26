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

ENT.Sounds        =
    Pickup: "vo/npc/female01/hacks01.wav"
    PickupFailed: "common/warning.wav"

ENT.Model         = "models/cfc/powerups/powerup.mdl"
ENT.Color         = Color 255, 255, 255

ENT.PickupDistance = 50
ENT.FailedPickups = {}

if CLIENT
   ENT.Draw = =>
       @DrawModel!

   return

ENT.Initialize = =>
    @SetModel @Model
    @SetColor @Color
    @SetMoveType MOVETYPE_NOCLIP
    @PhysicsInit SOLID_NONE
    @Activate!

ENT.GivePowerup = (ply) =>
    return unless IsValid ply

    alertThreshold = 1
    lastFailedPickup = @FailedPickups[ply]

    canGivePowerup = PowerupManager.plyCanGetPowerup ply, @Powerup
    shouldThrottleMessage = lastFailedPickup and (CurTime! - lastFailedPickup) < alertThreshold

    unless canGivePowerup
        return if shouldThrottleMessage

        @EmitSound @Sounds.PickupFailed
        ply\ChatPrint "You can't use this powerup right now! (Maybe it requires PvP mode or maybe you already have it)"

        @FailedPickups[ply] = CurTime!

        return

    if PowerupManager.hasPowerup ply, @Powerup
        existingPowerup = ply.Powerups[@Powerup]

        if existingPowerup.IsRefreshable
            @EmitSound @Sounds.Pickup
            PowerupManager.refreshPowerup ply, @Powerup

            @Remove!
        else
            @EmitSound @Sounds.PickupFailed
            ply\ChatPrint "This Powerup cannot be refreshed!"

        return

    @EmitSound @Sounds.Pickup

    PowerupManager.givePowerup ply, @Powerup

    @Remove!

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

ENT.Model         = "models/powerups/minigun.mdl"

ENT.PickupDistance = 50
ENT.FailedPickups = {}

if CLIENT
   ENT.Draw = =>
       @DrawModel!

   return

ENT.Initialize = =>
    @SetModel @Model
    @SetMoveType MOVETYPE_NOCLIP
    @PhysicsInit SOLID_NONE
    @SetModelScale 15
    @Activate!

    @originalPos = @GetPos!

ENT.Think = =>
    newPos = @originalPos + Vector 0, 0, math.sin(CurTime! * 2) * 10
    @SetPos newPos

    @NextThink CurTime! + 0.1
    true

ENT.GivePowerup = (ply) =>
    alertThreshold = 0.5
    canGive = PowerupManager.plyCanGetPowerup ply, @Powerup
    lastFailedPickup = @FailedPickups[ply]
    shouldThrottleMessage = lastFailedPickup and (CurTime! - lastFailedPickup) < alertThreshold

    if canGive and not shouldThrottleMessage
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

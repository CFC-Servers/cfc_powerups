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

ENT.PickupDistance = 50

if CLIENT
   ENT.Draw = =>
       @DrawModel!

if CLIENT return

ENT.Initialize = =>
    @SetModel @Model
    @SetMoveType MOVETYPE_NOCLIP
    @PhysicsInit SOLID_NONE
    @SetModelScale 15
    @Activate!

    @originalPos = @GetPos!

    @watchTimerName = "CFC_Powerups-PickupWatcher-#{@EntIndex!}"
    timer.Create @watchTimerName, 0.1, 0, -> @CheckForPlayers!

ENT.Think = =>
    newPos = @originalPos + Vector 0, 0, math.sin(CurTime! * 2) * 10
    @SetPos newPos

    @NextThink CurTime! + 0.1
    true

ENT.GivePowerup = (ply) =>
    if not PowerupManager.plyCanGetPowerup ply, @Powerup
        @EmitSound @Sounds.PickupFailed
        ply\ChatPrint "You can't use this powerup right now! (Maybe it requires PvP mode or maybe you already have it)"
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

ENT.CheckForPlayers = =>
    pos = @GetPos!

    for ply in *player.GetAll!
        continue unless IsValid ply

        distance = pos\DistToSqr ply\GetPos!

        -- We square our pickup distance because distance is squared, too
        -- This more efficient than Vector1:Distance(Vector2)
        if distance < @PickupDistance * @PickupDistance
            return @GivePowerup ply

ENT.CallOnRemove = =>
    timer.Remove @watchTimerName

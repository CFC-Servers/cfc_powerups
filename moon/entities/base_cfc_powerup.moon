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

ENT.PowerupName   = "base-cfc-powerup"
ENT.PickupFailed  = "common/warning.wav"
ENT.PickupSound   = "vo/npc/female01/hacks01.wav"
ENT.Model         = "models/props/cs_assault/money.mdl"
ENT.RemoveOnDeath = true
ENT.RequiresPvp   = true

-- Client --

if CLIENT
   ENT.Draw = =>
       @DrawModel!

-- Shared --

if CLIENT return

ENT.Initialize = =>
    @SetModel @Model
    @SetMoveType MOVETYPE_NONE
    @PhysicsInit SOLID_NONE

    @PowerupInfo or= {}
    @PowerupInfo.Name = @PowerupName
    @PowerupInfo.RemoveOnDeath = @RemoveOnDeath
    @PowerupInfo.RequiresPvp = @RequiresPvp

-- This will be replaced in each powerup
ENT.PowerupEffect = (ply) =>
    ply\ChatPrint "Powerup Get!"
    ply\Kill!

ENT.GivePowerup = (ply) =>
    if @RequiresPvp and ply\GetNWBool("CFC_PvP_Mode", false) == false
        @EmitSound @PickupFailed
        ply\ChatPrint "This Powerup requires PvP mode!"
        return

    if ply\HasPowerup @PowerupName
        return @PowerupRefresh ply

    @EmitSound @PickupSound
    @PowerupEffect ply
    ply\AddPowerup @PowerupInfo

    @Remove!

ENT.Use = (activator) =>
    @GivePowerup activator

ENT.RefreshPowerup = (ply) =>
    -- By Default, err saying it can't be picked up
    @EmitSound @PickupFailed
    ply\ChatPrint "You can't pick up this powerup again!"

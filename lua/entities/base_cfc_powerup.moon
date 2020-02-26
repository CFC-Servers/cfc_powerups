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

ENT.PickupSound   = "vo/npc/female01/hacks01.wav"
ENT.Model         = "models/props/cs_assault/money.mdl"
ENT.RemoveOnDeath = true

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

-- This will be replaced in each powerup
ENT.PowerupEffect = (ply) =>
    ply\ChatPrint "Powerup Get!"
    ply\Kill!

ENT.GivePowerup = (ply) =>
    ply\EmitSound @PickupSound
    ply.RemovePowerupOnDeath = @RemoveOnDeath
    @PowerupEffect ply

ENT.Use = (activator) =>
    @GivePowerup activator
    @Remove!

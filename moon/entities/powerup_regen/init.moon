AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

ENT.Powerup = PowerupManager.getMetaPowerup "regen-powerup"

DEFINE_BASECLASS "base_cfc_powerup"

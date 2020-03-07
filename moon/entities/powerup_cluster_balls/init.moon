AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

ENT.Base = "base_cfc_powerup"
ENT.Powerup = PowerupManager.getMetaPowerup "cluster-combine-balls"

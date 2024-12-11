require "moonloader"

AddCSLuaFile!
require "logger"

export CFCPowerups = {
    Logger: Logger "CFC Powerups"
}

if SERVER
    include "powerups/loaders/sv_powerups_init.lua"
    AddCSLuaFile "powerups/loaders/cfc_powerups_killicons.lua"
    AddCSLuaFile "powerups/loaders/cl_powerups_init.lua"
else
    include "powerups/loaders/cfc_powerups_killicons.lua"
    include "powerups/loaders/cl_powerups_init.lua"

CFCPowerups.Logger\info "Loaded!"

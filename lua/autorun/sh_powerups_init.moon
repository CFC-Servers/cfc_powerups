require "moonloader"

AddCSLuaFile!
require "logger"

export CFCPowerups = {
    Logger: Logger "CFC Powerups"
}

if SERVER
    include "powerups/loaders/sv_powerups_init.lua"
else
    include "powerups/loaders/cfc_powerups_killicions.lua"
    include "powerups/loaders/cl_powerups_init.lua"

CFCPvp.Logger\info "Loaded!"

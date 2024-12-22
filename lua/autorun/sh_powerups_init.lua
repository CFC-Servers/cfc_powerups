if SERVER then
    require( "moonloader" )
end

require( "logger" )

CFCPowerups = {
    Logger = Logger( "CFC Powerups" ),
    SharedHandlers = {}, -- For powerup handler classes that carry duplicate code between server and client relams
}

if SERVER then
    include( "powerups/loaders/sv_powerups_init.lua" )
    AddCSLuaFile( "powerups/loaders/cfc_powerups_killicons.lua" )
    AddCSLuaFile( "powerups/loaders/cl_powerups_init.lua" )
else
    include( "powerups/loaders/cfc_powerups_killicons.lua" )
    include( "powerups/loaders/cl_powerups_init.lua" )
end

CFCPowerups.Logger:info( "Loaded!" )

if SERVER then
    require( "moonloader" )
    resource.AddWorkshop( "3114943116" )
end

require( "logger" )

CFCPowerups = {
    Logger = Logger( "CFC Powerups" )
}

if SERVER then
    include( "powerups/loaders/sv_powerups_init.lua" )
else
    include( "powerups/loaders/cfc_powerups_killicions.lua" )
    include( "powerups/loaders/cl_powerups_init.lua" )
end

CFCPowerups.Logger:info( "Loaded!" )

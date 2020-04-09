configs = include "powerups/config/sv_config.lua"

CFCPowerups.Config =
    get: (key) ->
        key = "cfc_powerups_#{key}"

        convar = GetConVar key
        default = configs[key].default
        convarType = type default

        switch convarType
            when "number"
                convar\GetFloat!
            when "string"
                convar\GetString!
            when "boolean"
                convar\GetBool!
            else
                ErrorNoHalt "Can't get the got dang type of #{key}'s default value (#{default})"
                convar\GetString!

    loadConfig: =>
        for key, options in pairs configs
            {:default, :helpText, :min} = options

            flags = FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_PROTECTED
            CreateConVar key, default, flags, helpText, min

CFCPowerups.Config.loadConfig!

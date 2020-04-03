configs = include "powerups/config/sv_config.lua"

CFCPowerups.Config =
    get: (key) ->
        convar = GetConVar key
        default = convar\GetDefault!
        convarType = type default

        switch convarType
            when "number"
                convar\GetInt!
            when "float"
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
            value = GetConVar(key) or default

            CreateConVar key, value, nil, helpText

CFCPowerups.Config.loadConfig!

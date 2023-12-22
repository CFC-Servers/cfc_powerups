local configs = include("powerups/config/sv_config.lua")
CFCPowerups.Config = {
  get = function(key)
    key = "cfc_powerups_" .. tostring(key)
    local convar = GetConVar(key)
    local default = configs[key].default
    local convarType = type(default)
    local _exp_0 = convarType
    if "number" == _exp_0 then
      return convar:GetFloat()
    elseif "string" == _exp_0 then
      return convar:GetString()
    elseif "boolean" == _exp_0 then
      return convar:GetBool()
    else
      ErrorNoHalt("Can't get the got dang type of " .. tostring(key) .. "'s default value (" .. tostring(default) .. ")")
      return convar:GetString()
    end
  end,
  loadConfig = function(self)
    for key, options in pairs(configs) do
      local default, helpText, min
      default, helpText, min = options.default, options.helpText, options.min
      local flags = FCVAR_REPLICATED + FCVAR_ARCHIVE + FCVAR_PROTECTED
      CreateConVar(key, default, flags, helpText, min)
    end
  end
}
return CFCPowerups.Config.loadConfig()

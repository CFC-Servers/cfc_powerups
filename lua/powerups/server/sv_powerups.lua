local playerInit
playerInit = function(ply)
  ply.Powerups = ply.Powerups or { }
end
hook.Remove("PlayerInitialSpawn", "CFC_Powerups_PlayerInit")
hook.Add("PlayerInitialSpawn", "CFC_Powerups_PlayerInit", playerInit)
local playerLeave
playerLeave = function(ply)
  local _accum_0 = { }
  local _len_0 = 1
  local _list_0
  do
    local _base_0 = ply
    local _fn_0 = _base_0.Powerups
    _list_0 = function(...)
      return _fn_0(_base_0, ...)
    end
  end
  for _index_0 = 1, #_list_0 do
    local powerup = _list_0[_index_0]
    _accum_0[_len_0] = powerup.RemovePowerup()
    _len_0 = _len_0 + 1
  end
  return _accum_0
end
hook.Remove("PlayerDisconnected", "CFC_Powerups_Cleanup")
hook.Add("PlayerDisconnected", "CFC_Powerups_Cleanup", playerLeave)
local playerExitPvp
playerExitPvp = function(ply)
  local _accum_0 = { }
  local _len_0 = 1
  local _list_0
  do
    local _base_0 = ply
    local _fn_0 = _base_0.Powerups
    _list_0 = function(...)
      return _fn_0(_base_0, ...)
    end
  end
  for _index_0 = 1, #_list_0 do
    local powerup = _list_0[_index_0]
    if powerup.RequiresPvp then
      _accum_0[_len_0] = powerup.RemovePowerup()
      _len_0 = _len_0 + 1
    end
  end
  return _accum_0
end
hook.Remove("CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp")
hook.Add("CFC_PlayerExitedPvp", "CFC_Powerups_PlayerExitPvp", playerExitPvp)
local playerDied
playerDied = function(ply)
  local _accum_0 = { }
  local _len_0 = 1
  local _list_0
  do
    local _base_0 = ply
    local _fn_0 = _base_0.Powerups
    _list_0 = function(...)
      return _fn_0(_base_0, ...)
    end
  end
  for _index_0 = 1, #_list_0 do
    local powerup = _list_0[_index_0]
    if powerup.RemoveOnDeath then
      _accum_0[_len_0] = powerup.RemovePowerup()
      _len_0 = _len_0 + 1
    end
  end
  return _accum_0
end
hook.Remove("PostPlayerDeath", "CFC_Powerups_PlayerDeath")
return hook.Add("PostPlayerDeath", "CFC_Powerups_PlayerDeath", playerDied)

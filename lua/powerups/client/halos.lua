local drawHalos
drawHalos = function()
  do
    return nil
  end
  local me = LocalPlayer()
  if not (me:IsInPvp()) then
    return 
  end
  local activeWeapon = me:GetActiveWeapon()
  local hasWeapon = IsValid(activeWeapon)
  local hasCameraOut = hasWeapon and activeWeapon:GetClass() == "gmod_camera"
  if hasCameraOut then
    return 
  end
  local playersWithPowerups
  do
    local _accum_0 = { }
    local _len_0 = 1
    local _list_0 = player.GetAll()
    for _index_0 = 1, #_list_0 do
      local ply = _list_0[_index_0]
      if ply:GetNWBool("HasPowerup", false) then
        _accum_0[_len_0] = ply
        _len_0 = _len_0 + 1
      end
    end
    playersWithPowerups = _accum_0
  end
  return halo.Add(playersWithPowerups, Color(255, 0, 0), 2, 1, 1, false, true)
end
hook.Add("PreDrawHalos", "DrawPowerupHalos", drawHalos)
local stopPvpHalos
stopPvpHalos = function(ply)
  if ply:GetNWBool("HasPowerup", false) then
    return false
  end
end
return hook.Add("CFC_PvP_SetPlayerHalo", "PreventPvPHalosForPowerups", stopPvpHalos)

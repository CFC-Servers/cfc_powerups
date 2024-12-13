local ShotgunPowerupHandler
ShotgunPowerupHandler = CFCPowerups.SharedHandlers.ShotgunPowerupHandler
local shotguns = { }
local removeShotgun
removeShotgun = function(ownerSteamID64)
  local shotgun = shotguns[ownerSteamID64]
  if not (shotgun) then
    return 
  end
  shotgun:Remove()
  shotguns[ownerSteamID64] = nil
end
net.Receive("CFC_Powerups-Shotgun-Start", function()
  local ownerSteamID64 = net.ReadString()
  local singleBulletsMin = net.ReadUInt(7)
  local singleBulletsMax = net.ReadUInt(7)
  local singleDamageMult = net.ReadFloat()
  local singleSpreadMult = net.ReadFloat()
  local singleSpreadAdd = net.ReadFloat()
  local multiBulletsMult = net.ReadFloat()
  local multiDamageMult = net.ReadFloat()
  removeShotgun(ownerSteamID64)
  local owner = player.GetBySteamID64(ownerSteamID64)
  if not (IsValid(owner)) then
    return 
  end
  shotguns[ownerSteamID64] = ShotgunPowerupHandler(owner, singleBulletsMin, singleBulletsMax, singleDamageMult, singleSpreadMult, singleSpreadAdd, multiBulletsMult, multiDamageMult)
end)
return net.Receive("CFC_Powerups-Shotgun-Stop", function()
  local ownerSteamID64 = net.ReadString()
  return removeShotgun(ownerSteamID64)
end)

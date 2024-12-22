AddCSLuaFile()
DEFINE_BASECLASS("base_point")
ENT.Type = "point"
ENT.Spawnable = false
ENT.Initialize = function(self) end
ENT.UpdateTransmitState = function()
  return TRANSMIT_NEVER
end

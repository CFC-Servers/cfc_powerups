AddCSLuaFile!

DEFINE_BASECLASS "base_point"

ENT.Type          = "point"
ENT.Spawnable     = false


ENT.Initialize = =>
    -- Do nothing

ENT.UpdateTransmitState = ->
    TRANSMIT_NEVER

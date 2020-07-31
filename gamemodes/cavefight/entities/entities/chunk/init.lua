AddCSLuaFile('cl_init.lua')

include('shared.lua')

function ENT:UpdateTransmitState()
  return TRANSMIT_ALWAYS
end

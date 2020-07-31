AddCSLuaFile()

ENT.Base = 'base_anim'
ENT.Type = 'anim'

function ENT:SetupDataTables()
  self:NetworkVar('Entity', 0, 'LastHooker')
end
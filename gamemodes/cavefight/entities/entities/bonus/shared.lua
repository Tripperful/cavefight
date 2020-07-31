AddCSLuaFile()

ENT.Base = 'base_anim'
ENT.Type = 'anim'

ENT.Colors = {
  [BONUS_HEALTH] = Color(255, 100, 150),
  [BONUS_INVIS] = Color(255, 255, 255),
  [BONUS_DAMAGE] = Color(255, 0, 0),
  [BONUS_SHIELD] = Color(255, 255, 0),
}

function ENT:SetupDataTables()
  self:NetworkVar('Int', 0, 'Type')
end

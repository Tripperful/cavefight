AddCSLuaFile('cl_init.lua')

include('shared.lua')

function ENT:Initialize()
  self:SetModel('models/xqm/rails/gumball_1.mdl')
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_NONE)
  self:SetTrigger(true)
  self:SetMaterial('models/debug/debugwhite')
  self:SetColor(self.Colors[self:GetType()])
  self:EnableCustomCollisions(true)
end

function ENT:TestCollision(start, delta, isbox, extents)
  return false
end

ENT.Duration = {
  [BONUS_HEALTH] = 10,
  [BONUS_INVIS] = 20,
  [BONUS_DAMAGE] = 30,
  [BONUS_SHIELD] = 10,
}

function ENT:StartTouch(ship)
  if ship:GetClass() == 'ship' and ship:Health() > 0 then
    local bonusType = self:GetType()
    ship:ApplyBonus(bonusType, CurTime() + self.Duration[bonusType])
    self:Remove()
    timer.Simple(10, function()
      spawnBonus(bonusType)
    end)
  end
end
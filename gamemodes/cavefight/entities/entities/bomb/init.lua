AddCSLuaFile('cl_init.lua')

include('shared.lua')

function ENT:Initialize()
  self:SetModel('models/dynamite/dynamite.mdl')
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetTrigger(true)
  local p = self:GetPhysicsObject()
  p:SetDamping(0, 0)
  p:SetMass(10)
  p:Wake()
end

function ENT:StartTouch(ent)
  if self:IsConstrained() then return end
  local lastHooker = self:GetLastHooker()
  if IsValid(lastHooker) then
    util.BlastDamage(lastHooker, lastHooker, self:GetPos(), 300, 1500)
    local boom = EffectData()
    boom:SetOrigin(self:GetPos())
    util.Effect('Explosion', boom, true, true)
    self:Remove()
    timer.Simple(3, function()
      spawnBomb()
    end)
  end
end
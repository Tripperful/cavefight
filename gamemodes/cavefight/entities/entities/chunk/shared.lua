AddCSLuaFile()

ENT.Base = 'base_anim'
ENT.Type = 'anim'

function ENT:SetupDataTables()
  self:NetworkVar('Int', 0, 'Seed')
end

function ENT:InitPhysics()
  if self.geometry then
    self:PhysicsFromMesh(self.geometry)
    self:EnableCustomCollisions(true)
    self:SetSolid(SOLID_VPHYSICS)
    local p = self:GetPhysicsObject()
    if IsValid(p) then
      p:SetMaterial('rock')
      p:SetMass(10000)
      p:SetContents(CONTENTS_SOLID)
      p:EnableMotion(false)
      p:Sleep()
    end
  end
end

function ENT:Initialize()
  self:SetModel('models/hunter/blocks/cube025x025x025.mdl')
  self:DrawShadow(false)
  local caveSeed = self:GetSeed()
  local p = self:GetPos() / caveChunkSize
  local heights = caveNoiseChunk(caveSeed, p.x, p.y)
  local chunk = caveChunkTriangles(heights, p.x, p.y)
  self.chunk = chunk
  if SERVER and #chunk == 0 then
    return
  end
  self.geometry = chunk
  if CLIENT then
    self:InitMesh()
  end
  self:InitPhysics()
end

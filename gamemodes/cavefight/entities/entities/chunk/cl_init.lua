include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

local mat = CreateMaterial('terrain', 'VertexLitGeneric', {
  ['$basetexture'] = 'nature/rockwall011d',
})

local mins, maxs = Vector(-caveChunkSize / 2, -caveChunkSize / 2, -caveMaxH), Vector(caveChunkSize / 2, caveChunkSize / 2, caveMaxH + caveMaxCeil)

function ENT:InitMesh()
    self.mesh = Mesh(mat)
    self.mesh:BuildFromTriangles(self.chunk)
    self:SetRenderBounds(mins, maxs)
    self:SetNextClientThink(CurTime() + 1)
end

function ENT:Draw()
  render.SetBlend(0)
  self:DrawModel()
  render.SetBlend(1)
  if IsValid(self.mesh) then
    cam.PushModelMatrix(self:GetWorldTransformMatrix())
    render.SetMaterial(mat)
    self.mesh:Draw()
    cam.PopModelMatrix()
  end
end

function ENT:Think()
  if not IsValid(self.mesh) then
    self:InitMesh()
  end
end

function ENT:OnRemove()
  if IsValid(self.mesh) then
    self.mesh:Destroy()
  end
end

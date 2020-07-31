include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
    self.lastSpark = 0
    self:SetRenderBounds(vector_origin, vector_origin, Vector(100, 100, 100))
end

function ENT:Draw()
  self:DrawModel()
  local lastHooker = self:GetLastHooker()
  if IsValid(lastHooker) then
    local dlight = DynamicLight(self:EntIndex(), true)
    if (dlight) then
      dlight.pos = self:LocalToWorld(Vector(0, 0, 20))
      dlight.r = 255
      dlight.g = 255
      dlight.b = 0
      dlight.brightness = 1
      dlight.Decay = 1000
      dlight.Size = 300
      dlight.DieTime = CurTime() + FrameTime()
    end
    local t = CurTime()
    if t - self.lastSpark > 0.2 then
      self.lastSpark = t
      local spark = EffectData()
      spark:SetOrigin(self:LocalToWorld(Vector(0, 0, 20)))
      util.Effect('cball_explode', spark, true, true)
    end
  end
end
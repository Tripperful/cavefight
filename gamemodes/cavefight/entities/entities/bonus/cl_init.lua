include('shared.lua')

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.Icons = {
  [BONUS_HEALTH] = Material('icon16/heart.png'),
  [BONUS_INVIS] = Material('icon16/eye.png'),
  [BONUS_DAMAGE] = Material('icon16/fire.png'),
  [BONUS_SHIELD] = Material('icon16/shield.png'),
}

function ENT:Initialize()
  self:SetRenderBounds(vector_origin, vector_origin, Vector(500, 500, 500))
end

local bonusBgSprite = Material('particle/particle_glow_05')

function ENT:Draw()
  local bonusType = self:GetType()
  local color = self.Colors[bonusType]
  render.SetMaterial(bonusBgSprite)
  render.DrawSprite(self:GetPos() + EyeVector(), 100, 100, color)
  render.SetMaterial(self.Icons[bonusType])
  render.DrawSprite(self:GetPos(), 20, 20, color_white)
  render.SuppressEngineLighting(false)
  local dlight = DynamicLight(self:EntIndex(), true)
  if (dlight) then
    dlight.pos = self:GetPos()
    dlight.r = color.r
    dlight.g = color.g
    dlight.b = color.b
    dlight.brightness = 3
    dlight.Decay = 1000
    dlight.Size = 500
    dlight.DieTime = CurTime() + FrameTime()
  end
end

function ENT:OnRemove()
    local eff = EffectData()
    eff:SetEntity(self)
    eff:SetOrigin(self:GetPos())
    util.Effect('cball_explode', eff, true, true)
    playSound(SOUND_BONUS, self:GetPos())
end
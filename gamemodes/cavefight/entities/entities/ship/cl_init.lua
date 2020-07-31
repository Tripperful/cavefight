include('shared.lua')

local particleMat = Material('effects/rollerglow')
local shieldMat = Material('effects/com_shield004a')

function ENT:Draw()
  local driver = self:GetDriver()
  local thirdperson = driver != LocalPlayer() or driver:GetThirdperson()
  if not self.invis and thirdperson then self:DrawModel() end
  if self:Health() > 0 then
    if self.shield then
      render.SetMaterial(shieldMat)
      render.DrawSphere(self:GetPos(), 15, 30, 30, color_white)
    end
    local t = CurTime()
    local vel = self:GetVelocity():Length()
    local mul = math.Clamp(vel / 400, 0, 1)
    local dlight = DynamicLight(self:EntIndex(), true)
    if (dlight) then
      dlight.pos = self:LocalToWorld(Vector(-20, 0, 0))
      dlight.r = 100
      dlight.g = 200
      dlight.b = 255
      dlight.brightness = 2 * mul
      dlight.Decay = 1000
      dlight.Size = 3000 * mul
      dlight.DieTime = t + FrameTime()
    end
    if not self.invis and t - (self.lastPartile or 0) > 0.1 then
      local particle = self.emitter:Add(particleMat, self:LocalToWorld(self.EngineMuzzlePos))
      particle:SetDieTime(mul)
      particle:SetStartAlpha(255 * mul)
      particle:SetEndAlpha(0)
      particle:SetStartSize(5 * mul)
      particle:SetEndSize(0)
      particle:SetGravity(Vector(0, 0, 100))
      particle:SetVelocity(-self:GetForward() * 5 + VectorRand() * 30)
    end
    if self.idleSound then
      self.idleSound:ChangePitch(50 + math.Clamp(vel * 0.1, 0, 100), 0)
    end
  end
end

function ENT:OnRemove()
  if self.idleSound then
      self.idleSound:Stop()
    end
end

net.Receive('cave.applyBonus', function(len)
  local ship = net.ReadEntity()
  local bonusType = net.ReadUInt(8)
  local endTime = net.ReadFloat()
  if IsValid(ship) then
    ship:ApplyBonus(bonusType, endTime)
  end
end)

net.Receive('cave.removeBonus', function(len)
  local ship = net.ReadEntity()
  local bonusType = net.ReadUInt(8)
  if IsValid(ship) then
    ship:RemoveBonus(bonusType)
  end
end)

net.Receive('cave.kill', function(len)
  local attacker, driver = net.ReadEntity(), net.ReadEntity()
  notification.AddLegacy(attacker == driver and
    attacker:Nick() .. ' suicided' or
    attacker:Nick() .. ' killed ' .. driver:Nick()
  , NOTIFY_GENERIC, 3)
end)

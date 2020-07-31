AddCSLuaFile()

ENT.Base = 'base_ai'
ENT.Type = 'anim'
ENT.EngineMuzzlePos = Vector(-10, 1.5, -3.5)

if SERVER then
  util.AddNetworkString('setShipDriver')
end

function ENT:SetupDataTables()
  self:NetworkVar('Entity', 0, 'Driver')
end

local shipSound = Sound('npc/turret_wall/turret_loop1.wav')

function ENT:Initialize()
  self:SetModel('models/shield_scanner.mdl')
  self:SetSequence(self:LookupSequence('OpenUp'))
  if SERVER then
    self:SetLagCompensated(true)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    local p = self:GetPhysicsObject()
    p:SetMaterial('metal')
    p:SetMass(100)
    p:Wake()
    self:Reactivate()
  else
    self.idleSound = CreateSound(self, shipSound)
    self.idleSound:PlayEx(0.2, 100)
    self.emitter = ParticleEmitter(vector_origin, false)
  end
end

local bonusNames = {
  [BONUS_HEALTH] = 'Health regeneration',
  [BONUS_INVIS] = 'Invisibility',
  [BONUS_DAMAGE] = 'Increased damage',
  [BONUS_SHIELD] = 'Shield',
}

function ENT:ApplyBonus(bonusType, endTime)
  local bonusId = self:EntIndex() .. '.' .. bonusType
  local startTime = CurTime()
  local lastApplied = startTime
  local driver = self:GetDriver()
  if SERVER then
    net.Start('cave.applyBonus')
      net.WriteEntity(self)
      net.WriteUInt(bonusType, 8)
      net.WriteFloat(endTime)
    net.Broadcast()
  end
  self:OnBonusStart(bonusType, endTime)
  hook.Add('Think', bonusId, function()
    if IsValid(self) then
      local t = CurTime()
      if t < endTime then
        self:OnBonusThink(bonusType, startTime, endTime, t - lastApplied)
        lastApplied = t
        if CLIENT and driver == LocalPlayer() then
          local progress = (endTime - CurTime()) / (endTime - startTime)
          notification.AddProgress(bonusId, bonusNames[bonusType], progress)
        end
      else
        self:RemoveBonus(bonusType)
      end
    else
      hook.Remove('Think', bonusId)
      if CLIENT and driver == LocalPlayer() then
        notification.Kill(bonusId)
      end
    end
  end)
end

function ENT:RemoveBonus(bonusType)
  local bonusId = self:EntIndex() .. '.' .. bonusType
  local driver = self:GetDriver()
  if SERVER then
    net.Start('cave.removeBonus')
      net.WriteEntity(self)
      net.WriteUInt(bonusType, 8)
    net.Broadcast()
  end
  self:OnBonusEnd(bonusType)
  hook.Remove('Think', bonusId)
  if CLIENT and driver == LocalPlayer() then
    notification.Kill(bonusId)
  end
end

function ENT:RemoveAllBonuses()
  for bonusType = 1, BONUS_COUNT - 1 do
    self:RemoveBonus(bonusType)
  end
end

function ENT:OnBonusStart(bonusType, endTime)
  if bonusType == BONUS_HEALTH and CLIENT then
    self.lastHeal = CurTime()
  elseif bonusType == BONUS_INVIS and CLIENT then
    self.invis = true
  elseif bonusType == BONUS_DAMAGE then
    if SERVER then
      self.dmg = true
    else
      self.lastDmg = CurTime()
    end
  elseif bonusType == BONUS_SHIELD then
    self.shield = true
  end
end

local healMat = Material('icon16/heart.png')
local dmgMat = Material('icon16/fire.png')

function ENT:OnBonusThink(bonusType, startTime, endTime, dt)
  local t = CurTime()
  if bonusType == BONUS_HEALTH then
    if SERVER then
      self:SetHealth(math.min(self:Health() + dt * 150, self:GetMaxHealth()))
    else
      if t - self.lastHeal > 0.5 then
        local particle = self.emitter:Add(healMat, self:GetPos() + Vector(0, 0, 5))
        particle:SetDieTime(1)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(0)
        particle:SetEndSize(10)
        particle:SetGravity(Vector(0, 0, 100))
        playSound(SOUND_HEAL, self:GetPos())
        self.lastHeal = t
      end
    end
  elseif bonusType == BONUS_DAMAGE and CLIENT then
    if t - self.lastDmg > 1 then
        local particle = self.emitter:Add(dmgMat, self:GetPos() + Vector(0, 0, 5))
        particle:SetDieTime(0.5)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(0)
        particle:SetEndSize(20)
        particle:SetGravity(Vector(0, 0, 100))
        playSound(SOUND_DMG, self:GetPos())
        self.lastDmg = t
      end
  end
end

function ENT:OnBonusEnd(bonusType)
  if bonusType == BONUS_INVIS and CLIENT then
    self.invis = false
  elseif bonusType == BONUS_DAMAGE and SERVER then
    self.dmg = false
  elseif bonusType == BONUS_SHIELD then
    self.shield = false
  end
end
include('shared.lua')

function GM:CalcView(ply, pos, ang, fov)
  local p, a = caveCalcView(ply, pos, ang)
  return {
    origin = p,
    angles = a,
    fov = 90,
    drawViewer = false
  }
end

function GM:SetupWorldFog()

  render.FogMode( MATERIAL_FOG_LINEAR )
  render.FogStart( 500 )
  render.FogEnd( 2000 )
  render.FogMaxDensity( 0.5 )
  render.FogColor( 80, 80, 100 )

  return true
end

local hiddenHud = {
  CHudAmmo = true,
  CHudBattery = true,
  CHudDamageIndicator = true,
  CHudCrosshair = true,
  CHudGeiger = true,
  CHudHealth = true,
  CHudPoisonDamageIndicator = true,
  CHudSecondaryAmmo = true,
  CHudSquadStatus = true,
  CHudTrain = true,
  CHudVehicle = true,
  CHudWeaponSelection = true,
  CHudZoom = true,
  CHUDQuickInfo = true,
  CHudSuitPower = true,
}

function GM:HUDShouldDraw(el)
  if hiddenHud[el] then return false end
  return true
end

local tips = {
  '[LMB] to shoot',
  '[RMB] to use hook',
  '[F3] to toggle firstperson/thirdperson',
  '[W/A/S/D] to fly',
  '[SHIFT] to accelerate',
  '[CTRL] to lower altitude',
  '[SPACE] to gain altitude',
}

function GM:OnContextMenuOpen()
  for _, tip in pairs(tips) do
    notification.AddProgress(tip, tip, 1)
  end
end

function GM:OnContextMenuClose()
  for _, tip in pairs(tips) do
    notification.Kill(tip)
  end
end

local hudColor = Color(0, 200, 255, 255)
local bgTint = Material('vgui/zoom')
local gradrt = Material('gui/gradient')

function GM:HUDPaintBackground()
  surface.SetDrawColor(255, 255, 255, 255)
  surface.SetMaterial(bgTint)
  local w, h = ScrW(), ScrH()
  surface.DrawTexturedRect(0, 0, w, h)
end

surface.CreateFont('CaveScore', {
  font = 'Roboto',
  size = 64
})

surface.CreateFont('CaveTimer', {
  font = 'Roboto',
  size = 24
})

function GM:HUDPaint()
  local w, h = ScrW(), ScrH()
  local driver = LocalPlayer()
  local ship = driver:GetShip()
  if not IsValid(ship) then return end
  if IsValid(ship) then
    local eyePos, eyeAng = caveCalcView(driver, driver:EyePos(), driver:EyeAngles())
    local tr = util.TraceLine({
      start = eyePos,
      endpos = eyePos + eyeAng:Forward() * 100000,
      filter = ship
    })
    tr = util.TraceLine({
      start = ship:GetPos(),
      endpos = tr.HitPos,
      filter = ship
    })
    local pos = tr.HitPos:ToScreen()
    local m = Matrix()
    m:Translate(Vector(pos.x, pos.y, 0))
    surface.SetMaterial(gradrt)
    surface.SetDrawColor(hudColor)
    m:Rotate(Angle(0, ship:GetAngles().r, 0))
    cam.PushModelMatrix(m)
    surface.DrawTexturedRect(8, -1, 100, 2)
    cam.PopModelMatrix()
    m:Rotate(Angle(0, 180, 0))
    cam.PushModelMatrix(m)
    surface.DrawTexturedRect(8, -1, 100, 2)
    cam.PopModelMatrix()
  end
  local hp = ship:Health() / ship:GetMaxHealth()
  surface.SetDrawColor(hudColor)
  surface.DrawRect(w / 3, h - 64, w / 3 * hp, 10)
  surface.DrawRect(w / 3 - 15, h - 74, 10, 30)
  surface.DrawRect(w / 3 * 2 + 5, h - 74, 10, 30)
  draw.SimpleText('Health', 'Trebuchet24', w / 2, h - 64, hudColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
  draw.SimpleText(driver:Frags() .. '/' .. driver:Deaths(), 'CaveScore', ScrW() / 2, 0, hudColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
  local tl = string.FormattedTime(timeleft())
  draw.SimpleText(string.format('%02i:%02i', tl.m, tl.s), 'CaveTimer',  ScrW() / 2, 72, hudColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
end

local ending = false

function GM:PostDrawHUD()
  local tl = timeleft()
  if tl < 0 then
    net.Start('cave.requestTimeleft')
    net.SendToServer()
    return
  end
  if tl < 8 then
    if not ending then
      ending = true
      self:ScoreboardShow()
      notification.AddLegacy('End of round!', NOTIFY_HINT, 5)
    end
    local w, h = ScrW(), ScrH()
    surface.SetAlphaMultiplier(math.Clamp(4 - tl / 2, 0, 1))
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, w, h)
    surface.SetAlphaMultiplier(1)
  elseif ending then
    ending = false
    self:ScoreboardHide()
  end
end

function GM:PlayerBindPress(ply, bind)
  if bind == 'gm_showspare1' then
    net.Start('cave.thirdperson')
    net.SendToServer()
  end
end

function GM:PreDrawHalos()
  halo.Add(ents.FindByClass('bomb'), Color(255, 255, 0))
end

function playSound(index, pos)
  sound.Play(sounds[index], pos, 75, 100, 1)
end

net.Receive('cave.sound', function(len)
  playSound(net.ReadUInt(16), net.ReadVector())
end)

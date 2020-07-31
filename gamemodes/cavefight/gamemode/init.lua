AddCSLuaFile('cl_init.lua')

include('shared.lua')

caveSeed = 0

local function getRadialPos(minR, maxR)
  local r, a = minR + math.random() * maxR - minR, math.random() * math.pi * 2
  local x, y = math.cos(a) * r, math.sin(a) * r
  return Vector(x, y, caveHeightAtPoint(caveSeed, x, y) + caveMaxCeil / 2)
end

local minRespRadius, maxRespRadius = caveMapSize * 0.1, caveMapSize * 0.4

function spawnBonus(bonusType)
  local bonus = ents.Create('bonus')
  bonus:SetType(bonusType)
  bonus:SetPos(getRadialPos(minRespRadius, maxRespRadius))
  bonus:Spawn()
end

function spawnBomb()
  local bomb = ents.Create('bomb')
  bomb:SetPos(getRadialPos(minRespRadius, maxRespRadius))
  bomb:Spawn()
end

function spawnShip(driver)
  local ship = ents.Create('ship')
  ship:SetDriver(driver)
  driver:SetShip(ship)
  driver:SetThirdperson(true)
  ship:Spawn()
end

local function spawnChunks()
  local from, to = -caveMapSize / 2, caveMapSize / 2
  for y = from, to, caveChunkSize do
    for x = from, to, caveChunkSize do
      local chunk = ents.Create('chunk')
      chunk:SetSeed(caveSeed)
      chunk:SetPos(Vector(x, y, 1))
      chunk:Spawn()
      chunk:Activate()
    end
  end
end

local bonusCount = {
  [BONUS_HEALTH] = 1,
  [BONUS_INVIS] = 1,
  [BONUS_DAMAGE] = 1,
  [BONUS_SHIELD] = 1,
}

local bombCount = 5

local toRemove = {
  chunk = true,
  ship = true,
  bonus = true,
  bomb = true,
}

local timelimit = 300 // 5 min

function generateMap()
  caveSeed =  math.random(0, 1000)
  for _, ent in pairs(ents.GetAll()) do
    if toRemove[ent:GetClass()] then
      ent:Remove()
    end
  end
  spawnChunks()
  for bonusType, count in pairs(bonusCount) do
    for i = 1, count do
      spawnBonus(bonusType)
    end
  end
  for i = 1, bombCount do
    spawnBomb()
  end
  for _, ply in pairs(player.GetAll()) do
    spawnShip(ply)
    ply:SetFrags(0)
    ply:SetDeaths(0)
  end
  setNextWorldGen(CurTime() + timelimit)
end

function GM:InitPostEntity()
  generateMap()
end

function GM:Think()
  if timeleft() <= 0 then
    generateMap()
  end
end

function GM:PlayerInitialSpawn(ply)
  player_manager.SetPlayerClass(ply, 'player_shipdriver')
  spawnShip(ply)
end

function GM:PlayerSpawn(ply)
  ply:SetPos(Vector(0, 0, 5000))
  ply:SetSolid(SOLID_NONE)
  ply:SetMoveType(MOVETYPE_NONE)
  ply:SetNoDraw(true)
end

function GM:PlayerDisconnected(ply)
  local ship = ply:GetShip()
  if IsValid(ship) then
    ship:Die()
  end
end

function GM:CanPlayerSuicide(ply)
  return false
end

util.AddNetworkString('cave.sound')
function playSound(index, pos)
  net.Start('cave.sound')
  net.WriteUInt(index, 16)
  net.WriteVector(pos)
  net.Broadcast()
end

util.AddNetworkString('cave.thirdperson')
net.Receive('cave.thirdperson', function(len, ply)
  ply:SetThirdperson(not ply:GetThirdperson())
end)

util.AddNetworkString('cave.requestTimeleft')
net.Receive('cave.requestTimeleft', function(len, ply)
  net.Start('cave.setNextWorldGen')
    net.WriteFloat(nextWorldGenTimestamp)
  net.Send(ply)
end)

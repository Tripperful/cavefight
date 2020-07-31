AddCSLuaFile()

BONUS_HEALTH = 1
BONUS_INVIS = 2
BONUS_DAMAGE = 3
BONUS_SHIELD = 4
BONUS_COUNT = 5

caveChunkSize = 512
caveNoiseScale = 1
caveMaxH = 600
caveResX, caveResY = 8, 8
caveMapSize = 4096
caveMaxCeil = 300
caveTextureTile = 0.5

local camRadius = Vector(3, 3, 3)
local camOffset = Vector(0, 0, 10)

sounds = {}
local function soundEnum(name, snd)
  _G[name] = table.insert(sounds, Sound(snd))
end

soundEnum('SOUND_SHOOT', 'weapons/alyx_gun/alyx_gun_fire5.wav')
soundEnum('SOUND_ZAP', 'ambient/energy/zap1.wav')
soundEnum('SOUND_BONUS', 'buttons/button1.wav')
soundEnum('SOUND_HEAL', 'physics/plaster/ceiling_tile_impact_soft3.wav')
soundEnum('SOUND_DMG', 'physics/plaster/ceiling_tile_impact_soft1.wav')
soundEnum('SOUND_RESPAWN', 'buttons/combine_button1.wav')

local camNoClip = {
  ['ship'] = true,
  ['bonus'] = true,
}

function caveCalcView(ply, pos, ang)
  local ship = ply:GetShip()
  if IsValid(ship) then
    ang = LerpVector(0.2, ang:Forward(), ship:GetAngles():Forward()):Angle()
    local start = ship:GetPos()
    local thirdperson = ply:GetThirdperson()
    if thirdperson then
      local dir = -ang:Forward()
      local tr = util.TraceHull({
        start = start,
        endpos = start + camOffset + dir * 40,
        filter = function(e)
          return not camNoClip[e:GetClass()]
        end,
        mins = -camRadius,
        maxs = camRadius,
        mask = MASK_PLAYERSOLID,
      })
      pos = tr.HitPos
    else
      pos = start
    end
    return pos, ang
  end
end

nextWorldGenTimestamp = nextWorldGenTimestamp or 0

function setNextWorldGen(timestamp)
  nextWorldGenTimestamp = timestamp
  if SERVER then
    net.Start('cave.setNextWorldGen')
      net.WriteFloat(timestamp)
    net.Broadcast()
  end
end

function timeleft()
  return nextWorldGenTimestamp - CurTime()
end

if SERVER then
  util.AddNetworkString('cave.setNextWorldGen')
else
  net.Receive('cave.setNextWorldGen', function(len)
    setNextWorldGen(net.ReadFloat())
  end)
end

include('sh_noise.lua')
include('sh_terrain.lua')
include('player_shipdriver.lua')

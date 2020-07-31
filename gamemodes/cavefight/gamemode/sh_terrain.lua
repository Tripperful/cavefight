AddCSLuaFile()

function caveCenterDist(x, y)
  return math.sqrt(math.pow(x, 2) + math.pow(y, 2))
end

function caveChunkTriangles(heights, chunkX, chunkY)
  local sx, sy = caveChunkSize / caveResX, caveChunkSize / caveResY
  local cx, cy = chunkX * caveChunkSize, chunkY * caveChunkSize
  local lc = Vector(-0.5 * caveChunkSize, -0.5 * caveChunkSize, 0)
  local triangles = {}
  local normals = {}
  for y = 0, #heights - 1 do
    for x = 0, #heights[y] - 1 do
      local h1, h2, h3, h4 = heights[y][x], heights[y + 1][x], heights[y][x + 1], heights[y + 1][x + 1]
      local p1 = lc + Vector((x - 1) * sx, (y - 1) * sy, h1)
      local p2 = lc + Vector((x - 1) * sx, y * sy, h2)
      local p3 = lc + Vector(x * sx, (y - 1) * sy, h3)
      local p4 = lc + Vector(x * sx, y * sy, h4)
      local p5 = lc + Vector((x - 1) * sx, (y - 1) * sy, h1)
      local p6 = lc + Vector((x - 1) * sx, y * sy, h2)
      local p7 = lc + Vector(x * sx, (y - 1) * sy, h3)
      local p8 = lc + Vector(x * sx, y * sy, h4)
      p5.z = p5.z + math.Clamp(caveMapSize / 2 - caveCenterDist(cx + p5.x, cy + p5.y), 0, caveMaxCeil)
      p6.z = p6.z + math.Clamp(caveMapSize / 2 - caveCenterDist(cx + p6.x, cy + p6.y), 0, caveMaxCeil)
      p7.z = p7.z + math.Clamp(caveMapSize / 2 - caveCenterDist(cx + p7.x, cy + p7.y), 0, caveMaxCeil)
      p8.z = p8.z + math.Clamp(caveMapSize / 2 - caveCenterDist(cx + p8.x, cy + p8.y), 0, caveMaxCeil)
      if not (p1.z == p5.z and p2.z == p6.z and p3.z == p7.z and p4.z == p8.z) then
        local n1 = (p3 - p2):Cross(p2 - p1):GetNormalized() / 4
        local n2 = (p4 - p2):Cross(p2 - p3):GetNormalized() / 4
        normals[y], normals[y + 1] = normals[y] or {}, normals[y + 1] or {}
        normals[y][x],
        normals[y + 1][x],
        normals[y][x + 1],
        normals[y + 1][x + 1] =
          normals[y][x] or Vector(),
          normals[y + 1][x] or Vector(),
          normals[y][x + 1] or Vector(),
          normals[y + 1][x + 1] or Vector()
        normals[y][x] = normals[y][x] + n1
        normals[y + 1][x] = normals[y + 1][x] + n1 + n2
        normals[y][x + 1] = normals[y][x + 1] + n1 + n2
        normals[y + 1][x + 1] = normals[y + 1][x + 1] + n2
        if x > 0 and y > 0 and x < #heights - 1 and y < #heights[x] - 1 then
          table.insert(triangles, {pos = p1, x = x, y = y})
          table.insert(triangles, {pos = p2, x = x, y = y + 1})
          table.insert(triangles, {pos = p3, x = x + 1, y = y})
          table.insert(triangles, {pos = p3, x = x + 1, y = y})
          table.insert(triangles, {pos = p2, x = x, y = y + 1})
          table.insert(triangles, {pos = p4, x = x + 1, y = y + 1})

          table.insert(triangles, {pos = p5, x = x, y = y, flip = true})
          table.insert(triangles, {pos = p7, x = x + 1, y = y, flip = true})
          table.insert(triangles, {pos = p6, x = x, y = y + 1, flip = true})
          table.insert(triangles, {pos = p7, x = x + 1, y = y, flip = true})
          table.insert(triangles, {pos = p8, x = x + 1, y = y + 1, flip = true})
          table.insert(triangles, {pos = p6, x = x, y = y + 1, flip = true})
        end
      end
    end
  end
  for _, vertex in pairs(triangles) do
    vertex.normal = normals[vertex.y][vertex.x]
    if vertex.flip then
      vertex.normal = -vertex.normal
      vertex.flip = nil
    end
    vertex.u, vertex.v = vertex.x * caveTextureTile, vertex.y * caveTextureTile
    vertex.x, vertex.y = nil, nil
  end
  return triangles
end

function caveHeightAtPoint(s, x, y)
  local nx, ny = s + x / caveChunkSize * caveNoiseScale, y / caveChunkSize * caveNoiseScale
  local h = 0
  h = h + perlinNoise(nx * 0.5, ny * 0.5) * caveMaxH
  h = h + perlinNoise(nx * 2, ny * 2) * caveMaxH / 2
  h = h + perlinNoise(nx * 6, ny * 6) * caveMaxH / 8
  return h
end

function caveNoiseChunk(s, dx, dy)
  local t = {}
  for y = 0, caveResY + 2 do
    t[y] = {}
    for x = 0, caveResX + 2 do
      t[y][x] = caveHeightAtPoint(s, ((x - 1) / caveResX + dx - 0.5) * caveChunkSize, ((y - 1) / caveResY + dy - 0.5) * caveChunkSize)
    end
  end
  return t
end

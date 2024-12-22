local insert, remove
do
  local _obj_0 = table
  insert, remove = _obj_0.insert, _obj_0.remove
end
local DrawBeam, SetMaterial
do
  local _obj_0 = render
  DrawBeam, SetMaterial = _obj_0.DrawBeam, _obj_0.SetMaterial
end
local Clamp, ceil, random
do
  local _obj_0 = math
  Clamp, ceil, random = _obj_0.Clamp, _obj_0.ceil, _obj_0.random
end
local Decompress, JSONToTable
do
  local _obj_0 = util
  Decompress, JSONToTable = _obj_0.Decompress, _obj_0.JSONToTable
end
local ThornManager
do
  local _class_0
  local _base_0 = {
    getSparkSound = function(self)
      local sparkNumber = random(3, 6)
      return "ambient/energy/spark" .. tostring(sparkNumber) .. ".wav"
    end,
    playSparkSound = function(self, attacker)
      local sparkSound = self:getSparkSound()
      return attacker:EmitSound(sparkSound, 75, 100, 1)
    end,
    generateThornSegments = function(self, thorn)
      local ply, attacker, amount, createdAt
      ply, attacker, amount, createdAt = thorn.ply, thorn.attacker, thorn.amount, thorn.createdAt
      if not (IsValid(attacker)) then
        return 
      end
      local startOffset = random(45, 50)
      local offset = random(20, 50)
      local startPos = ply:GetPos() + Vector(0, 0, startOffset)
      local endPos = attacker:GetPos() + Vector(0, 0, offset)
      local segments = { }
      local segmentLength = 50
      local segmentCount = ceil(startPos:Distance(endPos) / segmentLength) + 2
      local lastPos = startPos
      local lastOffset = Vector(0, 0, 0)
      for i = 1, segmentCount do
        local t = i / segmentCount
        local lerpedPos = startPos * (1 - t) + endPos * t
        if i == 1 then
          lerpedPos = startPos
        end
        offset = Vector(0, 0, 0)
        if (i ~= 1) and i ~= segmentCount then
          local zigZaggyness = random(10, 40)
          offset = VectorRand() * zigZaggyness
        end
        insert(segments, lerpedPos + offset)
        lastPos = lerpedPos
        lastOffset = offset
      end
      thorn.segments = segments
    end,
    drawThorns = function(self)
      local now = CurTime()
      for i, thorn in pairs(self.thorns) do
        local _continue_0 = false
        repeat
          local amount = thorn.amount
          local createdAt = thorn.createdAt
          local segments = thorn.segments
          local lifetime = now - createdAt
          if lifetime > self.thornDuration then
            remove(self.thorns, i)
            _continue_0 = true
            break
          end
          for k, segment in pairs(segments) do
            local lastPos = segments[k - 1] or segment
            local t = k / #segments
            local widthModifier = amount * self.thornDamageMult
            local thornAge = 1 - lifetime / self.thornDuration
            local width = widthModifier * thornAge
            SetMaterial(self.thornMat)
            DrawBeam(lastPos, segment, width, 0, 0, Color(93, 227, 232))
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
    end,
    addThorn = function(self, thorn)
      self:generateThornSegments(thorn)
      insert(self.thorns, thorn)
      return self:playSparkSound(thorn.attacker)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.thorns = { }
      self.thornMat = Material("cable/blue_elec")
      self.thornDuration = 0.25
      self.thornDamageMult = 5
      return hook.Add("PostDrawTranslucentRenderables", "CFC_Powerups-ThornsRenderer", function()
        return self:drawThorns()
      end)
    end,
    __base = _base_0,
    __name = "ThornManager"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ThornManager = _class_0
end
local Thorn
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, thornyPly, attacker, amount)
      self.ply = thornyPly
      self.attacker = attacker
      self.amount = amount
      self.createdAt = CurTime()
    end,
    __base = _base_0,
    __name = "Thorn"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Thorn = _class_0
end
local manager = ThornManager()
return net.Receive("CFC_Powerups-ThornsDamage", function()
  local damageData = net.ReadTable()
  for ply, attackers in pairs(damageData) do
    local _continue_0 = false
    repeat
      if not (IsValid(ply)) then
        _continue_0 = true
        break
      end
      for attacker, amount in pairs(attackers) do
        local _continue_1 = false
        repeat
          if not (IsValid(attacker)) then
            _continue_1 = true
            break
          end
          local thorn = Thorn(ply, attacker, amount)
          manager:addThorn(thorn)
          if #manager.thorns >= 25 then
            return 
          end
          _continue_1 = true
        until true
        if not _continue_1 then
          break
        end
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end)

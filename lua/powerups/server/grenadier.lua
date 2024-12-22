local getConf
getConf = CFCPowerups.Config.get
local Rand, cos, sin
do
  local _obj_0 = math
  Rand, cos, sin = _obj_0.Rand, _obj_0.cos, _obj_0.sin
end
local Create
Create = ents.Create
local SpriteTrail
SpriteTrail = util.SpriteTrail
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    AltFireAdjustor = function(self)
      local altFireDelay = getConf("grenadier_alt_fire_delay")
      local activeWeapon = self.owner:GetActiveWeapon()
      if not (IsValid(activeWeapon)) then
        return 
      end
      if not (activeWeapon:GetClass() == "weapon_smg1") then
        return 
      end
      if not (activeWeapon:GetNextSecondaryFire() > CurTime() + altFireDelay) then
        return 
      end
      if self.UsesRemaining < 1 then
        return 
      end
      activeWeapon:SetNextSecondaryFire(CurTime() + altFireDelay)
      self.UsesRemaining = self.UsesRemaining - 1
    end,
    NewAltFireWatcher = function(self)
      return function(ent)
        if not (ent:GetClass() == "grenade_ar2") then
          return 
        end
        if not (ent:GetOwner() == self.owner) then
          return 
        end
        if ent.isClustered then
          return 
        end
      end
    end,
    NewExplosionWatcher = function(self)
      return function(ent)
        if not (ent:GetClass() == "grenade_ar2") then
          return 
        end
        if not (ent:GetOwner() == self.owner) then
          return 
        end
        if ent.isClustered then
          return 
        end
        local distanceMin = getConf("grenadier_cluster_min_distance")
        local distanceMax = getConf("grenadier_cluster_max_distance")
        local heightMin = getConf("grenadier_cluster_min_height")
        local heightMax = getConf("grenadier_cluster_max_height")
        local clusterDelay = getConf("grenadier_cluster_delay")
        local clusterCount = getConf("grenadier_cluster_count")
        local impactSound = getConf("grenadier_cluster_impact_sound")
        ent:EmitSound(impactSound, 150)
        local theta = (math.pi * 2) / clusterCount
        local entPos = ent:GetPos()
        timer.Simple(clusterDelay, function()
          if ent.isClustered then
            return 
          end
          for i = 1, clusterCount do
            local height = Rand(heightMin, heightMax)
            local ang = theta * i
            local xDistance = Rand(distanceMin, distanceMax)
            local x = cos(ang) * xDistance
            local yDistance = Rand(distanceMin, distanceMax)
            local y = sin(ang) * yDistance
            local offset = Vector(x, y, height)
            local newPos = entPos + offset
            local cluster = Create("grenade_ar2")
            cluster.isClustered = true
            cluster:Spawn()
            cluster:SetOwner(self.owner)
            SpriteTrail(cluster, 0, Color(255, 0, 0), true, 5, 1, 1, 0.8, "smoke")
            timer.Simple(0.01, function()
              cluster.isClustered = true
            end)
            cluster:SetPos(entPos)
            cluster:SetVelocity((newPos - entPos) * 5)
          end
        end)
        if self.UsesRemaining < 1 then
          return self:Remove()
        end
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      local steamID = self.owner:SteamID64()
      self.explosionWatcher = "CFC_Powerups-Grenadier-ExplosionWatcher-" .. tostring(steamID)
      hook.Add("EntityRemoved", self.explosionWatcher, self:NewExplosionWatcher())
      self.altFireWatcher = "CFC_Powerups-Grenadier-AltFireWatcher-" .. tostring(steamID)
      hook.Add("OnEntityCreated", self.altFireWatcher, self:NewAltFireWatcher())
      self.adjustorTimer = "CFC_Powerups-Grenadier-AltFireAdjustor-" .. tostring(steamID)
      timer.Create(self.adjustorTimer, 0.1, 0, function()
        return self:AltFireAdjustor()
      end)
      local smg1 = "weapon_smg1"
      local smg1ammo = 9
      do
        local _with_0 = self.owner
        _with_0:Give(smg1)
        _with_0:GiveAmmo(15, smg1ammo, true)
        _with_0:SelectWeapon(smg1)
        _with_0:ChatPrint("You've gained " .. tostring(self.UsesRemaining) .. " Grenadier rounds")
        return _with_0
      end
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      local usesGained = getConf("grenadier_uses")
      self.UsesRemaining = self.UsesRemaining + usesGained
      return self.owner:ChatPrint("You've gained " .. tostring(usesGained) .. " extra Grenadier rounds (total: " .. tostring(self.UsesRemaining) .. ")")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.adjustorTimer)
      hook.Remove("EntityRemoved", self.explosionWatcher)
      hook.Remove("OnEntityCreated", self.altFireWatcher)
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:ChatPrint("You've lost the Grenadier Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.UsesRemaining = getConf("grenadier_uses")
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "GrenadierPowerup",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.powerupID = "powerup_grenadier"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  GrenadierPowerup = _class_0
end
return hook.Add("EntityTakeDamage", "CFC_Powerups-Grenadier-PreventChainExplosion", function(ent, damageInfo)
  if not (ent:GetClass() == "grenade_ar2") then
    return 
  end
  if not (ent.isClustered) then
    return 
  end
  local inflictorClass = damageInfo:GetInflictor():GetClass()
  if inflictorClass == "grenade_ar2" then
    return true
  end
end)

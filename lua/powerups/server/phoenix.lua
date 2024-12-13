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
local IGNORED_INFLICTORS = {
  cfc_simple_ent_antigrav_grenade = true,
  cfc_simple_ent_bubble_grenade = true,
  cfc_simple_ent_curse_grenade = true
}
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    Revive = function(self)
      self.UsesRemaining = self.UsesRemaining - 1
      self.immune = true
      self.ownerModel = self.owner:GetModel()
      local maxRegenHealth = math.min(self.reviveHealth, self.owner:GetMaxHealth())
      local maxRegenArmor = math.min(self.reviveArmor, self.owner:GetMaxArmor())
      do
        local _with_0 = self.owner
        _with_0:SetHealth(1)
        _with_0:SetArmor(maxRegenArmor == 0 and 0 or 1)
        _with_0:ChatPrint("Like a phoenix, you rise from the ashes! (" .. tostring(self.UsesRemaining) .. " uses remaining)")
        local splodePitch = math.random(80, 90)
        _with_0:EmitSound("ambient/levels/labs/electric_explosion4.wav", 75, splodePitch, 1)
        _with_0:ScreenFade(SCREENFADE.IN, Color(255, 240, 230, 150), 2, 0.1)
        util.ScreenShake(_with_0:GetPos(), 10, 20, 2.5, 1500)
        util.ScreenShake(_with_0:GetPos(), 40, 40, 0.5, 500)
      end
      do
        local eff = EffectData()
        eff:SetOrigin(self.owner:GetPos())
        eff:SetNormal(Vector(0, 0, 1))
        util.Effect("VortDispel", eff, true, true)
        util.Effect("HL1GaussWallImpact2", eff, true, true)
      end
      do
        local eff = EffectData()
        eff:SetOrigin(self.owner:WorldSpaceCenter())
        eff:SetNormal(Vector(0, 0, -1))
        eff:SetMagnitude(50)
        util.Effect("HL1GaussWallPunchExit", eff, true, true)
      end
      do
        local eff = EffectData()
        eff:SetOrigin(self.owner:GetPos())
        eff:SetMagnitude(1)
        eff:SetScale(1)
        util.Effect("cball_explode", eff, true, true)
      end
      self.setModel(self.owner, "models/player/charple.mdl")
      do
        local _with_0 = CreateSound(self.owner, "music/hl2_song10.mp3")
        self.holyMusic = _with_0
        local songPitch = math.random(140, 160)
        _with_0:PlayEx(1, songPitch)
        _with_0:FadeOut(self.immunityDuration)
      end
      do
        local _with_0 = CreateSound(self.owner, "player/heartbeat1.wav")
        self.heartbeatSound = _with_0
        _with_0:Play(75, 80)
      end
      timer.Create(self.regenTimerName, 0.1, 0, function()
        local good = self.immune and IsValid(self.owner)
        if not (good) then
          return timer.Remove(self.regenTimerName)
        end
        do
          local _with_0 = self.owner
          local health = _with_0:Health()
          if health < maxRegenHealth then
            local addHealth = math.random(1, 5)
            local newHealth = math.Clamp(health + addHealth, 0, maxRegenHealth)
            _with_0:SetHealth(newHealth)
          end
          local armor = _with_0:Armor()
          if armor < maxRegenArmor then
            local addArmor = math.random(1, 5)
            local newArmor = math.Clamp(armor + addArmor, 0, maxRegenArmor)
            _with_0:SetArmor(newArmor)
          end
          return _with_0
        end
      end)
      return timer.Create(self.timerName, self.immunityDuration, 1, function()
        self.immune = false
        timer.Remove(self.regenTimerName)
        if IsValid(self.owner) then
          self.holyMusic:Stop()
          self.holyMusic = nil
          self.heartbeatSound:Stop()
          self.heartbeatSound = nil
          self.setModel(self.owner, self.ownerModel)
          self.ownerModel = nil
          for i = 1, 5 do
            local pitch = Lerp(i / 5, 80, 140)
            self.owner:EmitSound("ambient/machines/thumper_hit.wav", 75, pitch, 0.5)
          end
        end
        if not (self.UsesRemaining > 0) then
          return self:Remove()
        end
      end)
    end,
    DamageWatcher = function(self)
      return function(victim, damageInfo)
        if not (victim == self.owner) then
          return 
        end
        if self.immune then
          return true
        end
        if not (victim:Alive()) then
          return 
        end
        local newHealth = math.floor(victim:Health() - damageInfo:GetDamage())
        if not (newHealth <= 0) then
          return 
        end
        local shouldIgnore = hook.Run("CFC_Powerups-Phoenix-ShouldIgnoreDamage", victim, damageInfo)
        if shouldIgnore == true then
          return 
        end
        self:Revive()
        return true
      end
    end,
    DamageVictimWatcher = function(self)
      return function(victim, damageInfo)
        if victim == self.owner then
          return 
        end
        if not (self.immune) then
          return 
        end
        damageInfo:ScaleDamage(self.immunityDamageMult)
        return nil
      end
    end,
    CollisionListener = function(self)
      return function(_, colData)
        local otherEnt = colData.HitEntity
        if not (IsValid(otherEnt)) then
          return 
        end
        if not (otherEnt:GetClass() == "prop_combine_ball") then
          return 
        end
        if otherEnt._cfcPowerups_phoenix_alreadyHit then
          return 
        end
        otherEnt._cfcPowerups_phoenix_alreadyHit = true
        otherEnt:Remove()
        if not (self.immune) then
          return self:Revive()
        end
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      local steamID = self.owner:SteamID64()
      self.damageWatcherName = "CFC_Powerups-Phoenix-DamageWatcher-" .. tostring(steamID)
      self.damageVictimWatcherName = "CFC_Powerups-Phoenix-DamageVictimWatcher-" .. tostring(steamID)
      self.timerName = "CFC_Powerups-Phoenix-Timer-" .. tostring(steamID)
      self.regenTimerName = "CFC_Powerups-Phoenix-Regen-Timer-" .. tostring(steamID)
      self.collisionListenerID = self.owner:AddCallback("PhysicsCollide", self:CollisionListener())
      hook.Add("EntityTakeDamage", self.damageWatcherName, self:DamageWatcher(), HOOK_LOW)
      hook.Add("EntityTakeDamage", self.damageVictimWatcherName, self:DamageVictimWatcher())
      self.hadNoDissolve = self.owner:IsEFlagSet(EFL_NO_DISSOLVE)
      self.owner:AddEFlags(EFL_NO_DISSOLVE)
      return self.owner:ChatPrint("You've gained " .. tostring(self.UsesRemaining) .. " Phoenix round(s)")
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      local usesGained = getConf("phoenix_uses")
      local maxUses = getConf("phoenix_max_uses")
      local oldUses = self.UsesRemaining
      local newUses = math.min(oldUses + usesGained, maxUses)
      self.UsesRemaining = newUses
      return self.owner:ChatPrint("You've gained " .. tostring(newUses - oldUses) .. " extra Phoenix round(s) (total: " .. tostring(self.UsesRemaining) .. ")")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      timer.Remove(self.timerName)
      timer.Remove(self.regenTimerName)
      hook.Remove("EntityTakeDamage", self.damageWatcherName)
      hook.Remove("EntityTakeDamage", self.damageVictimWatcherName)
      if not (IsValid(self.owner)) then
        return 
      end
      if self.holyMusic then
        self.holyMusic:Stop()
      end
      if self.heartbeatSound then
        self.heartbeatSound:Stop()
      end
      self.owner:RemoveCallback("PhysicsCollide", self.collisionListenerID)
      if not self.hadNoDissolve then
        self.owner:RemoveEFlags(EFL_NO_DISSOLVE)
      end
      if self.ownerModel then
        self.setModel(self.owner, self.ownerModel)
      end
      if self.UsesRemaining == 0 then
        self.owner:ChatPrint("You've lost the Phoenix Powerup")
      else
        self.owner:ChatPrint("The Phoenix spirit tried, but your body was unrecoverable...")
      end
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.UsesRemaining = getConf("phoenix_uses")
      self.reviveHealth = getConf("phoenix_revive_health")
      self.reviveArmor = getConf("phoenix_revive_armor")
      self.immunityDamageMult = getConf("phoenix_immunity_damage_multiplier")
      self.immunityDuration = getConf("phoenix_immunity_duration")
      self.setModel = FindMetaTable("Entity").SetModel
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "PhoenixPowerup",
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
  self.powerupID = "powerup_phoenix"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  PhoenixPowerup = _class_0
end
hook.Add("CFC_Powerups_DisallowGetPowerup", "CFC_Powerups-Phoenix-EnforceUseLimit", function(_, powerupId, existingPowerup)
  if not (powerupId == "powerup_phoenix") then
    return 
  end
  if not (existingPowerup) then
    return 
  end
  local maxUses = getConf("phoenix_max_uses")
  if not (existingPowerup.UsesRemaining >= maxUses) then
    return 
  end
  return true, "You're maxed out on Phoenix uses"
end)
return hook.Add("CFC_Powerups-Phoenix-ShouldIgnoreDamage", "CFC_Powerups-Phoenix-IgnoredInflictors", function(_, damageInfo)
  local inflictor = damageInfo:GetInflictor()
  if not (IsValid(inflictor)) then
    return 
  end
  if not (IGNORED_INFLICTORS[inflictor:GetClass()]) then
    return 
  end
  return true
end)

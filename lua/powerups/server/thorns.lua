local getConf
getConf = CFCPowerups.Config.get
local AddNetworkString, Compress, Effect, TableToJSON
do
  local _obj_0 = util
  AddNetworkString, Compress, Effect, TableToJSON = _obj_0.AddNetworkString, _obj_0.Compress, _obj_0.Effect, _obj_0.TableToJSON
end
local random, Round
do
  local _obj_0 = math
  random, Round = _obj_0.random, _obj_0.Round
end
local Count, insert
do
  local _obj_0 = table
  Count, insert = _obj_0.Count, _obj_0.insert
end
AddNetworkString("CFC_Powerups-ThornsDamage")
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    PlayAoeEffect = function(self)
      do
        local effect = EffectData()
        effect:SetEntity(self.holo)
        effect:SetScale(1)
        effect:SetMagnitude(12)
        Effect("TeslaHitboxes", effect, true, true)
        return effect
      end
    end,
    MakeHolo = function(self)
      local holo = ents.Create("base_anim")
      local parentAttachment = 6
      do
        holo:SetModel("models/hunter/blocks/cube025x025x025.mdl")
        holo:SetPos(self.owner:GetPos() + Vector(0, 0, 50))
        holo:SetParent(self.owner, parentAttachment)
        holo:SetRenderMode(RENDERMODE_NONE)
        holo:DrawShadow(false)
        holo:Spawn()
        holo:CallOnRemove("CleanupOnRemove", function()
          return self.passiveSound:Stop()
        end)
      end
      return holo
    end,
    BroadcastDamage = function(self)
      net.Start("CFC_Powerups-ThornsDamage")
      net.WriteTable(self.BroadcastQueue)
      net.Broadcast()
      self.LastDamageBroadcast = CurTime()
      self.BroadcastQueue = { }
    end,
    QueueDamageForBroadcast = function(self, attacker, amount)
      self.BroadcastQueue[self.owner] = self.BroadcastQueue[self.owner] or { }
      local ownerToAttacker = self.BroadcastQueue[self.owner][attacker]
      if ownerToAttacker then
        self.BroadcastQueue[self.owner][attacker] = self.BroadcastQueue[self.owner][attacker] + amount
      else
        self.BroadcastQueue[self.owner][attacker] = amount
      end
      local now = CurTime()
      local diff = now - self.LastDamageBroadcast
      local overLimit = self:BroadcastQueueSize() > self.BroadcastQueueLimit
      local expired = diff >= self.BroadcastInterval
      if expired or overLimit then
        return self:BroadcastDamage()
      end
    end,
    DamageWatcher = function(self)
      return function(ent, dmg, took)
        if not (ent == self.owner) then
          return 
        end
        if took == false then
          return 
        end
        local attacker = dmg:GetAttacker()
        if not (IsValid(attacker)) then
          return 
        end
        if ent == attacker then
          return 
        end
        local inflictor = dmg:GetInflictor()
        if IsValid(inflictor) and inflictor:GetClass() == "cfc_powerup_thorns_inflictor" then
          return 
        end
        local damageAmount = dmg:GetDamage()
        if not (damageAmount > 0) then
          return 
        end
        local damageScale = getConf("thorns_return_percentage")
        damageScale = damageScale / 100
        local reflectedAmount = math.ceil(damageAmount * damageScale)
        local thornsInflictor = self.damageInflictor
        timer.Simple(0, function()
          if not (IsValid(attacker)) then
            return 
          end
          if not (IsValid(ent)) then
            return 
          end
          if not (IsValid(thornsInflictor)) then
            return 
          end
          do
            local refDmg = DamageInfo()
            refDmg:SetAttacker(ent)
            refDmg:SetInflictor(thornsInflictor)
            refDmg:SetDamage(reflectedAmount)
            refDmg:SetDamageType(DMG_GENERIC)
            attacker:TakeDamageInfo(refDmg)
            return refDmg
          end
        end)
        self:QueueDamageForBroadcast(attacker, reflectedAmount)
        return nil
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      self.duration = getConf("thorns_duration")
      local damageWatcher = self:DamageWatcher()
      hook.Add("PostEntityTakeDamage", self.HookName, damageWatcher)
      hook.Add("DoPlayerDeath", self.HookName, function(ply, _, dmg)
        return damageWatcher(ply, dmg)
      end)
      timer.Create(self.TimerName, self.duration, 1, function()
        return self:Remove()
      end)
      timer.Create(self.ZapperName, 0.1, self.duration * 10, function()
        return self:PlayAoeEffect()
      end)
      self.passiveSound:Play()
      self.passiveSound:ChangeVolume(0.1)
      self.owner:SetNWBool("CFC_Powerups-HasThorns", true)
      return self.owner:ChatPrint("You've gained " .. tostring(duration) .. " seconds of the Thorns Powerup")
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      timer.Start(self.TimerName)
      timer.Create(self.ZapperName, 0.1, self.duration * 10, function()
        return self:PlayAoeEffect()
      end)
      return self.owner:ChatPrint("You've refreshed the duration of your Thorns Powerup")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      hook.Remove("PostEntityTakeDamage", self.HookName)
      hook.Remove("DoPlayerDeath", self.HookName)
      timer.Remove(self.TimerName)
      timer.Remove(self.ZapperName)
      self.passiveSound:Stop()
      local damageInflictor = self.damageInflictor
      if IsValid(self.holo) then
        self.holo:Remove()
      end
      timer.Simple(0.5, function()
        if not (IsValid(damageInflictor)) then
          return 
        end
        return damageInflictor:Remove()
      end)
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:SetNWBool("CFC_Powerups-HasThorns", false)
      self.owner:ChatPrint("You've lost the Thorns Powerup")
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.holo = self:MakeHolo()
      self.LastDamageBroadcast = CurTime()
      self.BroadcastQueue = { }
      self.BroadcastInterval = 0.5
      self.BroadcastQueueLimit = 75
      self.BroadcastQueueSize = function()
        local count = 0
        for ply, targets in pairs(self.BroadcastQueue) do
          count = count + Count(targets)
        end
        return count
      end
      self.passiveSoundPath = "ambient/energy/force_field_loop1.wav"
      self.passiveSound = CreateSound(self.holo, self.passiveSoundPath)
      self.passiveSound:SetSoundLevel(100)
      self.TimerName = "CFC-Powerups_Thorns-" .. tostring(ply:SteamID64())
      self.HookName = self.TimerName
      self.ZapperName = tostring(self.TimerName) .. "-Zapper"
      do
        local _with_0 = ents.Create("cfc_powerup_thorns_inflictor")
        self.damageInflictor = _with_0
        _with_0:SetOwner(self.owner)
        _with_0:Spawn()
      end
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "ThornsPowerup",
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
  self.powerupID = "powerup_thorns"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  ThornsPowerup = _class_0
  return _class_0
end

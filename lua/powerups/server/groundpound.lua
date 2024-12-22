local getConf
getConf = CFCPowerups.Config.get
local TERMINAL_VELOCITY = 3500
local EASE_FUNC = math.ease.InQuad
local BAD_MOVETYPES = {
  MOVETYPE_NONE = true,
  MOVETYPE_NOCLIP = true,
  MOVETYPE_LADDER = true,
  MOVETYPE_OBSERVER = true
}
local FALL_SOUND_FADE_IN = 0.75
local FALL_SOUND_FADE_OUT = 0.01
local RADIUS_PER_DAMAGE = 2.5
local DIRECTHIT_DMG_MUL = 1
local TERMINAL_EXTRABLAST_DMGMUL = 75
local TERMINAL_EXTRABLAST_RADIUS_MUL = 0.25
local TRAIL_ENABLED = true
local TRAIL_INTERVAL = 0.1
local TRAIL_LENGTH = 2
local TRAIL_SPEED = 2
local TRAIL_OFFSET_SPREAD = 30
local TRAIL_AMOUNT = 5
local UP_VECTOR = Vector(0, 0, 1)
do
  local _class_0
  local _parent_0 = BasePowerup
  local _base_0 = {
    CreateOwnerDamageWatcher = function(self)
      return function(victim, damageInfo)
        if not (victim == self.owner) then
          return 
        end
        if damageInfo:IsFallDamage() then
          return true
        end
        if not (damageInfo:GetAttacker() == victim) then
          return 
        end
        local inflictor = damageInfo:GetInflictor()
        if not (IsValid(inflictor)) then
          return 
        end
        if not (inflictor:GetClass() == "cfc_powerup_groundpound_inflictor") then
          return 
        end
        return true
      end
    end,
    CreateVictimDamageWatcher = function(self)
      return function(victim, damageInfo)
        if victim == self.owner then
          return 
        end
        if not (damageInfo:GetAttacker() == self.owner) then
          return 
        end
        local inflictor = damageInfo:GetInflictor()
        if not (IsValid(inflictor)) then
          return 
        end
        if not (inflictor:GetClass() == "cfc_powerup_groundpound_inflictor") then
          return 
        end
        local physObj = victim:GetPhysicsObject()
        if not (victim:IsPlayer() or ((IsValid(physObj)) and physObj:IsMotionEnabled())) then
          return 
        end
        local knockback = self.knockbackMult * damageInfo:GetDamage()
        local dir = victim:WorldSpaceCenter() - self.owner:GetPos()
        local ang = dir:Angle()
        local pitch = -math.Rand(40, 60)
        dir = Angle(pitch, ang.yaw, 0):Forward()
        if victim:IsPlayer() then
          local clampedKnockback = math.min(knockback, self.knockbackMax)
          local velToAdd = dir * knockback + Vector(0, 0, 250)
          victim:SetVelocity(velToAdd)
          damageInfo:SetDamageForce(velToAdd * 100)
        else
          local up = 5 * math.pow(physObj:GetMass(), 0.97)
          local force = dir * knockback + UP_VECTOR * up
          physObj:ApplyForceCenter(force)
        end
        damageInfo:SetDamagePosition(victim:WorldSpaceCenter())
        return nil
      end
    end,
    CreateFallDamageWatcher = function(self)
      return function(ply, speed)
        if not (ply == self.owner) then
          return 
        end
        if not (speed >= self.minSpeed) then
          return 
        end
        if not (self.owner:KeyDown(IN_DUCK)) then
          return 
        end
        self.nextUpToSpeedSound = 0
        self.nextUpToTerminalSpeedSound = 0
        local speedClamped = math.min(speed, TERMINAL_VELOCITY)
        local speedZeroToOne = speedClamped / TERMINAL_VELOCITY
        local speedOneToZero = 1 - speedZeroToOne
        speedOneToZero = EASE_FUNC(speedOneToZero)
        speedZeroToOne = EASE_FUNC(speedZeroToOne)
        local speedAbove = speedClamped - self.minSpeed
        local damage = self.baseDamage
        local damageAdd = speedAbove * self.addedDamage
        damage = damage + damageAdd
        local radius = damage * RADIUS_PER_DAMAGE
        local ownersPos = self.owner:WorldSpaceCenter()
        util.BlastDamage(self.damageInflictor, self.owner, ownersPos, radius, damage)
        self.UsesRemaining = self.UsesRemaining - 1
        self.owner:ChatPrint("You have " .. tostring(math.max(self.UsesRemaining, 0)) .. " Groundpound uses remaining")
        util.ScreenShake(ownersPos, speedZeroToOne * 40, 4, 2, 1000)
        util.ScreenShake(ownersPos, 1, 5, 5, damage * 2)
        do
          local _with_0 = self.owner
          local groundEntity = self.owner:GetGroundEntity()
          if IsValid(groundEntity) then
            local damageInfo = DamageInfo()
            do
              damageInfo:SetAttacker(self.owner)
              damageInfo:SetInflictor(self.damageInflictor)
              damageInfo:SetDamage(damage * DIRECTHIT_DMG_MUL)
              damageInfo:SetDamageType(DMG_BLAST)
              damageInfo:SetDamageForce(Vector(0, 0, -damage * 10))
              damageInfo:SetDamagePosition(ownersPos)
            end
            groundEntity:TakeDamageInfo(damageInfo)
          end
          local thumpPitch = 110 + -(speedZeroToOne * 20)
          local thumpLvl = 75 + (speedZeroToOne * 60)
          _with_0:EmitSound("ambient/machines/thumper_hit.wav", thumpLvl, thumpPitch, 0.5, CHAN_STATIC)
          if speedClamped < TERMINAL_VELOCITY * 0.35 then
            _with_0:EmitSound("ambient/machines/thumper_dust.wav", 90, 62, 1, CHAN_STATIC)
          end
          if speedClamped > TERMINAL_VELOCITY * 0.35 then
            local hitPitch = 175 + -(speedZeroToOne * 125)
            local hitLvl = 90 + (speedZeroToOne * 50)
            _with_0:EmitSound("weapons/mortar/mortar_explode2.wav", hitLvl, hitPitch)
          end
          if speedClamped > TERMINAL_VELOCITY * 0.65 then
            local crashPitch = 110 + -(speedZeroToOne * 40)
            local crashLvl = 85 + (speedZeroToOne * 60)
            _with_0:EmitSound("ambient/machines/wall_crash1.wav", crashLvl, crashPitch, 0.5)
          end
          if speedClamped > TERMINAL_VELOCITY * 0.9 then
            _with_0:EmitSound("ambient/explosions/exp2.wav", 110, 30, 0.5)
            util.BlastDamage(self.damageInflictor, self.owner, ownersPos, radius * TERMINAL_EXTRABLAST_RADIUS_MUL, damage * TERMINAL_EXTRABLAST_DMGMUL)
          end
        end
        timer.Simple(0, function()
          if not (IsValid(self.owner)) then
            return 
          end
          if speedClamped > TERMINAL_VELOCITY * 0.9 then
            local effDat = EffectData()
            do
              local _with_0 = effDat
              _with_0:SetOrigin(ownersPos)
              _with_0:SetEntity(self.owner)
              _with_0:SetScale(1)
              util.Effect("powerups_groundpound_shockwave", effDat)
              _with_0:SetScale(4)
              _with_0:SetNormal(UP_VECTOR)
              util.Effect("powerups_groundpound_shockwave_huge", effDat)
              return _with_0
            end
          else
            local effDat = EffectData()
            local effScale = speedZeroToOne * 0.5
            effScale = effScale + 0.2
            do
              local _with_0 = effDat
              _with_0:SetOrigin(ownersPos)
              _with_0:SetNormal(UP_VECTOR)
              _with_0:SetScale(effScale)
              util.Effect("powerups_groundpound_shockwave", effDat)
              return _with_0
            end
          end
        end)
        if not (self.UsesRemaining > 0) then
          self:Remove()
        end
        return 0
      end
    end,
    CantFastFall = function(self)
      local owner = self.owner
      if not (owner:Alive()) then
        return true
      end
      if owner:InVehicle() then
        return true
      end
      if owner:IsOnGround() then
        return true
      end
      if BAD_MOVETYPES[owner:GetMoveType()] then
        return true
      end
      if not (owner:KeyDown(IN_DUCK)) then
        return true
      end
      return false
    end,
    HandleFastFallChange = function(self, cantFastFall)
      if not (cantFastFall == self.fastFalling) then
        return 
      end
      if self.fastFalling then
        self.fastFalling = false
        self.upToSpeedSound = false
        self.upToTerminalSpeedSound = false
        return self.fallSound:ChangeVolume(0, FALL_SOUND_FADE_OUT)
      else
        self.fastFalling = true
        self.fallSound:ChangeVolume(1, FALL_SOUND_FADE_IN)
        local now = CurTime()
        if self.nextCrouchSound <= now then
          self.owner:EmitSound("ambient/machines/thumper_top.wav", 78, 110, 1)
          self.nextCrouchSound = now + 0.75
        end
      end
    end,
    DoWindTrail = function(self)
      if not (TRAIL_ENABLED) then
        return 
      end
      local now = CurTime()
      if now < self.nextTrailTime then
        return 
      end
      self.nextTrailTime = now + TRAIL_INTERVAL
      local vel = self.owner:GetVelocity()
      local startPos = self.owner:GetPos() + self.owner:OBBCenter()
      local endPos = startPos + vel * TRAIL_INTERVAL * TRAIL_LENGTH
      do
        local eff = EffectData()
        eff:SetScale(vel:Length() * TRAIL_SPEED)
        eff:SetFlags(0)
        for _ = 1, TRAIL_AMOUNT do
          local offset = VectorRand(-TRAIL_OFFSET_SPREAD, TRAIL_OFFSET_SPREAD)
          eff:SetStart(startPos + offset)
          eff:SetOrigin(endPos + offset)
          util.Effect("GaussTracer", eff, true, true)
        end
        return eff
      end
    end,
    DoSpeedSounds = function(self, speed)
      if not self.upToSpeedSound then
        self.upToSpeedSound = true
        if self.nextUpToSpeedSound < CurTime() then
          self.owner:EmitSound("weapons/mortar/mortar_shell_incomming1.wav", 120, 100, 0.5)
        end
        self.nextUpToSpeedSound = CurTime() + 15
      end
      if speed >= TERMINAL_VELOCITY and not self.upToTerminalSpeedSound then
        self.upToTerminalSpeedSound = true
        if self.nextUpToTerminalSpeedSound < CurTime() then
          local filter = RecipientFilter()
          filter:AddAllPlayers()
          self.owner:EmitSound("weapons/mortar/mortar_shell_incomming1.wav", 150, 60, 0.5, CHAN_AUTO, 0, 0, filter)
        end
        self.nextUpToSpeedSound = CurTime() + 15
      end
    end,
    CreateThinkWatcher = function(self)
      return function()
        local cantFastFall = self:CantFastFall()
        self:HandleFastFallChange(cantFastFall)
        if cantFastFall then
          return 
        end
        local dt = FrameTime()
        local vel = self.owner:GetVelocity()
        local change = -self.accel * dt
        vel.z = vel.z + change
        local velToAdd = Vector(0, 0, change)
        local speedFrac = math.max(-vel.z / TERMINAL_VELOCITY, 0)
        local fallSoundPitch = Lerp(speedFrac, 100, 200)
        local fallSoundLevel = Lerp(speedFrac, 75, 150)
        self.owner:SetVelocity(velToAdd)
        self.fallSound:ChangePitch(fallSoundPitch, dt)
        self.fallSound:SetSoundLevel(fallSoundLevel)
        if vel.z > -self.minSpeed then
          return 
        end
        self:DoSpeedSounds(-vel.z)
        self:DoWindTrail()
        return nil
      end
    end,
    ApplyEffect = function(self)
      _class_0.__parent.__base.ApplyEffect(self, self)
      hook.Add("EntityTakeDamage", self.hookName, self:CreateOwnerDamageWatcher(), HOOK_HIGH)
      hook.Add("EntityTakeDamage", self.hookNameVictim, self:CreateVictimDamageWatcher())
      hook.Add("GetFallDamage", self.hookName, self:CreateFallDamageWatcher(), HOOK_HIGH)
      hook.Add("Think", self.hookName, self:CreateThinkWatcher())
      return self.owner:ChatPrint("You've gained " .. tostring(self.UsesRemaining) .. " Groundpound uses, crouch in the air to activate")
    end,
    Refresh = function(self)
      _class_0.__parent.__base.Refresh(self, self)
      local usesGained = getConf("groundpound_uses")
      self.UsesRemaining = self.UsesRemaining + usesGained
      return self.owner:ChatPrint("You've gained " .. tostring(usesGained) .. " extra Groundpound uses (total: " .. tostring(self.UsesRemaining) .. ")")
    end,
    Remove = function(self)
      _class_0.__parent.__base.Remove(self, self)
      hook.Remove("EntityTakeDamage", self.hookName)
      hook.Remove("EntityTakeDamage", self.hookNameVictim)
      hook.Remove("GetFallDamage", self.hookName)
      hook.Remove("Think", self.hookName)
      if IsValid(self.damageInflictor) then
        self.damageInflictor:Remove()
      end
      if not (IsValid(self.owner)) then
        return 
      end
      self.owner:ChatPrint("You've lost the Groundpound Powerup")
      self.fallSound:Stop()
      self.owner.Powerups[self.__class.powerupID] = nil
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ply)
      _class_0.__parent.__init(self, ply)
      self.hookName = "CFC_Powerups-Groundpound-" .. tostring(ply:SteamID64())
      self.hookNameVictim = "CFC_Powerups-Groundpound-Victim-" .. tostring(ply:SteamID64())
      self.nextTrailTime = 0
      self.nextUpToSpeedSound = 0
      self.nextUpToTerminalSpeedSound = 0
      self.nextCrouchSound = 0
      self.fastFalling = false
      self.upToSpeedSound = false
      local _ = self.upToTerminalSpeedSound
      self.UsesRemaining = getConf("groundpound_uses")
      self.accel = getConf("groundpound_acceleration")
      self.minSpeed = getConf("groundpound_min_speed")
      self.baseDamage = getConf("groundpound_base_damage")
      self.addedDamage = getConf("groundpound_added_damage")
      self.knockbackMult = getConf("groundpound_knockback_multiplier")
      self.knockbackMax = getConf("groundpound_knockback_max")
      local rf = RecipientFilter()
      rf:AddAllPlayers()
      do
        local _with_0 = ents.Create("cfc_powerup_groundpound_inflictor")
        self.damageInflictor = _with_0
        _with_0:SetOwner(ply)
        _with_0:Spawn()
      end
      do
        local _with_0 = CreateSound(ply, "weapons/physcannon/superphys_hold_loop.wav", rf)
        self.fallSound = _with_0
        _with_0:PlayEx(0, 100)
      end
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "GroundpoundPowerup",
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
  self.powerupID = "powerup_groundpound"
  self.powerupWeights = {
    tier1 = 1,
    tier2 = 1,
    tier3 = 1,
    tier4 = 1
  }
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  GroundpoundPowerup = _class_0
  return _class_0
end

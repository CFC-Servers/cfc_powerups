local Clamp
Clamp = math.Clamp
local currentFluxShield
local FluxShield
do
  local _class_0
  local _base_0 = {
    PowerupTick = function(self)
      if self.scaleDirection == "increasing" then
        self.damageScale = self.damageScale - self.changePerTick
      else
        self.damageScale = self.damageScale + self.changePerTick
      end
      self.damageScale = Clamp(self.damageScale, 0, 1)
    end,
    DrawOverlay = function(self, alpha)
      render.UpdateScreenEffectTexture()
      local overlay = Material("effects/combine_binocoverlay")
      local clampedAlpha = Clamp(alpha, 0, 0.6)
      do
        overlay:SetFloat("$alpha", clampedAlpha)
        overlay:SetFloat("$envmap", 0)
        overlay:SetFloat("$envmaptint", 0)
        overlay:SetFloat("$refractamount", 0)
        overlay:SetInt("$ignorez", 1)
      end
      render.SetMaterial(overlay)
      return render.DrawScreenQuad()
    end,
    ScreenEffect = function(self)
      return function()
        local alpha = (1 - self.damageScale) / (self.maxReduction / 100)
        DrawSharpen(0.2 * alpha, 5 * alpha)
        self:DrawOverlay(alpha)
        local minColor = 0.1
        local maxContrast = 1.4
        local minBrightness = -0.3
        local tab = { }
        tab["$pp_colour_colour"] = Clamp(1 - alpha, minColor, 1)
        tab["$pp_colour_contrast"] = 1 + alpha, 1, maxContrast
        tab["$pp_colour_brightness"] = Clamp(-0.3 * alpha, minBrightness, 1)
        return DrawColorModify(tab)
      end
    end,
    ApplyEffect = function(self)
      timer.Create(self.durationTimer, self.duration, 1, function()
        return self:Remove()
      end)
      timer.Create(self.tickTimer, self.tickInterval, self.totalTicks, function()
        return self:PowerupTick()
      end)
      timer.Create(self.flipTimer, self.duration / 2, 1, function()
        self.scaleDirection = "decreasing"
      end)
      return hook.Add("RenderScreenspaceEffects", self.hookName, self:ScreenEffect())
    end,
    Remove = function(self)
      timer.Remove(self.durationTimer)
      timer.Remove(self.tickTimer)
      timer.Remove(self.flipTimer)
      return hook.Remove("RenderScreenspaceEffects", self.hookName)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, duration, maxReduction, tickInterval)
      self.damageScale = 1
      self.scaleDirection = "increasing"
      self.duration = duration
      self.maxReduction = maxReduction
      self.tickInterval = tickInterval
      self.totalTicks = self.duration / self.tickInterval
      self.changePerTick = (self.maxReduction / (self.totalTicks / 2)) / 100
      self.durationTimer = "CFC-Powerups_FluxShield"
      self.tickTimer = tostring(self.durationTimer) .. "-tick"
      self.flipTimer = tostring(self.durationTimer) .. "-flipper"
      self.hookName = self.durationTimer
      return self:ApplyEffect()
    end,
    __base = _base_0,
    __name = "FluxShield"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  FluxShield = _class_0
end
net.Receive("CFC_Powerups-FluxShield-Start", function()
  local duration = net.ReadUInt(10)
  local maxReduction = net.ReadUInt(7)
  local tickInterval = net.ReadFloat()
  print(duration, maxReduction, tickInterval)
  currentFluxShield = FluxShield(duration, maxReduction, tickInterval)
end)
return net.Receive("CFC_Powerups-FluxShield-Stop", function()
  if not (currentFluxShield) then
    return 
  end
  currentFluxShield:Remove()
  currentFluxShield = nil
end)

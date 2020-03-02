local playerMeta = FindMetaTable("Player")
playerMeta.AddPowerup = function(self, powerup)
  return self.Powerups.insert(powerup)
end
playerMeta.RemovePowerup = function(self, name)
  for key, powerup in pairs(self.Powerups) do
    if (function()
      local _base_0 = powerup
      local _fn_0 = _base_0.Name
      return function(...)
        return _fn_0(_base_0, ...)
      end
    end)() == name then
      powerup.RemovePowerup()
      table.remove(self.Powerups, key)
    end
  end
end
playerMeta.GetPowerup = function(self, name)
  local _list_0 = self.Powerups
  for _index_0 = 1, #_list_0 do
    local powerup = _list_0[_index_0]
    if (function()
      local _base_0 = powerup
      local _fn_0 = _base_0.Name
      return function(...)
        return _fn_0(_base_0, ...)
      end
    end)() == name then
      return powerup
    end
  end
end
playerMeta.HasPowerup = function(self, name)
  return self:GetPowerup(name ~= nil)
end

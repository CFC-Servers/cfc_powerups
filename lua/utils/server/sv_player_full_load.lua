return hook.Add("PlayerInitialSpawn", "FullLoadSetup", function(ply)
  return hook.Add("SetupMove", ply, function(self, ply, _, cmd)
    if self ~= ply then
      return 
    end
    if not (cmd:IsForced()) then
      return 
    end
    hook.Run("PlayerFullLoad", self)
    return hook.Remove("SetupMove", self)
  end)
end)

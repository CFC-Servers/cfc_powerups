hook.Add "PlayerInitialSpawn","FullLoadSetup", (ply) ->
    hook.Add "SetupMove", ply, (self, ply, _,cmd)
        return if self ~= ply
        return unless cmd\IsForced!

        hook.Run "PlayerFullLoad", self
        hook.Remove "SetupMove", self

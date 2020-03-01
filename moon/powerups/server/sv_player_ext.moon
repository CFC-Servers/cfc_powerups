playerMeta = FindMetaTable "Player"

playerMeta.AddPowerup = (powerup) =>
    @Powerups.insert powerup

playerMeta.RemovePowerup = (name) =>
    for key, powerup in pairs @Powerups
        if powerup\Name == name
            powerup.RemovePowerup!
            table.remove @Powerups, key

playerMeta.GetPowerup = (name) =>
    for powerup in *@Powerups
        if powerup\Name == name
            return powerup

playerMeta.HasPowerup = (name) =>
    @GetPowerup name ~= nil

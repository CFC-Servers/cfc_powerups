export BasePowerup
class BasePowerup
    ID: "base-cfc-powerup"
    RemoveOnDeath: true
    RequiresPvp: true
    IsRefreshable: true

    new: (ply) =>
        @owner = ply
        @ApplyEffect!

    ApplyEffect: =>
        @owner\ChatPrint "Powerup Get!"
        @owner\Kill!

    Refresh: =>
        @owner\ChatPrint "Powerup Refreshed!"
        @owner\Kill!

    Remove: =>
        @owner\ChatPrint "Powerup Removed!"
        @owner\Kill!

CFCPowerups[BasePowerup.ID] = BasePowerup

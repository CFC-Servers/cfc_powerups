{get: getConf} = CFCPowerups.Config

export TemplatePowerup
class TemplatePowerup extends BasePowerup
    @powerupID: "powerup_template"
    
    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

    -- These default to true, so you can omit them unless you need them to be false
    @RemoveOnDeath = true
    @RequiresPvp = true
    @IsRefreshable = true

    new: (ply) =>
        super ply

        @ApplyEffect!

    ApplyEffect: =>
        super self
        -- What happens when they pick up the powerup

    Refresh: =>
        super self
        -- What happens when they pick up the powerup while already having it

    Remove: =>
        super self
        -- What happens when the powerup is removed

        -- TODO: Should the PowerupManager do this?
        @owner.Powerups[@@powerupID] = nil

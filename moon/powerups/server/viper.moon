include "base.lua"

DEFAULT_PLAYER_COLOR = Color 255, 255, 255, 255
PLAYER_COLOR         = Color 255, 255, 255, 1
PLAYER_MATERIAL      = ""
POWERUP_DURATION     = 300 -- In Seconds

MELEE_DAMAGE_MULT   = 3 -- Valid melee damage is multiplied by this value

MELEE_WEAPONS       = {
    "m9k_knife": true,
    "m9k_damascus": true,
    "m9k_machete": true,
    "m9k_thrown_knife": true,
    "m9k_harpoon": true,
    "m9k_fists": true,
    "cw_ws_pamachete": true,
    "weapon_fists": true,
    "weapon_crowbar": true,
    "weapon_stunstick": true
}

export ViperPowerup
class ViperPowerup extends BasePowerup
    @powerupID: "powerup_viper"

    @powerupWeights: {1, 1, 1, 1}

    new: (ply) =>
        super ply

        @timerName = "CFC_Powerups_Viper-#{@owner\SteamID64!}"
        @hookName = @timerName

        @ApplyEffect!

    CreateDamageWatcher: =>
        (recipient, dmg) ->
            if not IsValid(recipient) and recipient\IsPlayer! return

            attacker = dmg\GetAttacker!

            if not IsValid(attacker) and attacker\IsPlayer! return
            if attacker ~= @owner return

            attackerWeapon = attacker\GetActiveWeapon!

            if not IsValid(attackerWeapon) return

            if not MELEE_WEAPONS[attackerWeapon] return

            dmg\ScaleDamage MELEE_DAMAGE_MULT

    ApplyEffect: =>
        @owner\SetColor PLAYER_COLOR

        timer.Create @timerName, POWERUP_DURATION, 1, -> @Remove!

        watcher = @CreateDamageWatcher!
        hook.Create "EntityTakeDamage", @hookName, watcher

    Refresh: =>
        timer.Start @timerName

    Remove: =>
        timer.Remove @timerName
        hook.Remove "EntityTakeDamage", @hookName

        if not IsValid(@owner) return
        @owner\SetColor DEFAULT_PLAYER_COLOR

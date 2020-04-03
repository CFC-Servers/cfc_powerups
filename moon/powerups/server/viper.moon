{get: getConf} = CFCPowerups.Config

DEFAULT_PLAYER_COLOR = Color 255, 255, 255, 255
PLAYER_COLOR         = Color 255, 255, 255, 1
PLAYER_MATERIAL      = ""

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

    @powerupWeights:
        tier1: 1
        tier2: 1
        tier3: 1
        tier4: 1

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
            return unless attacker == @owner

            attackerWeapon = attacker\GetActiveWeapon!

            return unless IsValid attackerWeapon

            return unless MELEE_WEAPONS[attackerWeapon]

            multiplier = getConf "viper_multiplier"
            dmg\ScaleDamage multiplier

    ApplyEffect: =>
        @owner\SetColor PLAYER_COLOR

        duration = getConf "viper_duration"
        timer.Create @timerName, duration, 1, @Remove

        watcher = @CreateDamageWatcher!
        hook.Add "EntityTakeDamage", @hookName, watcher

    Refresh: =>
        timer.Start @timerName

    Remove: =>
        timer.Remove @timerName
        hook.Remove "EntityTakeDamage", @hookName

        if not IsValid(@owner) return
        @owner\SetColor DEFAULT_PLAYER_COLOR

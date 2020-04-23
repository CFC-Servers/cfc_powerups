get: getConf = CFCPowerups.Config

import Logger from CFCPowerups

MELEE_WEAPONS =
    "m9k_knife": true
    "m9k_damascus": true
    "m9k_machete": true
    "m9k_thrown_knife": true
    "m9k_harpoon": true
    "m9k_fists": true
    "cw_ws_pamachete": true
    "weapon_fists": true
    "weapon_crowbar": true
    "weapon_stunstick": true
    "cw_extrema_ratio_official": true

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
            return unless IsValid(recipient) and recipient\IsPlayer!

            attacker = dmg\GetAttacker!

            return unless IsValid(attacker) and attacker\IsPlayer!
            return unless attacker == @owner

            attackerWeapon = attacker\GetActiveWeapon!

            return unless IsValid attackerWeapon

            attackerWeapon = attackerWeapon\GetClass!

            return unless MELEE_WEAPONS[attackerWeapon]

            multiplier = getConf "viper_multiplier"
            Logger\info "Scaling damage by: #{multiplier}"
            dmg\ScaleDamage multiplier

    ApplyEffect: =>
        viperMaterial = getConf "viper_material"

        with @owner
            \SetMaterial viperMaterial
            \DrawShadow false

        wep\SetMaterial viperMaterial for wep in *@owner\GetWeapons!

        duration = getConf "viper_duration"
        timer.Create @timerName, duration, 1, -> @Remove!

        watcher = @CreateDamageWatcher!
        hook.Add "EntityTakeDamage", @hookName, watcher

        @owner\ChatPrint "You've gained the Viper Powerup"

    Refresh: =>
        timer.Start @timerName
        @owner\ChatPrint "You've refreshed the duration of the Viper Powerup"

    Remove: =>
        timer.Remove @timerName
        hook.Remove "EntityTakeDamage", @hookName

        return unless IsValid @owner

        with @owner
            \SetMaterial ""
            \GetActiveWeapon\SetMaterial ""
            \DrawShadow true
            \ChatPrint "You've lost the Viper Powerup"

        wep\SetMaterial "" for wep in *@owner\GetWeapons!

        @owner.Powerups[@@powerupID] = nil

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
    "tfa_l4d2mw_bat": true
    "tfa_l4d2mw_baton": true
    "tfa_l4d2mw_crowbar": true
    "tfa_l4d2mw_etool": true
    "tfa_l4d2mw_fireaxe": true
    "tfa_l4d2mw_golfclub": true
    "tfa_l4d2mw_katana": true
    "tfa_l4d2mw_knife": true
    "tfa_l4d2mw_machete": true
    "tfa_l4d2mw_metalbat": true
    "tfa_l4d2mw_pitchfork": true
    "tfa_l4d2mw_shovel": true
    --"tfa_l4d2mw_riotshield": true -- riot shield is stinky and lame
    "tfa_l4d2mw_sledgehammer": true
    "cfc_slappers": true
    "cfc_super_slappers": true

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

    CreateWeaponChangeWatcher: =>
        viperMaterial = getConf "viper_material"

        (ply, oldWeapon, newWeapon) ->
            return unless IsValid newWeapon
            return unless ply == @owner

            newClass = newWeapon\GetClass!

            if MELEE_WEAPONS[newClass]
                with @owner
                    \SetMaterialForced viperMaterial
                    \DrawShadow false

                newWeapon\SetMaterial viperMaterial
            else
                with @owner
                    \SetMaterialForced ""
                    \DrawShadow true

                return unless IsValid oldWeapon

                oldWeapon\SetMaterial ""

    ApplyEffect: =>
        super self
        duration = getConf "viper_duration"
        timer.Create @timerName, duration, 1, -> @Remove!

        damageWatcher = @CreateDamageWatcher!
        hook.Add "EntityTakeDamage", @hookName, damageWatcher

        weaponChangeWatcher = @CreateWeaponChangeWatcher!
        hook.Add "PlayerSwitchWeapon", @hookName, weaponChangeWatcher

        @owner\ChatPrint "You've gained the Viper Powerup"

    Refresh: =>
        super self
        timer.Start @timerName

        @owner\ChatPrint "You've refreshed the duration of the Viper Powerup"

    Remove: =>
        super self
        timer.Remove @timerName
        hook.Remove "EntityTakeDamage", @hookName
        hook.Remove "PlayerSwitchWeapon", @hookName

        return unless IsValid @owner

        with @owner
            \SetMaterialForced ""
            \DrawShadow true
            \ChatPrint "You've lost the Viper Powerup"

        wep\SetMaterial "" for wep in *@owner\GetWeapons!

        @owner.Powerups[@@powerupID] = nil

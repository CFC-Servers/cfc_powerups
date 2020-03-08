include "base.lua"

POWERUP_ID = "juggernaut-powerup"
ARMOR_REFRESH_DELAY: 1
STARTING_HEALTH: 1000
ARMOR_AMOUNT: 100
WEAPON_CLASS: "m9k_minigun"
POWERUP_DURATION: 200

-- minigun + 1000 HP and 100 armor (armor resets to 100 if you take any damage every 1 second.)
export JuggernautPowerup
class JuggernautPowerup extends BasePowerup
    new: (ply) =>
        super ply

        ply\SetHealth(STARTING_HEALTH)
        ply\SetArmor(ARMOR_AMOUNT)
        ply\Give( WEAPON_CLASS, true )

        @timerName = "CFC_Powerups-Juggernaut-#{ply\SteamID64!}"
        @hookName = "CFC_Powerups-Juggernaut-#{ply\SteamID64!}"
        @_isArmourRefreshing = false

        hook.Add "EntityTakeDamage", @hookName, ( target, dmginfo ) ->
            @onPlayerDamage! if target == ply

        timer.Simple POWERUP_DURATION, ->
            @Remove!

    onPlayerDamage: =>
        if @_isArmourRefreshing
            return

        @_isArmourRefreshing = true
        timer.Simple ARMOR_REFRESH_DELAY, ->
            @_isArmourRefreshing = false
            @owner\SetArmor(ARMOR_AMOUNT)

    Refresh: =>
        timer.Start @timerName

    Remove: =>
        timer.Remove @timerName
        @owner\SetHealth(100)
        @owner\SetArmor(0)
        hook.Remove "EntityTakeDamage", @hookName

CFCPowerups[POWERUP_ID] = JuggernautPowerup


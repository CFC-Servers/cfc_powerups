{
-- Powerups ==============================================================
"cfc_powerups_spawn_delay":
    default: 60 * 60
    helpText: "How often the powerups spawn in random locations"
    min: 1

"cfc_powerups_spawn_sound":
    default: "ambient/machines/teleport4.wav"
    helpText: "The sound that each powerup makes when it spawns on the map"
-- =======================================================================

-- Cluster Combine Ball ==================================================
"cfc_powerups_cball_cluster_delay":
    default: 0.3
    helpText: "How long after a combine ball is fired that it will cluster"
    min: 0.01

"cfc_powerups_cball_balls_per_cluster":
    default: 15
    helpText: "How many balls per cluster"

"cfc_powerups_cball_uses":
    default: 3
    helpText: "How many uses of the Cluster Combine Ball powerup"

"cfc_powerups_cball_speed":
    default: 1500
    helpText: "How fast the Cluster Balls fly"

"cfc_powerups_cball_bounces":
    default: 8
    helpText: "How many bounces until clustered combine balls explode"
-- =======================================================================

-- Regen =================================================================
"cfc_powerups_regen_max_hp":
    default: 150
    helpText: "What is the maximum HP that the regen powerup will regen to"

"cfc_powerups_regen_duration":
    default: 300
    helpText: "How long does the regen powerup last"

"cfc_powerups_regen_interval":
    default: 0.1
    helpText: "How often to apply the regen powerup's regeneration"
    min: 0.01

"cfc_powerups_regen_amount":
    default: 3
    helpText: "How much health to regenerate every interval"

"cfc_powerups_regen_sound":
    default: "items/medcharge4.wav"
    helpText: "What sound to play when health is regenerated"
-- =======================================================================

-- Viper =================================================================
"cfc_powerups_viper_duration":
    default: 300
    helpText: "How long does the Viper powerup last, in seconds"

"cfc_powerups_viper_multiplier":
    default: 3
    helpText: "What value to multiply melee damage by for the Viper powerup"

"cfc_powerups_viper_material":
    default: "models/shadertest/predator"
    helpText: "What material to set the player and their weapons to"
-- =======================================================================

-- Speed =================================================================
"cfc_powerups_speed_duration":
    default: 600
    helpText: "How long does the Speed powerup last, in seconds"

"cfc_powerups_speed_multiplier":
    default: 2.25
    helpText: "What value to multiply speed by for the Speed powerup"
-- =======================================================================

-- Feather ===============================================================
"cfc_powerups_feather_duration":
    default: 600
    helpText: "How long does the Feather powerup last, in seconds"

"cfc_powerups_feather_gravity_multiplier":
    default: 0.75
    helpText: "What value to multiply gravity by for the Feather powerup"
-- =======================================================================

-- Hotshot ===============================================================
"cfc_powerups_hotshot_duration":
    default: 600
    helpText: "How long does the Hotshot powerup last, in seconds"

"cfc_powerups_hotshot_ignite_duration":
    default: 5
    helpText: "How many seconds to ignite targets for"

"cfc_powerups_hotshot_ignite_multiplier":
    default: 0.25
    helpText: "Cumulative ignite damage is calculated by multiplying the damage amount by this number"

"cfc_powerups_hotshot_explosion_ignite_duration":
    default: 10
    helpText: "The ignite duration for the on-death explosion of players affected by Hotshot"

"cfc_powerups_hotshot_explosion_base_radius":
    default: 50
    helpText: "What distance (in units) from the on-death explosion will entites be ignited by default"

"cfc_powerups_hotshot_explosion_max_radius":
    default: 2000
    helpText: "What distance (in units) from the on-death explosion, after being scaled by damage, will entities be ignited"

"cfc_powerups_hotshot_explosion_sound":
    default: "ambient/fire/gascan_ignite1.wav"
    helpText: "What sound to play for the on-death explosion"

"cfc_powerups_hotshot_explosion_sound_level":
    default: 180
    helpText: "How loud and how far the on-death explosion can be heard. (Range: 20 - 180)"
-- =======================================================================

-- Ammo ==================================================================
"cfc_powerups_ammo_duration":
    default: 600
    helpText: "How long does the Ammo powerup last, in seconds"

"cfc_powerups_ammo_refresh_interval":
    default: 0.25
    helpText: "How long to wait between each ammo refresh, in seconds"

"cfc_powerups_ammo_secondary_refresh_amount":
    default: 1
    helpText: "How much secondary ammo to give the player each refresh interval"
-- =======================================================================
}

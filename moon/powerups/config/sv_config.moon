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
-- =======================================================================
}

{
-- Powerups ==============================================================
"cfc_powerups_spawn_delay":
    --default: 60 * 60
    default: 45
    helpText: "How often the powerups spawn in random locations"
    min: 1

"cfc_powerups_spawn_sound":
    default: "ambient/machines/teleport4.wav"
    helpText: "The sound that each powerup makes when it spawns on the map"

"cfc_powerups_spawn_height":
    default: 0
    helpText: "The height offset to add to a powerup spawn position"
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

"cfc_powerups_speed_interval":
    default: 1
    helpText: "How often to check if the Speed powerup needs to be re-applied"
    min: 0.01

"cfc_powerups_speed_multiplier":
    default: 1.5
    helpText: "What value to multiply speed by for the Speed powerup"
-- =======================================================================

-- Super Speed =================================================================
"cfc_powerups_super_speed_duration":
    default: 600
    helpText: "How long does the Super Speed powerup last, in seconds"

"cfc_powerups_super_speed_interval":
    default: 1
    helpText: "How often to check if the Super Speed powerup needs to be re-applied"
    min: 0.01

"cfc_powerups_super_speed_multiplier":
    default: 2.25
    helpText: "What value to multiply speed by for the Super Speed powerup"
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

"cfc_powerups_hotshot_explosion_base_radius":
    default: 20
    helpText: "What distance (in units) from the on-death explosion will entites be ignited by default"

"cfc_powerups_hotshot_explosion_max_radius":
    default: 750
    helpText: "What distance (in units) from the on-death explosion, after being scaled by damage, will entities be ignited"

"cfc_powerups_hotshot_explosion_base_damage":
    default: 5
    helpText: "How much damage to apply to nearby entities when a Hotshot victim explodes"

"cfc_powerups_hotshot_explosion_max_damage":
    default: 100
    helpText: "What is the maximum damage a Hotshot explosion can deal"

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

"cfc_powerups_ammo_secondary_min":
    default: 10
    helpText: "How much secondary ammo to give the player each refresh interval"
-- =======================================================================

-- Grenadier =============================================================
"cfc_powerups_grenadier_uses":
    default: 5
    helpText: "How many uses of the Grenadier powerup is given"

"cfc_powerups_grenadier_alt_fire_delay":
    default: 0.2
    helpText: "How long to wait before each smg alt-fire"

"cfc_powerups_grenadier_cluster_min_distance":
    default: 5
    helpText: "What is the minimum distance the clustered grenades can spread"

"cfc_powerups_grenadier_cluster_max_distance":
    default: 300
    helpText: "What is the maximum distance the clustered grenades can spread"

"cfc_powerups_grenadier_cluster_min_height":
    default: 15
    helpText: "What is the minimum height the clustered grenades can spread"

"cfc_powerups_grenadier_cluster_max_height":
    default: 60
    helpText: "What is the maximum height the clustered grenades can spread"

"cfc_powerups_grenadier_cluster_delay":
    default: 0.2
    helpText: "How long after the parent grenade explodes will the clusters shoot"

"cfc_powerups_grenadier_cluster_count":
    default: 25
    helpText: "How many clusters to create"

"cfc_powerups_grenadier_cluster_impact_sound":
    default: "ambient/machines/thumper_hit.wav"
    helpText: "What sound to make when the parent grenade explodes"
-- =======================================================================

-- Flux Shield ===========================================================
"cfc_powerups_flux_shield_duration":
    default: 120
    helpText: "How long does the Flux Shield powerup last, in seconds"

"cfc_powerups_flux_shield_max_reduction":
    default: 50
    helpText: "What is the maximum percentage of damage Flux Shield can reduce"

"cfc_powerups_flux_shield_tick_interval":
    default: 1
    helpText: "How often should Flus Shield adjust the damage reduction value, in seconds"

"cfc_powerups_flux_shield_active_sound_level":
    default: 130
    helpText: "What sound level should the Flux Shield use for its active playing sound? (Look into GLua sound levels)"
-- =======================================================================

-- Thorns ================================================================
"cfc_powerups_thorns_duration":
    default: 600
    helpText: "How long does the Thorns powerup last, in seconds"

"cfc_powerups_thorns_return_percentage":
    default: 25
    helpText: "What percentage of damage should be returned to the attacker?"
-- =======================================================================

-- Magnetic Crossbow =====================================================
"cfc_powerups_magnetic_crossbow_uses":
    default: 10
    helpText: "How many uses of the Magnetic Crossbow powerup is given"

"cfc_powerups_magnetic_crossbow_speed_multiplier":
    default: 16
    helpText: "What value to multiply crossbow bolt speed by for the Magnetic Crossbow powerup"

"cfc_powerups_magnetic_crossbow_cone_range":
    default: 300
    helpText: "What range to use when finding targets in a cone (read the wiki for more info)"

"cfc_powerups_magnetic_crossbow_cone_arc":
    default: 20
    helpText: "What arc degree to use when calculating targeting cone"

"cfc_powerups_magnetic_crossbow_effect_linger_time":
    default: 10
    helpText: "How long should the effects relating to the Magnetic Crossbow powerup last?"

"cfc_powerups_magnetic_crossbow_magnet_sound":
    default: "ambient/machines/fluorescent_hum_1.wav"
    helpText: "What sound should play when the bolt acquires a target?"
-- =======================================================================

-- Groundpound ===============================================================
"cfc_powerups_groundpound_uses":
    default: 10
    helpText: "How many uses of the Groundpound powerup is given"

"cfc_powerups_groundpound_acceleration":
    default: 600
    helpText: "Added hmu/s^2 Groundpound acceleration to the player"

"cfc_powerups_groundpound_min_speed":
    default: 600
    helpText: "The minimum falling speed needed for Groundpound shockwaves"

"cfc_powerups_groundpound_base_damage":
    default: 100
    helpText: "Base groundpound damage/radius"

"cfc_powerups_groundpound_added_damage":
    default: 0.25
    helpText: "Damage/radius added per speed player is above the min speed"

"cfc_powerups_groundpound_knockback_multiplier":
    default: 10
    helpText: "Knockback multiplier for Groundpound shockwaves, scales based on final damage"

"cfc_powerups_groundpound_knockback_max":
    default: 1500
    helpText: "Knockback maximum for Groundpound shockwaves"
-- =======================================================================

-- Shotgun ================================================================
"cfc_powerups_shotgun_duration":
    default: 300
    helpText: "How long does the Shotgun powerup last, in seconds"

"cfc_powerups_shotgun_single_bullets_min":
    default: 6
    helpText: "Minimum number of bullets for single-bullet weapons"

"cfc_powerups_shotgun_single_bullets_max":
    default: 8
    helpText: "Maximum number of bullets for single-bullet weapons"

"cfc_powerups_shotgun_single_damage_multiplier":
    default: 0.5
    helpText: "Damage multiplier for single-bullet weapons"

"cfc_powerups_shotgun_single_spread_multiplier":
    default: 1.25
    helpText: "Spread multiplier for single-bullet weapons"

"cfc_powerups_shotgun_single_spread_add":
    default: 0.04
    helpText: "Spread additive for single-bullet weapons"

"cfc_powerups_shotgun_multi_bullets_multiplier":
    default: 1.5
    helpText: "Multiplier against the number of bullets for multi-bullet weapons"

"cfc_powerups_shotgun_multi_damage_multiplier":
    default: 1.5
    helpText: "Damage multiplier for multi-bullet weapons"

-- Phoenix =============================================================
"cfc_powerups_phoenix_uses":
    default: 1
    helpText: "How many uses of the Phoenix powerup is given"

"cfc_powerups_phoenix_max_uses":
    default: 5
    helpText: "The maximum uses of the Phoenix powerup a player can hold"

"cfc_powerups_phoenix_revive_health":
    default: 100
    helpText: "What to set a Phoenix player's health to when they revive"

"cfc_powerups_phoenix_revive_armor":
    default: 0
    helpText: "What to set a Phoenix player's armor to when they revive"

"cfc_powerups_phoenix_immunity_duration":
    default: 5
    helpText: "How long a Phoenix player is immune for after being revived"

"cfc_powerups_phoenix_immunity_damage_multiplier":
    default: 1
    helpText: "While a Phoenix player is immune, multiply damage they deal by this much"
    min: 0
-- =======================================================================

-- Curse =============================================================
"cfc_powerups_curse_duration":
    default: 300
    helpText: "How long does the Curse powerup last, in seconds"

"cfc_powerups_curse_duration_min":
    default: 10
    helpText: "Minimum curse effect duration from the Curse powerup"

"cfc_powerups_curse_duration_max":
    default: 15
    helpText: "Maximum curse effect duration from the Curse powerup"

"cfc_powerups_curse_chance":
    default: 0.25
    helpText: "The chance to apply a curse, when a player shoots a Curse powerup user and has no curses"

"cfc_powerups_curse_ratelimit":
    default: 0.75
    helpText: "Cooldown for applying curses to attackers when they already have one"
-- =======================================================================
}

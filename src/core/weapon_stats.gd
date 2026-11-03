class_name WeaponStats
extends RefCounted

## Pure weapon configuration. Factories keep the slice data in one place.

var id := ""
var damage := 0
var shots_per_second := 1.0
var projectile_count := 1
var spread_degrees := 0.0
var bullet_speed := 600.0
var bullet_lifetime := 1.0
var terrain_radius := 8.0
var automatic := false
var recoil := 0.0


static func rifle() -> WeaponStats:
	var stats := WeaponStats.new()
	stats.id = "rifle"
	stats.damage = 10
	stats.shots_per_second = 8.0
	stats.projectile_count = 1
	stats.spread_degrees = 2.0
	stats.bullet_speed = 600.0
	stats.bullet_lifetime = 0.8
	stats.terrain_radius = 12.0
	stats.automatic = true
	stats.recoil = 20.0
	return stats


static func shotgun() -> WeaponStats:
	var stats := WeaponStats.new()
	stats.id = "shotgun"
	stats.damage = 6
	stats.shots_per_second = 1.5
	stats.projectile_count = 5
	stats.spread_degrees = 18.0
	stats.bullet_speed = 500.0
	stats.bullet_lifetime = 0.35
	stats.terrain_radius = 20.0
	stats.automatic = false
	stats.recoil = 60.0
	return stats

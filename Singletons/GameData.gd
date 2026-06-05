extends Node

var tower_data = {
	"GunT1": {
		"damage": 15,
		"reload": 1.5,
		"range": 300,
		"ammo": "Projectile",
		"cost": 50,
		"upgrade_cost": 100,
		"upgrade": "GunT2"},
	"GunT2": {
		"damage": 30,
		"reload": 0.8,
		"range": 400,
		"ammo": "Projectile",
		"cost": 100,
		"upgrade": "",},
	"MissileT1": {
		"damage": 100,
		"reload": 4,
		"range": 500,
		"ammo": "Missile",
		"cost": 150,
		"upgrade_cost": 200,
		"upgrade": "MissileT2",
		"missile_count": 1,},
	"MissileT2": {
		"damage": 100,
		"reload": 2,
		"range": 600,
		"ammo": "Missile",
		"cost": 300,
		"upgrade": "",
		"missile_count": 2,}
	}

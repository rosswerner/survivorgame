extends Node

const ICON_PATH = "res://assets/Icons/"
const UPGRADES = {
	"fireball" : {
		"icon": ICON_PATH + "fireball.png",
		"displayname": "Plasmaball",
		"desc": "A ball of plasma is launched towards the nearest enemy in range, hits, then explodes.",
		"prereqs": [],
		"type": "ranged"
	},
	"fireball_proj_1" : {
		"icon": ICON_PATH + "fireball.png",
		"displayname": "Additional Projectile",
		"desc": "An additional ball of plasma is launched.",
		"prereqs": ["fireball"],
		"type": "ranged"
	},
	"fireball_proj_2" : {
		"icon": ICON_PATH + "fireball.png",
		"displayname": "Additional Projectile",
		"desc": "An additional ball of plasma is launched.",
		"prereqs": ["fireball", "fireball_proj_1"],
		"type": "ranged"
	},
}

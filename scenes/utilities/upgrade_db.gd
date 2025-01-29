extends Node

const ICON_PATH = "res://assets/Icons/"
const UPGRADES = {
	"default" : {
		"icon": ICON_PATH + "ranged.png",
		"displayname": "Woops",
		"desc": "Lorem ipsum whatever test.",
		"prereqs": [],
		"type": "utility"
	},
	"fireball" : {
		"icon": ICON_PATH + "ranged.png",
		"displayname": "Plasmaball",
		"desc": "A ball of plasma is launched towards the nearest enemy in range, hits, then explodes.",
		"prereqs": [],
		"type": "ranged"
	},
	"fireball_proj_1" : {
		"icon": ICON_PATH + "ranged.png",
		"displayname": "Additional Projectile",
		"desc": "An additional ball of plasma is launched.",
		"prereqs": ["fireball"],
		"type": "ranged"
	},
	"fireball_proj_2" : {
		"icon": ICON_PATH + "ranged.png",
		"displayname": "Additional Projectile",
		"desc": "An additional ball of plasma is launched.",
		"prereqs": ["fireball_proj_1"],
		"type": "ranged"
	},
	"sound_wave" : {
		"icon": ICON_PATH + "aoe.png",
		"displayname": "Sound Wave",
		"desc": "Area of pulsing sound waves dealing damage in a small area around the player",
		"prereqs": [],
		"type": "aoe"
	},
	"arrow" : {
		"icon": ICON_PATH + "ranged.png",
		"displayname": "Bolt",
		"desc": "A quick bolt is launched at a nearby enemy.",
		"prereqs": [],
		"type": "ranged"
	}
}

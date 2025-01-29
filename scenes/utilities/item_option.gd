extends ColorRect

var mouse_over = false
var item = null

@onready var player := get_tree().get_first_node_in_group("Player")
@onready var lbl_name := $lbl_name
@onready var lbl_desc := $lbl_desc
@onready var itemIcon := $ColorRect/ItemIcon

signal selected_upgrade(upgrade)

func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	if(item == null):
		item = "default"
	lbl_name.text = UpgradeDb.UPGRADES[item]["displayname"]
	lbl_desc.text = UpgradeDb.UPGRADES[item]["desc"]
	itemIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])
	
func _input(event: InputEvent) -> void:
	if(event.is_action("Left_Click")):
		if(mouse_over):
			emit_signal("selected_upgrade", item)
	
func _on_mouse_entered():
	mouse_over = true
	
func _on_mouse_exited():
	mouse_over = false

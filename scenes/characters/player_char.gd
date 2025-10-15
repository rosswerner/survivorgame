extends CharacterBody2D

#@export var starting_direction : Vector2 = Vector2(0,1)
##Skills
var ls_active := false
var ls_pos := Vector2.ZERO
var ls_slash_active := false
var ls_spin_active := false
var ls_cd := 1.0
var ls_move_speed := 50
var plasmaball_active := false
var plasmaball_proj := 1
var plasmaball_spread := 10
var rf_active := false
var rf_scale := 1.0
var arrow_active := false
var arrow_cd := 1.0
var arrow_proj := 1


var ls_tmp : Node2D
var last_velocity := Vector2.ZERO
var click_position := Vector2()
var target_position := Vector2()
var mouse_position := Vector2()
var pos_dist : float = 0.0
var plasmaball_last_time : int = 0
var arrow_last_time : int = 0
var ls_spin_last_time : int = 0
var dead := false
var enemies_in_range := []
var rf_on := false
var ls_on := false
var xp := 0.0
var level := 1

##UPGRADES
var collected_upgrades = []
var upgrade_options = []
var dmg_resistance = 0.0
@export var move_speed : float = 100 #TODO remove export - in for ez testing
@export var attack_speed : float = 1000 #TODO remove export - in for ez testing
@export var cast_speed : float = 1000 #TODO remove export - in for ez testing
var tempo_speed := 0.0

#@export var attack_velocity : Vector2
@onready var lightsaber := preload("res://scenes/skills/lightsaber.tscn")
@onready var plasmaball := preload("res://scenes/skills/plasmaball.tscn")
@onready var arrow := preload("res://scenes/skills/arrow.tscn")
@onready var rf := preload("res://scenes/skills/righteous_fire.tscn")
@onready var health_bar := get_node("HUD/HealthBar")
@onready var xp_bar := get_node("HUD/XPBar")
@onready var tot_hp : float = 1000
@onready var cur_hp := tot_hp
@onready var hitbox := $Hitbox
@onready var level_panel := get_node("%LevelUp")
@onready var upgrade_options_UI := get_node("%UpgradeOptions")
#@onready var sndLevelUp := get_node("%LevelingSound")
@onready var item_options := preload("res://scenes/utilities/item_option.tscn")

func _ready():
	click_position = position
	health_bar.max_value = tot_hp
	health_bar.value = cur_hp
	
	xp_bar.max_value = (1.349 * 1.191 ** level + 10)
	xp_bar.value = xp
	#animation_tree.set("parameters/Idle/blend_position", starting_direction)
	
func _physics_process(_delta):
	if(!dead):
		mouse_position = get_global_mouse_position()
		if Input.is_action_pressed("Left_Click"):
			click_position = mouse_position
		#if Input.is_action_pressed("Skill1"):
		
		##Use skills##
		target_position = get_closest_enemy()
		use_skills(_delta)
			
		pos_dist = position.distance_to(click_position)	
		if pos_dist > 4:
			target_position = (click_position - position).normalized()
			var vel := position.direction_to(click_position) * move_speed
			velocity = vel
			last_velocity = velocity
			move_and_slide()
		else:
			pos_dist = 0
			velocity = Vector2(0,0)
			move_and_slide()
		
func use_skills(delta) -> void:
	if(ls_active) :
		lightsaber_skill(delta)
	if(plasmaball_active) :
		plasmaball_skill()
	if(rf_active) :
		rf_skill()
	if(arrow_active) :
		arrow_skill()
		
func hit(damage: float) -> void:
	if(cur_hp > 0):
		cur_hp -= damage
		health_bar.value = cur_hp
		
		if(!health_bar.visible):
			health_bar.visible = true
	if(cur_hp <= 0):
		die()
		
func die() -> void:
	dead = true
	#state_machine.travel("Death")
	hitbox.set_deferred("disabled", true)
	#animation_tree.set("parameters/death/blend_position", velocity)
	velocity = Vector2.ZERO
	health_bar.visible = false
	
func lightsaber_skill(delta: float) -> void:
	var player_pos = global_position
	var target_pos = target_position

	if target_pos == Vector2.ZERO:
		target_pos = get_global_mouse_position()

	# Instantiate if not already
	if not ls_tmp or not ls_tmp.is_inside_tree():
		ls_tmp = lightsaber.instantiate()
		ls_tmp.speed = ls_move_speed * delta
		ls_tmp.global_position = player_pos
		ls_tmp.rotation = (target_pos - player_pos).angle()
		get_tree().current_scene.get_node("Actors").add_child(ls_tmp)
		ls_on = true
		return

	var saber_pos = ls_tmp.global_position

	if saber_pos.distance_to(player_pos) > 125.0 or enemies_in_range.is_empty():
		var move_dir = (player_pos - saber_pos).normalized()
		ls_tmp.global_position += move_dir * ls_move_speed * delta
		ls_tmp.rotation = move_dir.angle()
	else:
		var move_dir = (target_pos - saber_pos).normalized()
		ls_tmp.global_position += move_dir * ls_move_speed * delta
		ls_tmp.rotation = move_dir.angle()
		
	if ls_slash_active:
		# TODO: slash
		pass
	if ls_spin_active:
		if(Time.get_ticks_msec() - ls_spin_last_time >= ls_tmp.spin_delay_time * ls_cd):
			ls_spin_last_time = Time.get_ticks_msec()
			var tween = create_tween()
			tween.tween_property(ls_tmp, "rotation", ls_tmp.rotation + 2 * TAU, .25).from_current()  # rotate 360° over 1 second

func rf_skill() -> void:
	if(!rf_on):
		var rf_tmp := rf.instantiate()
		rf_tmp.scale *= rf_scale
		rf_on = true
		rf_tmp.position = global_position.normalized()
		add_child(rf_tmp)
		
func arrow_skill() -> void:
	if(target_position != Vector2.ZERO):
		var arrow_tmp := arrow.instantiate()
		if(Time.get_ticks_msec() - arrow_last_time >= arrow_tmp.delay_time * arrow_cd):
			arrow_last_time = Time.get_ticks_msec()
			var shoot_target := (target_position - global_position).normalized() #(mouse_position - global_position).normalized()
			arrow_tmp.position = global_position
			arrow_tmp.rotation = position.direction_to(target_position).angle()
			arrow_tmp.direction = shoot_target
			#this is to make the proj not be affected by the player's movements
			get_tree().get_root().add_child(arrow_tmp)
		
func plasmaball_skill() -> void:
	if(target_position != Vector2.ZERO):
		var plasmaball_tmp := plasmaball.instantiate()
		if(Time.get_ticks_msec() - plasmaball_last_time >= plasmaball_tmp.delay_time):
			for i in range(plasmaball_proj):
				plasmaball_last_time = Time.get_ticks_msec()
				var direction = position.direction_to(target_position)
				#Volley code
				#var offset = Vector2(-direction.y, direction.x) * 10 * ((i % 2) * 2 - 1) * ((i + 1) / 2)
				#plasmaball_tmp.position = global_position + offset
				var angle_offset = plasmaball_spread * ((i - (plasmaball_proj - 1) / 2.0) / (plasmaball_proj / 2.0))
				var rotated_direction = direction.rotated(deg_to_rad(angle_offset))  # Rotate by spread amount
				
				plasmaball_tmp.position = global_position
				plasmaball_tmp.rotation = direction.angle()
				plasmaball_tmp.direction = rotated_direction
				
				#this is to make the proj not be affected by the player's movements
				get_tree().get_root().add_child(plasmaball_tmp)
				plasmaball_tmp = plasmaball.instantiate()
		
func get_closest_enemy() -> Vector2:
	var closest_distance := 0.0 
	var enemy_distance := 0.0
	var target := mouse_position
	if(!enemies_in_range.is_empty()):
		for body in enemies_in_range :
			enemy_distance = position.distance_to(body.global_position)
			if(closest_distance == 0.0 || enemy_distance < closest_distance):
				closest_distance = enemy_distance
				target = body.global_position
	return target
	
func calculate_xp() -> void:
	if (xp >= (1.349 * 1.191 ** level) + 10):
		level_up()
	
	xp_bar.value = xp
	
func level_up() -> void:
	xp = xp - (1.349 * 1.191 ** level + 10)
	level += 1
	xp_bar.max_value = (1.349 * 1.191 ** level + 10)
	
	level_panel.visible = true
	var options = 0
	while(options < 3):
		var item_options_tmp = item_options.instantiate()
		item_options_tmp.item = get_random_upgrades()
		upgrade_options_UI.add_child(item_options_tmp)
		options += 1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	match upgrade:
		"plasmaball":
			plasmaball_active = true
		"plasmaball_proj_1", "plasmaball_proj_2":
			plasmaball_proj += 1
		"sound_wave":
			rf_active = true
		"sound_wave_aoe":
			rf_scale *= 1.3
		"arrow":
			arrow_active = true
		"arrow_cd":
			arrow_cd *= .5
		"melee":
			ls_active = true
		"melee_spin":
			ls_spin_active = true
			
	var option_children = upgrade_options_UI.get_children()
	for options in option_children:
		options.queue_free()
	upgrade_options.clear()
	
	collected_upgrades.append(upgrade)
	
	level_panel.visible = false
	get_tree().paused = false
	
	calculate_xp()
	
func get_random_upgrades():
	#TODO maybe add weighting for upgrades and/or reqs like 1 spell, 1 support, 3rd random, etc
	var db_list = []
	for upgrade in UpgradeDb.UPGRADES:
		if(upgrade in collected_upgrades or upgrade in upgrade_options):
			pass
		elif(UpgradeDb.UPGRADES[upgrade]["prereqs"].size() > 0):
			for prereqs in UpgradeDb.UPGRADES[upgrade]["prereqs"]:
				if(prereqs in collected_upgrades):
					db_list.append(upgrade)
		else:
			db_list.append(upgrade)
			
	if(db_list.size() > 0):
		var upgrade = db_list.pick_random()
		upgrade_options.append(upgrade)
		return upgrade
	return null

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "death"):
		queue_free()

func _on_enemy_detector_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Monster") and !(cur_hp <=0)):
		enemies_in_range.append(body)

func _on_enemy_detector_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Monster")):
		enemies_in_range.erase(body)

func _on_loot_reel_area_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_pickup_detector_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Pickups")):
		area.target = self

func _on_pickup_collector_area_entered(area: Area2D) -> void:
	if(area.is_in_group("Pickups")):
		xp += area.collect()
		calculate_xp()

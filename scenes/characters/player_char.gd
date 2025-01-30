extends CharacterBody2D

#@export var starting_direction : Vector2 = Vector2(0,1)
##Skills
var basic_active := true
var fireball_active := true
var fireball_proj := 3
var rf_active := false
var rf_scale := 1.0
var arrow_active := false
var arrow_proj := 1

var last_velocity := Vector2.ZERO
var click_position := Vector2()
var target_position := Vector2()
var mouse_position := Vector2()
var pos_dist : float = 0.0
var fireball_last_time : int = 0
var arrow_last_time : int = 0
var dead := false
var enemies_in_range := []
var rf_on := false
var xp := 0
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
@onready var fireball := preload("res://scenes/skills/fireball.tscn")
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
		use_skills()
			
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
		
		#if(!dead):
			
		#if last_velocity.x < 0:
			#$Sprite2D.flip_h = true
		#else:
			#$Sprite2D.flip_h = false
		
		#print("position = " + str(position))
		#print("mposition = " + str(click_position))
		#print("velocity = " + str(velocity))
		#print("posdist = " + str(pos_dist))
		
func use_skills() -> void:
	if(basic_active) :
		basic_skill()
	if(fireball_active) :
		fireball_skill()
	if(rf_active) :
		rf_skill()
	if(arrow_active) :
		arrow_skill()
		
func hit(damage: float) -> void:
	if(cur_hp > 0):
		cur_hp -= damage
		health_bar.value = cur_hp
		#damage_bar_timer.start(damage_bar_delay)
		#current_state = Swordsman_State.AGGRO
		
		if(!health_bar.visible):
			health_bar.visible = true
			#damage_bar.visible = true
	if(cur_hp <= 0):# and current_state != Swordsman_State.DEATH):
		die()
		
func die() -> void:
	dead = true
	#state_machine.travel("Death")
	hitbox.set_deferred("disabled", true)
	#animation_tree.set("parameters/death/blend_position", velocity)
	velocity = Vector2.ZERO
	health_bar.visible = false
	#damage_bar.visible = false
	
func basic_skill() -> void:
	pass
	
func rf_skill() -> void:
	if(!rf_on):
		var rf_tmp := rf.instantiate()
		rf_on = true
		rf_tmp.position = global_position.normalized()
		add_child(rf_tmp)
		
func arrow_skill() -> void:
	if(target_position != Vector2.ZERO):
		var arrow_tmp := arrow.instantiate()
		if(Time.get_ticks_msec() - arrow_last_time >= arrow_tmp.delay_time):
			arrow_last_time = Time.get_ticks_msec()
			var shoot_target := (target_position - global_position).normalized() #(mouse_position - global_position).normalized()
			arrow_tmp.position = global_position
			arrow_tmp.rotation = position.direction_to(target_position).angle()
			arrow_tmp.direction = shoot_target
			#this is to make the proj not be affected by the player's movements
			get_tree().get_root().add_child(arrow_tmp)
		
func fireball_skill() -> void:
	if(target_position != Vector2.ZERO):
		var fireball_tmp := fireball.instantiate()
		if(Time.get_ticks_msec() - fireball_last_time >= fireball_tmp.delay_time):
			for i in range(fireball_proj):
				fireball_last_time = Time.get_ticks_msec()
				var shoot_target := (target_position - global_position).normalized() #(mouse_position - global_position).normalized()
				var direction = position.direction_to(target_position)
				var offset = Vector2(-direction.y, direction.x) * 10 * ((i % 2) * 2 - 1) * ((i + 1) / 2)
				fireball_tmp.position = global_position + offset
				fireball_tmp.rotation = direction.angle()
				fireball_tmp.direction = shoot_target
				#this is to make the proj not be affected by the player's movements
				get_tree().get_root().add_child(fireball_tmp)
				fireball_tmp = fireball.instantiate()
		
func get_closest_enemy() -> Vector2:
	var closest_distance := 0.0 
	var enemy_distance := 0.0
	var target := Vector2.ZERO
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
		"fireball":
			fireball_active = true
		"fireball_proj_1", "fireball_proj_2":
			fireball_proj += 1
		"sound_wave":
			rf_active = true
		"arrow":
			arrow_active = true
			
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

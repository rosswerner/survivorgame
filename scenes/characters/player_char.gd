extends CharacterBody2D

@export var move_speed : float = 100
@export var attack_speed : float = 1000
#@export var starting_direction : Vector2 = Vector2(0,1)

var last_velocity := Vector2.ZERO
var click_position := Vector2()
var target_position := Vector2()
var mouse_position := Vector2()
var pos_dist : float = 0.0
var skill1_last_time : int = 0
var dead := false
var enemies_in_range := []
var rf_on := false
var xp := 0.0
var level := 0

#@export var attack_velocity : Vector2
@onready var fireball := preload("res://scenes/skills/fireball.tscn")
@onready var rf := preload("res://scenes/skills/righteous_fire.tscn")
@onready var health_bar := get_node("HUD/HealthBar")
@onready var tot_hp : float = 1000
@onready var cur_hp := tot_hp
@onready var hitbox := $Hitbox

func _ready():
	click_position = position
	health_bar.max_value = tot_hp
	health_bar.value = cur_hp
	#animation_tree.set("parameters/Idle/blend_position", starting_direction)
	
func _physics_process(_delta):
	if(!dead):
		mouse_position = get_global_mouse_position()
		if Input.is_action_pressed("Left_Click"):
			click_position = mouse_position
		#if Input.is_action_pressed("Skill1"):
		
		##Use skills##
		target_position = get_closest_enemy()
		#fireball_skill()
		rf_skill()
			
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
	print("ded")
	#damage_bar.visible = false
	
func rf_skill() -> void:
	if(!rf_on):
		var rf_tmp := rf.instantiate()
		rf_on = true
		rf_tmp.position = global_position.normalized()
		add_child(rf_tmp)
		
func fireball_skill() -> void:
	if(target_position != Vector2.ZERO):
		var fireball_tmp := fireball.instantiate()
		if(Time.get_ticks_msec() - skill1_last_time >= fireball_tmp.delay_time):
			skill1_last_time = Time.get_ticks_msec()
			var shoot_target := (target_position - global_position).normalized() #(mouse_position - global_position).normalized()
			fireball_tmp.position = global_position
			fireball_tmp.rotation = position.direction_to(target_position).angle()
			fireball_tmp.direction = shoot_target
			#this is to make the proj not be affected by the player's movements
			get_tree().get_root().add_child(fireball_tmp)
		
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

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if(anim_name == "death"):
		queue_free()

func _on_enemy_detector_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Monster") and !(cur_hp <=0)):
		enemies_in_range.append(body)

func _on_enemy_detector_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Monster")):
		enemies_in_range.erase(body)

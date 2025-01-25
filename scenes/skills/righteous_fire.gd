extends Area2D

@export var radius : float = 2.5
@export var dot_speed := .5
@export var damage : float = 1.0

@onready var dot_timer := $DoTTimer
@onready var sprite := $Sprite2D
@onready var dot_collision := $DoTCollision

var enemies_in_range := []

func _ready():
	sprite.scale *= radius
	dot_collision.scale *= radius
	
	dot_timer.wait_time = dot_speed
	#dot_timer.start()
	#explosion_collision.set_deferred("disabled", true)

#func _physics_process(delta) -> void:


func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Monster")):
		enemies_in_range.append(body)
		
func _on_body_exited(body: Node2D) -> void:
	if(body.is_in_group("Monster")):
		enemies_in_range.erase(body)

func _on_dot_timer_timeout() -> void:
	if(!enemies_in_range.is_empty()):
		for body in enemies_in_range :
			body.hit(damage)

func destroy() -> void:
	queue_free()
	#explode()
	
#func explode() -> void:
	#sprite.z_index += 1
	#explosion_collision.set_deferred("disabled", false)
	#state_machine.travel("Explode")

#func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	#if(anim_name == "explode"):
		#queue_free()

#func _on_explosion_area_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Monster"):
		#body.hit(explosion_damage)

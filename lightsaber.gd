extends Area2D

@export var speed : float = 1
@export var direction := Vector2(1,0)
@export var damage : float = 100
@export var knockback_amount : float = 100
@export var spin_delay_time : float = 1000 

func _physics_process(delta) -> void:
	position.x += (speed * direction.x * delta)
	position.y += (speed * direction.y * delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Monster"):
		body.hit(damage)

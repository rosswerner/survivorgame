extends Area2D

@export var speed : float = 300
@export var direction := Vector2(1,0)

func _physics_process(delta) -> void:
	position.x += (speed * direction.x * delta)
	position.y += (speed * direction.y * delta)

extends Area2D

@export var xp = 1

var target : CharacterBody2D = null
var speed := -0.5

@onready var sprite := $Sprite2D
@onready var collision := $CollisionShape2D
@onready var sound := $AudioStreamPlayer2D

func _ready() -> void:
	if xp < 50:
		pass
	elif xp < 100:
		pass #change color
	elif xp < 500:
		pass #change color
	
func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += 2 * delta
		
func collect():
	#sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return xp


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()

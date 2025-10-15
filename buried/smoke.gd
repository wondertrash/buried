extends Node2D
@onready var anim: AnimationPlayer = $AnimationPlayer
func _ready() -> void:
	anim.play("smoke")
	anim.animation_finished.connect(_on_finished)
func _on_finished(anim_name: String) -> void:
	if anim_name == "smoke":
		queue_free()

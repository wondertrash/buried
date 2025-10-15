extends Control
func _on_restart_pressed() -> void:
	get_tree().paused = false
	$gameOverClickAudio.play()
	get_tree().reload_current_scene()
func _on_quit_pressed() -> void:
	$gameOverClickAudio.play()
	get_tree().quit()

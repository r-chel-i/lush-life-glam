extends Node2D

@onready var title = $Title
@onready var play_button = $PlayButton

# Start game when user presses play
func _on_play_pressed():
	play_button.disabled = true

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(title, "modulate:a", 0.0, 0.5)
	tween.tween_property(play_button, "modulate:a", 0.0, 0.5)

	tween.finished.connect(func():
		$TwinkleSound.play()
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/introduction.tscn")
	)

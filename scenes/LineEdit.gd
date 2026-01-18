extends Control

@onready var input_field = $LineEdit



		



func _on_text_submitted(new_text):
	if new_text == "SYMPHONY":
		Globals.unlocked = true
		queue_free()


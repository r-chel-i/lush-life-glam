extends TextEdit

@export var code: String




func _on_lines_edited_from(from_line, to_line):
	if code == "SYMPHONY":
		Globals.unlocked = true
		queue_free()

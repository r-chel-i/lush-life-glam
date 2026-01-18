extends TextureButton

@export var link: String



func _on_pressed():
	OS.shell_open(link)

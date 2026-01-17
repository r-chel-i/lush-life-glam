extends TextureButton

@onready var cursor_normal = load("res://assets/cursor_normal.png")
@onready var cursor_click = load("res://assets/cursor_click.png")

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	Input.set_custom_mouse_cursor(cursor_click)

func _on_mouse_exited():
	Input.set_custom_mouse_cursor(cursor_normal)

func _exit_tree():
	Input.set_custom_mouse_cursor(null)

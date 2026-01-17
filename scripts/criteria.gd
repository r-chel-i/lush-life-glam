extends Node2D

@onready var speech_bubble = $"Speech Bubble" 
@onready var label = $"Speech Bubble/Label"

# Dialogue
var dialogues = [
	"I'm performing at a concert, so everything has to be fun and bright!",
	"The vibe is summer! Make sure I'm wearing something appropriate.",
	"I also *hate* a red lip, but any other colour will do.",
	"That's all from me! I can't wait to see what you choose!"
]
var current_index = 0

# Fade in/out transitions
func fade_in_node(node, duration = 0.3):
	if not node:
		return
	node.visible = true
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)

func fade_out_node(node, duration = 0.3):
	if not node:
		return
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.finished.connect(func(): node.visible = false)

# Dialogue functions
func show_dialogue(index):
	label.text = dialogues[index]
	fade_in_node(speech_bubble)

func hide_dialogue(next_index):
	var tween = fade_out_node(speech_bubble)
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.35
	add_child(timer)
	timer.timeout.connect(func():
		# Exhausted dialogue: switch to next scene
		if next_index >= dialogues.size():
			get_tree().change_scene_to_file("res://scenes/game.tscn")
		else:
			current_index = next_index
			show_dialogue(current_index)
		timer.queue_free()
	)
	timer.start()

# Click to advance dialogue
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		hide_dialogue(current_index + 1)

func _ready():
	if speech_bubble:
		speech_bubble.visible = false
	show_dialogue(current_index)

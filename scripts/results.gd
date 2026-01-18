extends Node

@onready var speech_bubble = $"Speech Bubble"
@onready var label = $"Speech Bubble/Label"
@onready var customer = $"Customer"
@onready var chair = $"Chair"
@onready var reset_button = $"Reset Button"
@onready var success_sound = $"Success Sound"
@onready var fail_sound = $"Fail Sound"

@onready var content_nodes = [$"Speech Bubble", $"Customer", $"Chair", $"Reset Button"]  

# Fade Transitions
func fade_in(node, duration := 0.4):
	if not node: return
	node.visible = true
	node.modulate.a = 0.0
	create_tween().tween_property(node, "modulate:a", 1.0, duration)

func fade_out(node, duration := 0.4):
	if not node: return
	var t = create_tween()
	t.tween_property(node, "modulate:a", 0.0, duration)
	t.finished.connect(func(): node.visible = false)

func _ready():

	# Show lips reaction
	var score = Gamestate.score
	var chosen_lips = Gamestate.selections.get("lips", "res://assets/lips/lips1.png")
	var lips_path: String = chosen_lips.replace(".png", "")
	var new_lips_texture: Texture

	if score >= 70:
		new_lips_texture = load(lips_path + "_smile.png")
		if success_sound: success_sound.play()
	elif score < 50:
		new_lips_texture = load("res://assets/lips/lips_frown.png")
		if fail_sound: fail_sound.play()
	else:
		new_lips_texture = load(chosen_lips) # neutral

	customer.get_node("Lips").texture = new_lips_texture

	# Show reaction dialogue
	label.text = get_reaction_dialogue(score)
	fade_in(speech_bubble)
	
	reset_button.pressed.connect(_on_reset_pressed)


func get_reaction_dialogue(score: int) -> String:
	if score >= 80:
		return "Oh WOW — this is absolutely perfect! Summer isn't over yet!"
	elif score >= 70:
		return "Ooo, okay! I like this! Thanks for all your hard work!"
	elif score >= 50:
		return "Hmm... I wouldn't pick this out for myself... but not bad!"
	else:
		return "This isn't what I asked for! What am I supposed to do now?"
		
func _on_reset_pressed():
	reset_button.disabled = true

	# Clear Gamestate
	Gamestate.selections.clear()
	Gamestate.score = 0

	var tween = create_tween()
	tween.set_parallel(true) 

	# Fade out all content nodes
	for node in content_nodes:
		if node and node.visible:
			tween.tween_property(node, "modulate:a", 0.0, 0.5)

	# When tween finishes, go back to main menu
	tween.finished.connect(func():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	)

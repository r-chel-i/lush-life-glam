extends Node2D

enum Category { BODY, HAIR, EYES, EYEBROWS, LIPS, SHIRT }
var current_category = Category.HAIR

@onready var checkmark = $Checkmark
@onready var options_bg = $"Options Background"

@onready var targets = {
	Category.BODY: $Customer/Body,
	Category.EYES: $Customer/Eyes,
	Category.EYEBROWS: $Customer/Eyebrows,
	Category.LIPS: $Customer/Lips,
	Category.SHIRT: $Customer/Shirt,
	Category.HAIR: {
		"front": $Customer/HairFront,
		"back": $Customer/HairBack
	}
}

@onready var category_buttons = {
	Category.HAIR: $"Hair Select",
	Category.BODY: $"Body Select",
	Category.EYES: $"Eyes Select",
	Category.EYEBROWS: $"Eyebrows Select",
	Category.LIPS: $"Lips Select",
	Category.SHIRT: $"Shirt Select"
}

@onready var option_slots = [
	$"Option 1",
	$"Option 2",
	$"Option 3",
	$"Option 4"
]

@onready var particles := $Transition

var angle := 0.0
var radius := 0.0
var center := Vector2(-205,104)
var swirling := false
var swirl_time := 0.0
var swirl_duration := 2.0

var options = {
	Category.BODY: [
		"res://assets/body/body1.png",
		"res://assets/body/body2.png",
		"res://assets/body/body3.png",
		"res://assets/body/body4.png",
	],
	Category.HAIR: [
		"res://assets/hair/hair1.png",
		"res://assets/hair/hair2.png",
		"res://assets/hair/hair3.png",
		"res://assets/hair/hair4.png",
	],
	Category.EYES: [
		"res://assets/eyes/eyes1.png",
		"res://assets/eyes/eyes2.png",
		"res://assets/eyes/eyes3.png",
		"res://assets/eyes/eyes4.png",
	],
	Category.EYEBROWS: [
		"res://assets/eyebrows/eyebrows1.png",
		"res://assets/eyebrows/eyebrows2.png",
		"res://assets/eyebrows/eyebrows3.png",
		"res://assets/eyebrows/eyebrows4.png",
	],
	Category.LIPS: [
		"res://assets/lips/lips1.png",
		"res://assets/lips/lips2.png",
		"res://assets/lips/lips3.png",
		"res://assets/lips/lips4.png",
	],
	Category.SHIRT: [
		"res://assets/shirt/shirt1.png",
		"res://assets/shirt/shirt2.png",
		"res://assets/shirt/shirt3.png",
		"res://assets/shirt/shirt4.png",
	],
}

# Fade transitions
func fade_in_node(node: CanvasItem, duration: float = 0.5):
	node.visible = true
	node.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)
	return tween

func fade_out_node(node: CanvasItem, duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	tween.finished.connect(func(): node.visible = false)
	return tween

# Switch categories (hair, skin, etc.)
func switch_category(category):
	current_category = category
	clear_option_selection()

	var textures = options[category]

	for i in range(option_slots.size()):
		var slot = option_slots[i]
		var preview = slot.get_node_or_null("Preview")
		if preview and preview is TextureRect:
			preview.texture = load(textures[i])
		else:
			push_warning("Preview missing in slot %d" % i)

func _on_category_pressed(category):
	switch_category(category)


func clear_option_selection():
	for slot in option_slots:
		if slot is BaseButton:
			slot.button_pressed = false

# Choose option
func _on_option_pressed(index):
	print("Button pressed!", index)
	var path = options[current_category][index]
	
	if (current_category != 0) and (index == 3) and (Globals.unlocked == false):
		var popup = preload("res://scenes/toSurvey.tscn").instantiate()
		add_child(popup)
		return
	
	center = Vector2(-205,104)
	angle = 0.0
	radius = 0.0
	swirl_time = 0.0
	swirling = true
	particles.restart()
	particles.emitting = true
	$"Makeup Application".play()
	
	await get_tree().create_timer(1.9).timeout
		

	match current_category:
		Category.HAIR:
			var front = "res://assets/hair/hair%d_front.png" % (index + 1)
			var back  = "res://assets/hair/hair%d_back.png" % (index + 1)

			targets[Category.HAIR]["front"].texture = load(front)
			targets[Category.HAIR]["back"].texture = load(back)

			Gamestate.selections["hair"]["front"] = front
			Gamestate.selections["hair"]["back"] = back

		Category.BODY:
			targets[Category.BODY].texture = load(path)
			Gamestate.selections["body"] = path
		Category.EYES:
			targets[Category.EYES].texture = load(path)
			Gamestate.selections["eyes"] = path
		Category.EYEBROWS:
			targets[Category.EYEBROWS].texture = load(path)
			Gamestate.selections["eyebrows"] = path
		Category.LIPS:
			targets[Category.LIPS].texture = load(path)
			Gamestate.selections["lips"] = path
		Category.SHIRT:
			targets[Category.SHIRT].texture = load(path)
			Gamestate.selections["shirt"] = path

func _ready():
	
	# Hide all UI
	options_bg.visible = false
	checkmark.visible = false
	for btn in option_slots:
		btn.visible = false
	for cat_btn in category_buttons.values():
		cat_btn.visible = false

	# Fade in UI
	fade_in_node(options_bg)
	for btn in option_slots:
		fade_in_node(btn)
	for cat_btn in category_buttons.values():
		fade_in_node(cat_btn)
	fade_in_node(checkmark)
	
	# Category buttons
	for category in category_buttons.keys():
		var btn = category_buttons[category]
		if btn:
			var cat = category
			btn.pressed.connect(func() -> void:
				_on_category_pressed(cat)
			)
		else:
			push_warning("Category button missing: " + str(category))

	# Option buttons
	for i in range(option_slots.size()):
		var slot = option_slots[i]
		if slot and slot is BaseButton:
			var idx = i 
			print("Connecting signal for: ", slot.name) 
			
			slot.pressed.connect(func() -> void:
				print("SIGNAL FIRED: Slot ", idx, " clicked!") 
				_on_option_pressed(idx)
			)
		else:
			push_warning("Option button missing or not a Button at slot %d" % i)

	if category_buttons[Category.HAIR]:
		category_buttons[Category.HAIR].emit_signal("pressed")
		switch_category(Category.HAIR)
	
	checkmark.pressed.connect(_on_check_pressed)
		

func _process(delta):
	if not swirling:
		return

	swirl_time += delta

	if swirl_time >= swirl_duration:
		stop_swirl()
		return

	angle += delta * 20.0
	radius += delta * 140.0

	var offset := Vector2(
		cos(angle) * radius,
		sin(angle) * radius
	)

	particles.position = center + offset

func stop_swirl():
	swirling = false
	particles.emitting = false
	

# Move to next screen
func _on_check_pressed():
	checkmark.disabled = true
	$"Twinkle Sound".play()
	
	fade_out_node(options_bg)
	for btn in option_slots:
		fade_out_node(btn)
	for cat_btn in category_buttons.values():
		fade_out_node(cat_btn)
	fade_out_node(checkmark)
	
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/calculation.tscn")


extends Node2D

enum Category { BODY, HAIR, EYES, EYEBROWS, LIPS, SHIRT }
var current_category = Category.HAIR

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

# --- CATEGORY SWITCHING ---
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

func clear_option_selection():
	for slot in option_slots:
		if slot and slot is Button:
			slot.pressed = false

# --- OPTION SELECTION ---
func on_option_pressed(index):
	var path = options[current_category][index]

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

# --- READY ---
func _ready():
	# Category buttons
	for category in category_buttons.keys():
		var btn = category_buttons[category]
		if btn:
			# Capture category as a local variable to avoid closure issue
			var cat = category
			btn.pressed.connect(func() -> void:
				_on_category_pressed(cat)
			)
		else:
			push_warning("Category button missing: " + str(category))

	# Option buttons
	for i in range(option_slots.size()):
		var slot = option_slots[i]
		if slot and slot is Button:
			var idx = i  # Capture index locally
			slot.pressed.connect(func() -> void:
				_on_option_pressed(idx)
			)
		else:
			push_warning("Option button missing in slot %d" % i)

	# Initialize Hair category
	if category_buttons[Category.HAIR]:
		category_buttons[Category.HAIR].emit_signal("pressed")
		switch_category(Category.HAIR)

func _on_category_pressed(category):
	switch_category(category)

func _on_option_pressed(index):
	on_option_pressed(index)

extends Control
class_name ResultTextPanel

@onready var container: VBoxContainer = $MainContainer/Container
@onready var found_words_container: VBoxContainer = $MainContainer/FoundWordsContainer

var text_elements: Array = []
var drop_zones: Array[DropZone] = []
var found_word_scene: PackedScene = preload("res://assets/found_word/found_word.tscn")
var drop_zone_scene: PackedScene = preload("uid://dkf0vt7wj0ko")
var placed_word_scene: PackedScene = preload("res://scenes/placed_word_label.tscn")
var text_label_scene: PackedScene = preload("res://scenes/text_label.tscn")

signal word_placed_correctly(word: String, drop_zone: DropZone)
signal puzzle_completed()

func _ready():
	# Initially hide the panel
	#visible = false
	
	# Connect buttons
	var close_button = $MainContainer/ButtonContainer/CloseButton
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	var check_button = $MainContainer/ButtonContainer/CheckButton
	if check_button:
		check_button.pressed.connect(_on_check_button_pressed)
		
	GameManager.result_panel = self

func setup_final_text(final_text: String):
	# Clear existing elements
	for child in container.get_children():
		child.queue_free()
	drop_zones.clear()
	text_elements.clear()
	
	# Parse the text
	text_elements = TextParser.parse_final_text(final_text)
	
	# Create wrapped text layout
	create_wrapped_text_layout()

func create_wrapped_text_layout():
	var current_line = create_new_line()
	var current_line_width = 0
	var max_line_width = container.size.x - 40  # Leave some margin
	
	for element in text_elements:
		if element.type == "label":
			var label = text_label_scene.instantiate()
			label.set_text_content(element.text)
			
			# Check if this label would overflow the line
			var label_width = estimate_text_width(element.text)
			if current_line_width + label_width > max_line_width and current_line_width > 0:
				# Start a new line
				current_line = create_new_line()
				current_line_width = 0
			
			current_line.add_child(label)
			current_line_width += label_width
			
		elif element.type == "drop_zone":
			var drop_zone = create_drop_zone(element.expected_word)
			drop_zones.append(drop_zone)
			
			# Check if this drop zone would overflow the line
			var drop_zone_width = drop_zone.custom_minimum_size.x
			if current_line_width + drop_zone_width > max_line_width and current_line_width > 0:
				# Start a new line
				current_line = create_new_line()
				current_line_width = 0
			
			current_line.add_child(drop_zone)
			current_line_width += drop_zone_width

func create_new_line() -> HBoxContainer:
	var line = HBoxContainer.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(line)
	return line

func estimate_text_width(text: String) -> float:
	# Create a temporary label to get accurate text width
	var temp_label = text_label_scene.instantiate()
	temp_label.text = text
	add_child(temp_label)
	
	# Force update the label to get proper size
	temp_label.force_update_transform()
	var width = temp_label.get_theme_font("font").get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	
	# Remove the temporary label
	temp_label.queue_free()
	
	return width + 10  # Add some padding

func create_drop_zone(expected_word: String) -> DropZone:
	var drop_zone = drop_zone_scene.instantiate()
	drop_zone.expected_word = expected_word
	
	# Connect signals
	drop_zone.word_dropped.connect(_on_word_dropped)
	
	return drop_zone

func show_panel():
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#setup_found_words_display()

func setup_found_words_display():
	# Clear existing found words
	for child in found_words_container.get_children():
		child.queue_free()
	
	# Create draggable found words
	for word in GameManager.found_words:
		var found_word_node = found_word_scene.instantiate()
		found_word_node.text = word
		found_word_node.setup_draggable()
		found_words_container.add_child(found_word_node)

func _on_word_dropped(word: String, drop_zone: DropZone):
	# Hide placeholder
	var placeholder = drop_zone.get_node("Placeholder")
	if placeholder:
		placeholder.visible = false
	
	# Create and show the new word
	var word_label = placed_word_scene.instantiate()
	word_label.set_word_text(word)
	word_label.set_placed_state()
	drop_zone.add_child(word_label)
	
	# Use DropZone method to manage the placed word
	drop_zone.set_placed_word(word_label, word)
	
	# Reset background color
	drop_zone.add_theme_color_override("background_color", Color(0.3, 0.3, 0.3, 0.8))

func is_puzzle_complete() -> bool:
	for drop_zone in drop_zones:
		if drop_zone.placed_word == "":
			return false
	return true

func check_puzzle_correctness() -> bool:
	var all_correct = true
	for drop_zone in drop_zones:
		var word_label = drop_zone.get_placed_word_node()
		if word_label and drop_zone.placed_word.to_lower() == drop_zone.expected_word.to_lower():
			# Correct placement - green background
			drop_zone.add_theme_color_override("background_color", Color(0.2, 0.7, 0.2, 0.8))
			word_label.set_correct_state(true)
		else:
			# Wrong placement - red background
			drop_zone.add_theme_color_override("background_color", Color(0.7, 0.2, 0.2, 0.8))
			if word_label:
				word_label.set_correct_state(false)
			all_correct = false
	
	return all_correct

func hide_panel():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_close_button_pressed():
	hide_panel()

func _on_check_button_pressed():
	var all_correct = check_puzzle_correctness()
	if all_correct:
		puzzle_completed.emit()
		GameManager.puzzle_succeeded()
		$SuccessLabel.visible = true
		print("Puzzle completed successfully!")
	else:
		print("Some words are placed incorrectly. Try again!")

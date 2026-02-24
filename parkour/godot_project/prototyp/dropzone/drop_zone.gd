extends Control
class_name DropZone

@export var expected_word: String = ""
@export var can_accept_drop: bool = true
var placed_word: String = ""
var placed_word_node: PlacedWordLabel = null

signal word_dropped(word: String, drop_zone: DropZone)

var drag_preview: Control = null

func _ready():
	# Enable drop detection
	gui_input.connect(_on_gui_input)
	# Add to drop zones group for easy management
	add_to_group("drop_zones")

func _can_drop_data(_position: Vector2, data) -> bool:
	if not can_accept_drop:
		return false
	
	return data.has("dragged_word")

func _drop_data(_position: Vector2, data):
	var word = data.dragged_word
	word_dropped.emit(word, self)

func set_placed_word(word_node: PlacedWordLabel, word: String):
	# Remove existing placed word if any
	if placed_word_node:
		placed_word_node.queue_free()
	
	# Set new placed word
	placed_word_node = word_node
	placed_word = word

func get_placed_word_node() -> PlacedWordLabel:
	return placed_word_node

func clear_placed_word():
	if placed_word_node:
		placed_word_node.queue_free()
		placed_word_node = null
	placed_word = ""
	
	# Show placeholder
	var placeholder = get_node("Placeholder")
	if placeholder:
		placeholder.visible = true

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Visual feedback when clicked
			var tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

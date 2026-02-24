extends Label
class_name DraggableWord

var is_dragging: bool = false
var drag_offset: Vector2
var original_parent: Node
var original_position: Vector2
var original_global_position: Vector2

signal drag_started(word_node: DraggableWord)
signal drag_ended(word_node: DraggableWord)

func _ready():
	# Make the label draggable
	gui_input.connect(_on_gui_input)
	mouse_filter = Control.MOUSE_FILTER_PASS

func setup_draggable():
	# This method is called when the word is created for the result panel
	# Add visual styling to indicate it's draggable
	add_theme_color_override("font_color", Color(1, 0.8, 0.4, 1))  # Golden color
	add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	add_theme_constant_override("outline_size", 2)
	
	# Add a subtle background to make it look like a button
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style_box.border_color = Color(0.5, 0.5, 0.5, 1.0)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 5
	style_box.corner_radius_top_right = 5
	style_box.corner_radius_bottom_left = 5
	style_box.corner_radius_bottom_right = 5
	
	add_theme_stylebox_override("normal", style_box)
	
	# Add some padding
	add_theme_constant_override("margin_left", 10)
	add_theme_constant_override("margin_right", 10)
	add_theme_constant_override("margin_top", 5)
	add_theme_constant_override("margin_bottom", 5)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag(event)
			else:
				end_drag()
	elif event is InputEventMouseMotion and is_dragging:
		update_drag_position(event)

func start_drag(event: InputEventMouseButton):
	is_dragging = true
	drag_offset = event.position
	original_parent = get_parent()
	original_position = position
	original_global_position = global_position
	
	# Move to top level for dragging
	var root = get_tree().root
	root.add_child(self)
	global_position = get_global_mouse_position() - drag_offset
	
	# Visual feedback
	modulate.a = 0.7
	scale = Vector2(1.1, 1.1)
	
	drag_started.emit(self)

func end_drag():
	if not is_dragging:
		return
		
	is_dragging = false
	
	# Reset visual feedback
	modulate.a = 1.0
	scale = Vector2(1.0, 1.0)
	
	# Check if we were dropped on a valid drop zone
	var drop_target = get_drop_target()
	if drop_target and drop_target.can_accept_drop:
		# Drop the word (allows overriding existing words)
		drop_target._drop_data(Vector2.ZERO, {"dragged_word": text})
		original_parent.add_child(self)
		position = original_position
	else:
		# Return to original position
		original_parent.add_child(self)
		position = original_position
	
	drag_ended.emit(self)

func update_drag_position(_event: InputEventMouseMotion):
	if is_dragging:
		global_position = get_global_mouse_position() - drag_offset

func get_drop_target() -> DropZone:
	# Check if we're over a valid drop zone
	var mouse_pos = get_global_mouse_position()
	
	# Simple approach: check all DropZone nodes
	var drop_zones = get_tree().get_nodes_in_group("drop_zones")
	for drop_zone in drop_zones:
		if drop_zone is DropZone:
			var rect = Rect2(drop_zone.global_position, drop_zone.size)
			if rect.has_point(mouse_pos):
				return drop_zone
	
	return null

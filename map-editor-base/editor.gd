extends Node3D


var registered_map_objects: Dictionary[String, MapObject]
var selected_map_object: MapObject


@warning_ignore("shadowed_variable_base_class")
func InstantiateMapObject(
	base: String,
	pos: Vector3 = Vector3.ZERO,
	rot_degrees: Vector3 = Vector3.ZERO,
	scale: Vector3 = Vector3.ONE
) -> MapObject:
	if not registered_map_objects.has(base):
		return null
	
	var instance := registered_map_objects[base].duplicate()
	instance.position = pos
	instance.rotation_degrees = rot_degrees
	instance.scale = scale
	add_child(instance)
	return instance

func BuildGUIForMapObjectInstanceData(target: MapObject) -> Array[Control]:
	var controls: Array[Control]
	
	for key in target.data:
		if target.data[key] is bool:
			var checkbox := CheckBox.new()
			checkbox.text = key
			checkbox.button_pressed = target.data[key]
			checkbox.toggled.connect(
				func(toggled_on: bool):
					target.data[key] = toggled_on
			)
			controls.append(checkbox)
		
		elif target.data[key] is int:
			var vcontainer := VBoxContainer.new()
			var label := Label.new()
			label.text = key
			vcontainer.add_child(label)
			var spinbox := SpinBox.new()
			spinbox.rounded = true
			spinbox.allow_greater = true
			spinbox.allow_lesser = true
			spinbox.value = target.data[key]
			spinbox.value_changed.connect(
				func(value: float):
					target.data[key] = int(value)
			)
			spinbox.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
			vcontainer.add_child(spinbox)
			controls.append(vcontainer)
		
		elif target.data[key] is float:
			var vcontainer := VBoxContainer.new()
			var label := Label.new()
			label.text = key
			vcontainer.add_child(label)
			var spinbox := SpinBox.new()
			spinbox.step = -1
			spinbox.allow_greater = true
			spinbox.allow_lesser = true
			spinbox.value = target.data[key]
			spinbox.value_changed.connect(
				func(value: float):
					target.data[key] = value
			)
			spinbox.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
			vcontainer.add_child(spinbox)
			controls.append(vcontainer)
		
		elif target.data[key] is String:
			var vcontainer := VBoxContainer.new()
			var label := Label.new()
			label.text = key
			vcontainer.add_child(label)
			var line_edit := LineEdit.new()
			line_edit.text = target.data[key]
			line_edit.text_changed.connect(
				func(new_text: String):
					target.data[key] = new_text
			)
			line_edit.size_flags_horizontal |= Control.SIZE_EXPAND_FILL
			vcontainer.add_child(line_edit)
			controls.append(vcontainer)
		
		else:
			var label := Label.new()
			label.text = key
			controls.append(label)
	
	return controls

func SelectMapObject(target: MapObject) -> void:
	selected_map_object = target
	
	if not %Gizmo3D.is_selected(selected_map_object):
		%Gizmo3D.clear_selection()
		%Gizmo3D.select(selected_map_object)
	%Gizmo3D.show()
	
	%SpinBox_position_x.value = selected_map_object.position.x
	%SpinBox_position_y.value = selected_map_object.position.y
	%SpinBox_position_z.value = selected_map_object.position.z
	%SpinBox_rotation_x.value = selected_map_object.rotation_degrees.x
	%SpinBox_rotation_y.value = selected_map_object.rotation_degrees.y
	%SpinBox_rotation_z.value = selected_map_object.rotation_degrees.z
	%SpinBox_scale_x.value = selected_map_object.scale.x
	%SpinBox_scale_y.value = selected_map_object.scale.y
	%SpinBox_scale_z.value = selected_map_object.scale.z
	
	for child in %Data_panel.get_children():
		child.queue_free()
	for control in BuildGUIForMapObjectInstanceData(selected_map_object):
		%Data_panel.add_child(control)

func DeselectMapObject() -> void:
	selected_map_object = null
	
	%Gizmo3D.clear_selection()
	%Gizmo3D.hide()
	
	%SpinBox_position_x.value = 0.0
	%SpinBox_position_y.value = 0.0
	%SpinBox_position_z.value = 0.0
	%SpinBox_rotation_x.value = 0.0
	%SpinBox_rotation_y.value = 0.0
	%SpinBox_rotation_z.value = 0.0
	%SpinBox_scale_x.value = 0.0
	%SpinBox_scale_y.value = 0.0
	%SpinBox_scale_z.value = 0.0
	
	for child in %Data_panel.get_children():
		child.queue_free()

func DeleteSelectedMapObject() -> void:
	if selected_map_object:
		var target := selected_map_object
		DeselectMapObject()
		target.queue_free()

func Save(path: String) -> void:
	var map_object_instances_data: Array[Dictionary]
	var children := get_children()
	children.pop_front() # Exclude internal nodes
	for child in children:
		if child is MapObject:
			map_object_instances_data.append({
				"type": child.get_meta("type"),
				"pos": [
					child.position.x,
					child.position.y,
					child.position.z
				],
				"rot": [
					child.rotation_degrees.x,
					child.rotation_degrees.y,
					child.rotation_degrees.z
				],
				"scale": [
					child.scale.x,
					child.scale.y,
					child.scale.z
				],
				"data": child.data
			})
	
	FileAccess.open(path, FileAccess.WRITE).store_string(
		JSON.stringify(map_object_instances_data, "\t")
	)

func Load(path: String) -> void:
	DeselectMapObject()
	
	var children := get_children()
	children.pop_front() # Exclude internal nodes
	for child in children:
		child.queue_free()
	
	var loaded_data = JSON.parse_string(
		FileAccess.open(path, FileAccess.READ).get_as_text()
	)
	for map_object in loaded_data:
		if map_object["type"] not in registered_map_objects:
			continue
		
		var instance := InstantiateMapObject(
			map_object["type"],
			Vector3(map_object["pos"][0], map_object["pos"][1], map_object["pos"][2]),
			Vector3(map_object["rot"][0], map_object["rot"][1], map_object["rot"][2]),
			Vector3(map_object["scale"][0], map_object["scale"][1], map_object["scale"][2])
		)
		for key in map_object["data"]:
			instance.data[key] = map_object["data"][key]

func _ready() -> void:
	for file in DirAccess.open("res://MapObjects").get_files():
		if file.begins_with("_BASE."): continue
		
		var res := load("res://MapObjects/" + file)
		if res == null: continue
		var instance: MapObject = res.new()
		instance.set_meta("type", file.get_file())
		var collider := Area3D.new()
		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = instance.mesh.create_convex_shape()
		collision_shape.transform = instance.transform
		collider.add_child(collision_shape)
		instance.add_child(collider)
		registered_map_objects[file.get_file()] = instance
	
	for map_object_name in registered_map_objects:
		var add_button := Button.new()
		add_button.text = map_object_name.get_basename()
		add_button.pressed.connect(
			func():
				SelectMapObject(InstantiateMapObject(
					map_object_name,
					%EditorCamera.position
				))
				%AddMapObjectPopup.hide()
		)
		%AddMapObjectButtons.add_child(add_button)

func _physics_process(_delta: float) -> void:
	if get_viewport().gui_get_focus_owner() != null: return
	if %Gizmo3D.hovering or %Gizmo3D.editing: return
	
	if Input.is_action_just_pressed("Click"):
		var mouse_position := get_viewport().get_mouse_position()
		var from: Vector3 = %EditorCamera.project_ray_origin(mouse_position)
		var to: Vector3 = from + %EditorCamera.project_ray_normal(mouse_position) * %EditorCamera.far
		var ray_query_params := PhysicsRayQueryParameters3D.create(from, to)
		ray_query_params.collide_with_areas = true
		var raycast_result := get_world_3d().direct_space_state.intersect_ray(ray_query_params)
		if raycast_result:
			SelectMapObject(raycast_result["collider"].get_parent())
		else:
			DeselectMapObject()

func _input(event: InputEvent) -> void:
	if (event is InputEventKey and event.pressed and not event.is_echo()):
		match event.keycode:
			KEY_DELETE: DeleteSelectedMapObject()
			KEY_ESCAPE:
				get_viewport().gui_release_focus()
				if Input.is_key_pressed(KEY_ALT):
					get_tree().quit()
			KEY_D:
				if Input.is_key_pressed(KEY_ALT) and selected_map_object:
					var clone := selected_map_object.duplicate()
					clone.data = selected_map_object.data
					add_child(clone)
					SelectMapObject(clone)


#region CALLBACKS

func _on_button_add_pressed() -> void:
	%AddMapObjectPopup.popup_centered()


func _on_button_save_pressed() -> void:
	%SaveFileDialog.popup_centered()

func _on_save_file_dialog_file_selected(path: String) -> void:
	Save(path)
	get_viewport().gui_release_focus()


func _on_button_load_pressed() -> void:
	%LoadFileDialog.popup_centered()

func _on_load_file_dialog_file_selected(path: String) -> void:
	Load(path)
	get_viewport().gui_release_focus()


func _on_gizmo_3d_transform_changed(mode: Gizmo3D.TransformMode, value: Vector3) -> void:
	get_viewport().gui_release_focus()
	match mode:
		Gizmo3D.TransformMode.TRANSLATE:
			selected_map_object.global_position += value
		Gizmo3D.TransformMode.ROTATE:
			selected_map_object.global_rotation += value
		Gizmo3D.TransformMode.SCALE:
			selected_map_object.scale += value
	SelectMapObject(selected_map_object) # Refresh


func _on_viewport_padding_mouse_entered() -> void:
	get_viewport().gui_release_focus()


# -- GUI --

func _on_spin_box_position_x_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.position.x = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_position_y_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.position.y = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_position_z_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.position.z = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_rotation_x_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.rotation_degrees.x = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_rotation_y_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.rotation_degrees.y = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_rotation_z_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.rotation_degrees.z = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_scale_x_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.scale.x = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_scale_y_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.scale.y = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

func _on_spin_box_scale_z_value_changed(value: float, source: Range) -> void:
	get_viewport().gui_release_focus()
	if selected_map_object:
		selected_map_object.scale.z = value
		SelectMapObject(selected_map_object) # Refresh
	else:
		source.set_value_no_signal(0.0)

#endregion CALLBACKS

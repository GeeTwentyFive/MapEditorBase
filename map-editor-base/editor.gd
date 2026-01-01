extends Node3D


var registered_map_objects: Dictionary[String, MapObject]
var selected_map_object: MapObject


func InstantiateMapObject(
	base: String,
	pos: Vector3 = Vector3.ZERO,
	rot: Vector3 = Vector3.ZERO,
	scale: Vector3 = Vector3.ONE
) -> MapObject:
	if not registered_map_objects.has(base):
		return null
	
	var instance := registered_map_objects[base].duplicate()
	instance.position = pos
	instance.rotation = rot
	instance.scale = scale
	add_child(instance)
	return instance

func BuildGUIForMapObjectInstance(target: MapObject) -> Control:
	var gui: Control
	
	# TODO: Build MapObject instance's GUI based on its data
	
	return gui

func SelectMapObject(target: MapObject) -> void:
	selected_map_object = target
	
	if not %Gizmo3D.is_selected(selected_map_object):
		%Gizmo3D.clear_selection()
		%Gizmo3D.select(selected_map_object)
	%Gizmo3D.show()
	
	%Inspector_panel.add_child(
		BuildGUIForMapObjectInstance(selected_map_object)
	)

func DeselectMapObject() -> void:
	selected_map_object = null
	
	%Gizmo3D.clear_selection()
	%Gizmo3D.hide()
	
	for child in %Inspector_panel.get_children():
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
		map_object_instances_data.append({
			# TODO
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
	for instance in loaded_data:
		pass # TODO: Check if exists as MapObject type -> instantiate

func _ready() -> void:
	pass # TODO: AddMapObjectButtons from res://MapObjects/

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
			SelectMapObject(raycast_result["collider"])
		else:
			DeselectMapObject()

func _input(event: InputEvent) -> void:
	if (event is InputEventKey and event.pressed and not event.is_echo()):
		match event.keycode:
			KEY_ESCAPE: get_viewport().gui_release_focus()
			KEY_DELETE: DeleteSelectedMapObject()
			KEY_D:
				if Input.is_key_pressed(KEY_ALT) and selected_map_object:
					SelectMapObject(InstantiateMapObject(
						# TODO
					))


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

#endregion CALLBACKS

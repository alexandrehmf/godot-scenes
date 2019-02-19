extends Node

var stick_vector = Vector2()
var index = -1
var handle_radius = 0
var field_radius = 0
var deadzone = 0.2

signal updated(vector)

func _ready():
	field_radius = $Field/CollisionShape2D.shape.radius
	handle_radius = $Field/Handle/CollisionShape2D.shape.radius

func _input(event):
	if event is InputEventScreenDrag:
		if event.index == index:
			$Field/Handle.global_position = event.position
			if $Field/Handle.position.length() +  handle_radius > field_radius:
				$Field/Handle.position = ($Field/Handle.position / $Field/Handle.position.length()) * (field_radius-handle_radius)
				stick_vector = $Field/Handle.position
			else:
				stick_vector = $Field/Handle.position
			var normalized = stick_vector/(field_radius-handle_radius)
			if normalized.length() < deadzone:
				stick_vector = Vector2()
			else:
				stick_vector = normalized * ((normalized.length() - deadzone) / (1 - deadzone))
			emit_signal("updated",stick_vector)
	elif event is InputEventScreenTouch:
		if event.index == index:
			if !event.pressed:
				index = -1
				stick_vector = Vector2()
				$Field/Handle.position = stick_vector
				emit_signal("updated",stick_vector)

func _on_Field_input_event(viewport, event, shape_idx):
	if event is InputEventScreenTouch:
		if !event.pressed:
			index = -1
			stick_vector = Vector2()
			$Field/Handle.position = stick_vector
		else:
			index = event.index
			$Field/Handle.global_position = event.position
			if $Field/Handle.position.length() +  handle_radius < field_radius:
				stick_vector = $Field/Handle.position
			else:
				$Field/Handle.position = ($Field/Handle.position / $Field/Handle.position.length()) * (field_radius-handle_radius)
				stick_vector = $Field/Handle.position
		var normalized = stick_vector/(field_radius-handle_radius)
		if normalized.length() < deadzone:
			stick_vector = Vector2()
		else:
			stick_vector = normalized * ((normalized.length() - deadzone) / (1 - deadzone))
		emit_signal("updated",stick_vector)
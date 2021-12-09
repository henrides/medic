extends Node2D

signal position_struck(position)

var is_striking = false;

func _ready():
	pass # Replace with function body.

func strike(grid_size):
	is_striking = true
	var strike_pos_x = randi() % int(grid_size.x)
	var strike_pos_y = randi() % int(grid_size.y)
	emit_signal("position_struck", Vector2(strike_pos_x, strike_pos_y))
	is_striking = false

func strike_array(grid_positions):
	is_striking = true
	var strike_pos_idx = randi() % int(grid_positions.size())
	emit_signal("position_struck", grid_positions[strike_pos_idx])
	is_striking = false

func hit():
	pass

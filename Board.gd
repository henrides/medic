extends TileMap

export (PackedScene) var Unit

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

var grid_size = Vector2(6,6)
var field_positions = Array()

enum PLAYER_TYPE { HUMAN, ARTILLERY }
var turn = PLAYER_TYPE.HUMAN
var artillery_turn_count = 0

enum ENTITY_TYPE { MEDIC, UNIT, HELICOPTER, DOGTAG, CROSS }

const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

func _ready():
	randomize()
	
	generate_field()
	
	for u in range(0, 5):
		var unit_pos = rand_empty_space()
		var unit = Unit.instance()
		add_child(unit)
		unit.connect("rescued", self, "_on_Unit_rescued")
		unit.connect("dead", self, "_on_Unit_dead")
		unit.position = map_to_world(unit_pos) + half_tile_size
		
	
	var helicopter_pos = rand_empty_space()
	$Helicopter.position = map_to_world(helicopter_pos) + half_tile_size
	$Helicopter.connect("evacuated", self, "_on_Helicopter_evacuated")
	$Helicopter.connect("destroyed", self, "_on_Helicopter_destroyed")
	
	var medic_pos = rand_empty_space()
	$Medic.position = map_to_world(medic_pos) + half_tile_size
	$Medic.connect("movement_completed", self, "_on_Medic_movement_completed")
	
	$Artillery.connect("position_struck", self, "_on_Artillery_position_struck")

func generate_field():
	for i in range(0, grid_size.x): 
		for j in range(0, grid_size.y):
			field_positions.append(Vector2(i, j))

func rand_empty_space():
	while true:
		var position_idx = randi() % int(field_positions.size())
		var position = field_positions[position_idx]
		if get_child_at_position(position) == null:
			return position

func can_move_to(child_node, grid_pos):
	if turn != PLAYER_TYPE.HUMAN or child_node.is_moving:
		return false
	return grid_pos.x >= 0 and grid_pos.x < grid_size.x and grid_pos.y >= 0 and grid_pos.y < grid_size.y

func _on_Medic_movement_completed():
	turn = PLAYER_TYPE.ARTILLERY

func _on_Unit_rescued(unit):
	if unit != null:
		unit.queue_free()
		
func _on_Unit_dead(unit):
	if unit != null:
		var position = unit.position
		unit.queue_free()
		var dogtag = preload("res://Dogtag.tscn").instance()
		dogtag.position = position
		dogtag.connect("collected", self, "_on_Dogtag_collected")
		add_child(dogtag)
		
func _on_Helicopter_evacuated():
	print("Evacuated")
		
func _on_Helicopter_destroyed():
	var new_pos = rand_empty_space()
	$Helicopter.position = map_to_world(new_pos) + half_tile_size
		
func _on_Dogtag_collected(dogtag):
	if dogtag != null:
		dogtag.queue_free()
		
func _on_Artillery_position_struck(position):
	var autotile_coord = get_cell_autotile_coord(position.x, position.y)

	if autotile_coord.x < 3:
		if autotile_coord.y < 3:
			autotile_coord += Vector2(3,0)
	else:
		autotile_coord += Vector2(-3, 3)
		
	var child = get_child_at_position(position)
	if child != null:
		child.hit()

	set_cell(position.x, position.y, 0, false, false, false, autotile_coord)
	artillery_turn_count -= 1
	if artillery_turn_count <= 0:
		turn = PLAYER_TYPE.HUMAN

func get_child_at_position(position):
	var children = get_children()
	for child in children:
		var child_pos = world_to_map(child.position)
		if child_pos == position:
			return child
	return null

func get_tile_cost(position):
	var autotile_coord = get_cell_autotile_coord(position.x, position.y)
	if autotile_coord.y < 3:
		if autotile_coord.x < 3:
			return 1
		else:
			return 2
	else:
		return 3

func _process(delta):
	if turn == PLAYER_TYPE.ARTILLERY:
		if not $Artillery.is_striking:
			$Artillery.strike_array(field_positions)
	elif turn == PLAYER_TYPE.HUMAN:
		var direction = null
		if Input.is_action_pressed("ui_up"):
			direction = UP
		elif Input.is_action_pressed("ui_down"):
			direction = DOWN
		elif Input.is_action_pressed("ui_left"):
			direction = LEFT
		elif Input.is_action_pressed("ui_right"):
			direction = RIGHT
			
		if direction != null:
			var new_grid_pos = world_to_map($Medic.position) + direction
			if can_move_to($Medic, new_grid_pos):
				$Medic.move_to(map_to_world(new_grid_pos) + half_tile_size)
				artillery_turn_count = get_tile_cost(new_grid_pos)

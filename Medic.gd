extends KinematicBody2D

signal movement_completed

var is_moving = false
var target_position = Vector2()

const MAX_SPEED = 200

func _ready():
	pass

func _process(delta):
	if is_moving:
		var current_distance = position.distance_to(target_position)
		var direction = position.direction_to(target_position)
		var velocity = MAX_SPEED * direction.normalized() * delta
		var next_position = position + velocity
		var next_distance = next_position.distance_to(target_position)
		if next_distance > current_distance:
			position = target_position
			target_position = null
			is_moving = false
			emit_signal("movement_completed")
		else:
			move_and_collide(velocity)

func move_to(new_target_pos):
	target_position = new_target_pos
	is_moving = true
	
func hit():
	print("I'm DEAD!")

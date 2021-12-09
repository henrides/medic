extends Area2D

signal evacuated()
signal destroyed()

func _ready():
	connect("body_entered", self, "_on_Helicopter_body_entered")

func _on_Helicopter_body_entered(arg):
	emit_signal("evacuated")

func hit():
	emit_signal("destroyed")

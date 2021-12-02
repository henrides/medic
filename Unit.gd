extends Area2D

signal rescued(unit)
signal dead(unit)

func _ready():
	connect("body_entered", self, "_on_Unit_body_entered")

func _on_Unit_body_entered(arg):
	emit_signal("rescued", self)

func hit():
	emit_signal("dead", self)

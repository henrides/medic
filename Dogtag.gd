extends Area2D

signal collected(dogtag)

func _ready():
	connect("body_entered", self, "_on_Dogtag_body_entered")

func _on_Dogtag_body_entered(arg):
	emit_signal("collected", self)

func hit():
	print("Dogtag hit")

extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/Label2.text = "Score: " + str(Global.score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	get_tree().root.add_child.call_deferred(load("res://mainmenu.tscn").instantiate())
	queue_free()

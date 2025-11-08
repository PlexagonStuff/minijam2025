extends Node2D

var playerPosition = Vector2.ZERO
var buildingCount = 0
var combo = 0
var lastExplosion = Time.get_unix_time_from_system()
var score = 0
signal punch
signal buildingGoBoom
signal cameraTransition
# Called when the node enters the scene tree for the first time.
func _ready():
	buildingGoBoom.connect(
		func(buildingScale):
			var currentTime = Time.get_unix_time_from_system()
			if (currentTime - lastExplosion) < 4:
				combo = combo + 1
			else:
				combo = 0
			score += buildingScale * (max(1, combo))
			lastExplosion = currentTime
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

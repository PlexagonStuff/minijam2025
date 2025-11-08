extends Camera2D

#Based of the 3.x KidsCanCode implementation -> https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html

@export var decay := 0.8 #How quickly shaking will stop [0,1].
@export var max_offset := Vector2(50,75) #Maximum displacement in pixels.
@export var max_roll := 0.3 #Maximum rotation in radians (use sparingly).
@export var noise : FastNoiseLite #The source of random values.

var scaleIndex = 0
var scales = [Vector2(3,3), Vector2(2.5,2.5), Vector2(2,2), Vector2(1.5,1.5), Vector2(1,1), Vector2(0.5, 0.5), Vector2(0.25,0.25)]
var noise_y = 0 #Value used to move through the noise

var trauma := 0.0 #Current shake strength
var trauma_pwr := 3 #Trauma exponent. Use [2,3]

func _ready():
	Global.punch.connect(
		func():
			add_trauma(randf_range(0.3, 0.4))
	)
	Global.cameraTransition.connect(
		func():
			scaleIndex = scaleIndex + 1;
			var startZoom = zoom.x
			var tween = get_tree().create_tween()
			tween.tween_property(self, "zoom",scales[scaleIndex] , 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	)
	randomize()
	noise.seed = randi()

func add_trauma(amount : float):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
  #optional
	elif offset.x != 0 or offset.y != 0 or rotation != 0:
		lerp(rotation,0.0,1)

func shake(): 
	var amt = pow(trauma, trauma_pwr)
	noise_y += 1
	rotation = max_roll * amt * noise.get_noise_2d(noise.seed,noise_y)


func _physics_process(delta):
	global_position = Global.playerPosition
	if Global.combo < 2:
		$CanvasLayer/Score.text = "Score: " + str(floor(Global.score))
	else:
		$CanvasLayer/Score.text = "Score: " + str(floor(Global.score)) + " (x" + str(Global.combo) + ")"

extends CharacterBody2D


const SPEED = 300
const ACCELERATION = 200
var laserOn = false

var scalePossible = Vector2(0.2,0.2)
var damage = 1


func _ready():
	Global.buildingGoBoom.connect(
		func(buildingSize):
			Global.buildingCount -= 1
			if Global.buildingCount <= 0:
				get_tree().root.add_child.call_deferred(load("res://win_screen.tscn").instantiate())
				get_parent().queue_free()
			var previousScalePossible = scalePossible
			var scaleFactor = buildingSize * (1 + (Global.combo * 0.01))
			scale = scale + Vector2(scaleFactor / 150.0, scaleFactor / 150.0)
			if scale.x > 2:
				scale = Vector2(2, 2)
			damage += scaleFactor / 50.0
			scalePossible = scalePossible + Vector2(scaleFactor / 100.0, scaleFactor / 100.0)
			$PewPewLaser.value = $PewPewLaser.value + scaleFactor * 2

			if previousScalePossible.x < 0.3 && scalePossible.x > 0.3:
				Global.cameraTransition.emit()
			if previousScalePossible.x < 0.4 && scalePossible.x > 0.4:
				Global.cameraTransition.emit()
			if previousScalePossible.x < 0.5 && scalePossible.x > 0.5:
				Global.cameraTransition.emit()
			if previousScalePossible.x < 0.6 && scalePossible.x > 0.6:
				Global.cameraTransition.emit()
			if previousScalePossible.x < 0.7 && scalePossible.x > 0.7:
				Global.cameraTransition.emit()
			if previousScalePossible.x < 0.9 && scalePossible.x > 0.9:
				Global.cameraTransition.emit()
	)
func _physics_process(delta):
	$rotationPoint/Laser.visible = laserOn
	var x = -(get_global_mouse_position().x - global_position.x)
	var y = -(get_global_mouse_position().y - global_position.y)
	var angle = atan2(y, x)
	$rotationPoint.rotation = angle + PI
	if laserOn:
		var buildings = $rotationPoint/Laser.get_overlapping_areas()
		for buidling in buildings:
			print("Lasered?")
			if buidling.collision_layer == 2:
				if buidling.get_parent().scale.x <= scalePossible.x:
					Global.punch.emit()
					buidling.get_parent().hit_flash(damage)
	if Input.is_action_just_pressed("Click"):
		#print("Click pressed")
		$rotationPoint/Polygon2D.scale = Vector2(0, 0)
		$rotationPoint/Slash.visible = true
		#print(global_position.angle_to(get_global_mouse_position()))
		#$rotationPoint.rotation += rad_to_deg(global_position.angle_to(get_global_mouse_position()))
		
		var buildings = $rotationPoint/Slash.get_overlapping_areas()
		for buidling in buildings:
			if buidling.collision_layer == 2:
				if buidling.get_parent().scale.x <= scalePossible.x:
					Global.punch.emit()
					buidling.get_parent().hit_flash(damage)
		var tween = get_tree().create_tween()
		tween.tween_property($rotationPoint/Polygon2D, "scale",Vector2(1, 1) , 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property($rotationPoint/Polygon2D, "scale",Vector2(0,0) , 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_delay(0.4)
		tween.parallel().tween_callback(
			func():
				#print("tween ended")
				$rotationPoint/Slash.visible = false
		)
	
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction.x >= 0:
		$AnimatedSprite.flip_h = false
	else:
		$AnimatedSprite.flip_h = true
	velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	move_and_slide()
	Global.playerPosition = global_position



func _on_pew_pew_laser_value_changed(value):
	if value >= 90:
		laserOn = true
		$AnimatedSprite.play("Angry")
		$Timer.start()
		


func _on_timer_timeout():
	$PewPewLaser.value = 30
	$AnimatedSprite.play("Normal")
	laserOn = false

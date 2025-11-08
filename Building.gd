extends StaticBody2D
var health

var buildings = ["res://svg_medival_vector_buildings_v_0_1/building_blacksmith.svg", "res://svg_medival_vector_buildings_v_0_1/building_bonfire.svg", "res://svg_medival_vector_buildings_v_0_1/building_chapel.svg", "res://svg_medival_vector_buildings_v_0_1/building_cottage.svg", "res://svg_medival_vector_buildings_v_0_1/building_healertent.svg", "res://svg_medival_vector_buildings_v_0_1/building_hunter.svg",
"res://svg_medival_vector_buildings_v_0_1/building_lumberjack.svg", "res://svg_medival_vector_buildings_v_0_1/building_marketplace.svg", "res://svg_medival_vector_buildings_v_0_1/building_mine_copper.svg", "res://svg_medival_vector_buildings_v_0_1/building_mine_diamond.svg", "res://svg_medival_vector_buildings_v_0_1/building_mine_gold.svg", "res://svg_medival_vector_buildings_v_0_1/building_mine_iron.svg",
"res://svg_medival_vector_buildings_v_0_1/building_sawmill.svg", "res://svg_medival_vector_buildings_v_0_1/building_school.svg", "res://svg_medival_vector_buildings_v_0_1/building_stonemason.svg", "res://svg_medival_vector_buildings_v_0_1/building_tower.svg", "res://svg_medival_vector_buildings_v_0_1/building_vineyard.svg", "res://svg_medival_vector_buildings_v_0_1/building_wheat.svg", 
"res://svg_medival_vector_buildings_v_0_1/building_windmill.svg", "res://svg_medival_vector_buildings_v_0_1/building_woods.svg"]

@onready var polygon = $Polygon2D
# Called when the node enters the scene tree for the first time.
func _ready():
	createPolygon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func hit_flash(damage):
	$HitFlash.visible = true
	await get_tree().create_timer(0.2).timeout
	$HitFlash.visible = false
	health = health - damage
	if health <= 0:
		Global.buildingGoBoom.emit(scale.x * 10)
		explode()

func explode():
	var poly_points = polygon.polygon
	var triangles = Geometry2D.triangulate_polygon(poly_points)
	if triangles.is_empty():
		return
	
	# Create fragments from triangles
	for i in range(0, triangles.size(), 3):
		var tri_points = PackedVector2Array([
			poly_points[triangles[i]],
			poly_points[triangles[i + 1]],
			poly_points[triangles[i + 2]]
		])
		instantiateFragment(tri_points, polygon)
	queue_free()
	
func instantiateFragment(poly, polygon):
	print("Hello :)")
	var poly_instance = Polygon2D.new()
	var rigidBody = RigidBody2D.new()
	var despawnTimer = Timer.new()
	despawnTimer.timeout.connect(
		func():
			rigidBody.queue_free()
	)
	#print(poly)
	rigidBody.gravity_scale = 0
	poly_instance.polygon = poly
	poly_instance.uv = polygon.uv
	poly_instance.texture = polygon.texture
	rigidBody.global_position = polygon.global_position
	poly_instance.scale = scale
	rigidBody.scale = scale
	var center = (poly[0] + poly[1] + poly[2]) / 3.0
	var global_center = global_position + center
	
	# Apply radial impulse from explosion position
	var direction = (global_center - global_position).normalized()
	var distance = global_center.distance_to(global_position)
	var force_multiplier = 1.0 / max(distance / 100.0, 0.5)  # Closer = more force
	rigidBody.add_child(poly_instance)
	rigidBody.add_child(despawnTimer)
	rigidBody.apply_impulse(direction * 400 * force_multiplier, center)
	get_parent().add_child(rigidBody)
	despawnTimer.start(1)
	

func createPolygon():
	var imagePath = buildings.pick_random()
	var texture = load(imagePath)
	var image = texture.get_image()
	var height = image.get_height()
	var width = image.get_width()
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2(), bitmap.get_size()))
	#print(polygons.size())
	polygon.polygon = (polygons[0])#* Transform2D(0,Vector2(0.2,0.2), 0,Vector2.ZERO))
	$Area2D/CollisionPolygon2D.polygon =  (polygons[0])
	$CollisionPolygon2D.polygon = (polygons[0])
	$HitFlash.polygon = (polygons[0])#* Transform2D(0,Vector2(0.2,0.2), 0,Vector2.ZERO))
	polygon.uv = polygons[0]
	polygon.texture = texture
	


func _on_area_2d_area_entered(area):
	if scale.x < area.get_parent().scale.x && area.collision_layer == 2:
		print("area entered")
		queue_free()

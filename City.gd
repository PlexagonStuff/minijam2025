extends Node2D

var buildingNode = preload("res://building.tscn")
var p_radius = 75
var points = []
# Called when the node enters the scene tree for the first time.
func _ready():
	generateCity()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_triangle_circumcenter(a, b, c) -> Vector2:
	var d = 2.0 * (a.x * (b.y - c.y) +
				   b.x * (c.y - a.y) +
				   c.x * (a.y - b.y))
				
	var ux = ((a.x * a.x + a.y * a.y) * (b.y - c.y) +
			  (b.x * b.x + b.y * b.y) * (c.y - a.y) +
			  (c.x * c.x + c.y * c.y) * (a.y - b.y)) / d

	var uy = ((a.x * a.x + a.y * a.y) * (c.x - b.x) +
			  (b.x * b.x + b.y * b.y) * (a.x - c.x) +
			  (c.x * c.x + c.y * c.y) * (b.x - a.x)) / d

	return Vector2(ux, uy)

func generateCity():
	#Step 1: Use Poisson Disk Sampling to generate a list of nodes.
	print("Hello :)")
	var polyRegion = $CityBoundaries.polygon * Transform2D().scaled(Vector2(5, 5))
	points = PoissonDiscSampling.generate_points_for_polygon($CityBoundaries.polygon, p_radius, 30)
	var upscaledPoints = []
	var upscale_transform = Transform2D().scaled(Vector2(5, 5))
	for point in points:
		upscaledPoints.append(point * upscale_transform)
	points = upscaledPoints
	#points = Geometry2D.offset_polygon(points, 1000)[0]
	print(points)
	#Step 2: From this, greate a Delanuvay Triangulation
	var delaunay = Geometry2D.triangulate_delaunay(points)
	print(delaunay)
	#Step 3: From these triangles, grab the circumcenter of the triangle
	var triangles = []
	var index = 0
	while index < delaunay.size():
		var tri = {
			"points": [points[delaunay[index]],points[delaunay[index+1]],points[delaunay[index+2]]],
			"circumcenter": get_triangle_circumcenter(points[delaunay[index]],points[delaunay[index+1]],points[delaunay[index+2]])
		}
		if Geometry2D.is_point_in_polygon(tri["circumcenter"], polyRegion):	
			triangles.append(tri)
		index += 3
	print(triangles)
	var lines = []
	for i in range(triangles.size()):
		for j in range(i + 1, triangles.size()):
			var tri_a = triangles[i]
			var tri_b = triangles[j]
			var shared_vertices = 0
			for idx_a in tri_a["points"]:
				if idx_a in tri_b["points"]:
					shared_vertices += 1
			if shared_vertices == 2:
				lines.append([tri_a["circumcenter"], tri_b["circumcenter"]])
	var roads = []
	for line in lines:
		#var line = [centers[center], centers[center+1]]
		line = PackedVector2Array(line)
		var polygon = Polygon2D.new()
		polygon.polygon = Geometry2D.offset_polyline(line, 15, Geometry2D.JOIN_SQUARE,Geometry2D.END_ROUND)[0]
		roads.append(polygon.polygon)
		polygon.color = Color.DARK_GRAY
		add_child(polygon)
		
	#Step 5: Bake these roads into a navmesh
	#var navPoly = NavigationPolygon.new()
	#for road in range(roads.size()):
		#navPoly.add_outline(roads[road])
	##print(navPoly.outlines)
	##var source_geometry = NavigationMeshSourceGeometryData2D.new()
	##NavigationServer2D.bake_from_source_geometry_data(navPoly, source_geometry)
	#navPoly.make_polygons_from_outlines()
	#var navRegion = NavigationRegion2D.new()
	#navRegion.navigation_polygon = navPoly
	#add_child(navRegion)
	#Step 6: Spawn buildings alongside the roads :0
	var buildingPolygons = []
	
	for line in lines:
		var direction = line[0].direction_to(line[1])
		var startPoint = line[0] + (direction * randi_range(50, 75))
		#print(direction)
		while true:
			var to_end = line[1] - startPoint
			if direction.dot(to_end) <= 0:
				break
			var placingDirection
			var rotateFactor
			if randi_range(1,2) == 1:
				rotateFactor = -PI/2
				placingDirection = direction.rotated(-PI/2)
			else:
				rotateFactor = PI/2
				placingDirection = direction.rotated(PI/2)
			var placingOffset = startPoint + (placingDirection * randi_range(125, 200))
			var building = buildingNode.instantiate()
			building.global_position = placingOffset
			var scaleFactor = randi_range(2, 5) * 0.1
			building.health = (scaleFactor * 5 * 3)
			building.scale = Vector2(scaleFactor, scaleFactor)
			building.rotation = placingOffset.angle_to(startPoint)
			Global.buildingCount += 1
			add_child(building)
			
			startPoint += (direction * randi_range(50, 100))
	print("Hello :)")
			
	
	#Step 7: Add different NPCS or something to blow up

extends CollisionShape2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var path: WigglyAppendage2D    = $"../../Path"
	var points: PackedVector2Array = path.get_points()

	var new_points: Array[Variant] = []
	var radius: int                = 10  # Radius of the circle of points around each point in the path
	var num_points: int            = 10  # Number of points to generate around each point in the path

	for point in points:
		for i in range(num_points):
			var angle    = i * 2 * PI / num_points
			var x: float = point.x + radius * cos(angle)
			var y: float = point.y + radius * sin(angle)
			new_points.append(Vector2(x, y))

	var shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new()
	shape.set_points(new_points)
	self.set_shape(shape)


func _on_area_2d_area_entered(area):
	print("collision")
	pass

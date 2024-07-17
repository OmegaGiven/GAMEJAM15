extends Node2D


var objects_in_spawnable_location = []

func find_spawnable_location(x,y) -> Vector2:
	global_position.x = x
	global_position.y = y
	if len(objects_in_spawnable_location) == 0:
		return global_position
	else:
		print("Objects in position: ", objects_in_spawnable_location)
		return find_spawnable_location(x, y+1) #TODO adjust later to a good distance depending.

func _on_area_2d_body_entered(body):
	print("object entered: ",body)
	if body not in objects_in_spawnable_location:
		objects_in_spawnable_location.append(body)

func _on_area_2d_body_exited(body):
	if body in objects_in_spawnable_location:
		objects_in_spawnable_location.erase(body)

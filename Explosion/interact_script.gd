
extends Node

var do_explode = false
var explode_point
var pointMarker =  preload("res://PointMarker.xml")
var pcache = []
var explosion_force =20

func _ready():
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)
	pass


func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.pressed:
		explode_point = Vector2(event.x, event.y)
		do_explode = true


func _fixed_process(delta):
	if do_explode:
		do_explode = false
		refresh_point_markers()
		point_explode()


func point_explode():
	var radius = 300
	for body in get_children():
		# Only process RigidBody2D objects
		if body.get_type() != "RigidBody2D":
			continue
			
		var bodypos = body.get_pos()	
		var body_offset = bodypos - explode_point
		var mag = body_offset.length()
		
		# Ignore objects outside explosion radius.
		if mag > radius:
			continue
			
		# ray cast to objects from explosion point
		var point_of_force = cast_ray(explode_point, bodypos, body)
		
		# Only applie force to bodies with direct line of sight to explosion
		# Not very realistic, but intresting to do.
		if point_of_force != null:
			# mark the point of impact
			create_point_marker(point_of_force)
			
			# Get normalised force direction from explosion origin to body
			var force_direction = body_offset.normalized()
			# Ensure value of 1 or greater, so we don't divied by 0
			mag = max (mag, 1)
			# Reverse the length, so objects closer to explosion receive more force
			mag = radius / mag
			# sqaure the force, for expodential power
			mag = mag * mag
			
			# !IMPORTANT!
			# As apply_impulse takes a vector that is relative to the body,
			#  we offset point_of_force with the body's position.
			var body_relative_point = bodypos - point_of_force
			body.apply_impulse(body_relative_point, force_direction * mag * explosion_force)


func refresh_point_markers():
	for mark in pcache:
		mark.free()
	pcache = []


func create_point_marker(pos):
	var mark = pointMarker.instance()
	add_child(mark)
	mark.set_pos(pos)
	pcache.append(mark)


func cast_ray(origin, dest, target):
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_ray( origin, dest )
	if 'collider' in result and result['collider'] == target:
		return result['position']
	else:
		return null
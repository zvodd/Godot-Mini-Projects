
extends Node

var do_explode = false
var explode_point
var pointMarker = preload("res://prefabs/PointMarker.tscn")
var pcache = []
var explosion_force =20
var size = 1;
var maxforce = 700

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
		create_point_marker(explode_point)
		# Only process RigidBody2D objects
		if body.get_type() != "RigidBody2D":
			continue
			
		var bodypos = body.get_pos()	
		var body_offset = bodypos - explode_point
		var mag = body_offset.length()
		
		# Ignore objects outside explosion radius.
		if mag > radius:
			continue
		
		# Get normalised force direction from explosion origin to body
		var force_direction = body_offset.normalized()
		# Ensure value of 1 or greater, so we don't divied by 0
		mag = max (mag, 10)
		# Reverse the length, so objects closer to explosion receive more force
		mag = radius / mag
		# sqaure the force, for expodential power
		mag = mag * mag
		var finalforce = min(mag * explosion_force , maxforce)
		
		# !IMPORTANT!
		# As apply_impulse takes a vector that is relative to the body,
		#  we offset point_of_force with the body's position.
		var body_relative_point = force_direction *-1 * size
		body.apply_impulse(body_relative_point, force_direction * finalforce)


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
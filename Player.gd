extends KinematicBody2D

export (PackedScene) var Bullet

var speed = 500
var acceleration = 0.08
var friction = 0.08
var rotation_speed = 0.3

var velocity = Vector2.ZERO
var angle_rotation = Vector2.ZERO

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func get_input():
	var input = Vector2.ZERO

	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	return input
	

func get_rotation_input(input):
	angle_rotation.x = Input.get_action_strength("angle_right") - Input.get_action_strength("angle_left")
	angle_rotation.y = Input.get_action_strength("angle_down") - Input.get_action_strength("angle_up")
	
	if (angle_rotation == Vector2.ZERO && Input.is_action_pressed("shoot_mouse")):
		var mouse_angle = (get_global_mouse_position() - global_position).normalized().angle()
		rotation = lerp_angle(rotation, mouse_angle, rotation_speed * 2)
		return
	
	if (angle_rotation == Vector2.ZERO && input != Vector2.ZERO):
		angle_rotation = input

	if (angle_rotation != Vector2.ZERO):
		rotation = lerp_angle(rotation, angle_rotation.angle(), rotation_speed)

func _process(_delta):
	if (Input.is_action_pressed("shoot") || Input.is_action_pressed("shoot_mouse")):
		shoot()

func _physics_process(_delta):
	var input = get_input()
	get_rotation_input(input)
	
	if (input != Vector2.ZERO):
		input = input.normalized() * speed
		velocity = lerp(velocity, input, acceleration)
	else:
		velocity = lerp(velocity, Vector2.ZERO, friction)
	
	$Trace.process_material.set_gravity(Vector3(-velocity.x, -velocity.y, 0))
	if (velocity != Vector2.ZERO):
		$Trace.emitting = true
	else:
		$Trace.emitting = false
		
	velocity = move_and_slide(velocity)

func shoot():
	var b = Bullet.instance()
	
	if (velocity != Vector2.ZERO):
		b.speed += speed

	owner.add_child(b)
	b.transform = $Muzzle.global_transform


extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 15

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var linear_velocity = 0

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_right"):
		rotate_y(-PI / 2)
		linear_velocity = 0
	if Input.is_action_just_pressed("ui_left"):
		rotate_y(PI / 2)
		linear_velocity = 0
		
	if Input.is_action_just_pressed("ui_up"):
		linear_velocity = 1

	if Input.is_action_just_pressed("ui_down"):
		linear_velocity = 0

	velocity.x = sin(rotation.y) * linear_velocity
	velocity.z = cos(rotation.y) * linear_velocity
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

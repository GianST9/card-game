extends CharacterBody2D

#Constants
const MAX_SPEED = 400
const ACCELERATION = 1000
const FRICTION = 600

var input_vector = Vector2.ZERO

#animation tree (TODO not set up)
#@onready var animationTree : AnimationTree = $AnimationTree 

#States
enum {
	MOVE
}
var state = MOVE #initial state

func _ready():
	pass
	#for walking animation
	#animationTree.active = true
	
func _process(_delta):
	#for walking animation
	#update_animation_parameters()
	pass

#State machine 
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)

func get_input():
	#arrow key control
	input_vector.x = int(Input.get_action_strength("ui_right")) - int(Input.get_action_strength("ui_left"))
	input_vector.y = int(Input.get_action_strength("ui_down")) - int(Input.get_action_strength("ui_up"))
	return input_vector.normalized()
	
func move_state(delta):
	input_vector = get_input()
	
	if input_vector == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (input_vector * ACCELERATION * delta)	
		velocity = velocity.limit_length(MAX_SPEED)	
		
	move_and_slide() 	
	#current_camera()
	
	if Input.is_action_just_pressed("interact"): #"e" pressed
		#interaction logic
		pass

	#example change State by pressing "x"
	#if Input.is_action_just_pressed("x"):
	#		state = OTHER
	
###TODO: Animation Tree blender example setup
#func update_animation_parameters():
	#no inputs
	#if (velocity == Vector2.ZERO):
		#animationTree["parameters/conditions/idle"] = true
		#animationTree["parameters/conditions/is_moving"] = false
	#with input
	#else:
		#animationTree["parameters/conditions/idle"] = false
		#animationTree["parameters/conditions/is_moving"] = true
	#if (input_vector != Vector2.ZERO):
		#animationTree["parameters/Idle/blend_position"] = input_vector
		#animationTree["parameters/Run/blend_position"] = input_vector
		#animationTree["parameters/Attack/blend_position"] = input_vector
		#animationTree["parameters/Jump/blend_position"] = input_vector

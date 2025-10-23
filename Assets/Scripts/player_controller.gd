extends CharacterBody2D
class_name PlayerController

@export var move_speed = 35.0
@export var sprint_increase = 1.5

var direction : Vector2
var sprinting = false
var sprint_multiplier = 1.0

enum Facing {UP, DOWN, LEFT, RIGHT}
var player_facing : Facing = Facing.DOWN # Define um valor inicial

func _physics_process(delta):
	# 1. Pega o input
	direction = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		direction.y = -1
	elif Input.is_action_pressed("move_down"):
		direction.y = 1
		
	if Input.is_action_pressed("move_right"):
		direction.x = 1
	elif Input.is_action_pressed("move_left"):
		direction.x = -1

	# 2. LÓGICA DE 'FACING' CORRIGIDA
	#    Só atualiza o 'facing' se houver input.
	#    Isso "lembra" a última direção ao parar.
	if direction != Vector2.ZERO:
		if direction.x > 0:
			player_facing = Facing.RIGHT
		elif direction.x < 0:
			player_facing = Facing.LEFT
		elif direction.y < 0:
			player_facing = Facing.UP
		elif direction.y > 0:
			player_facing = Facing.DOWN
	
	# 3. Sprint
	if Input.is_action_pressed("sprint"):
		sprint_multiplier = sprint_increase
		sprinting = true
	else:
		sprint_multiplier = 1.0
		sprinting = false
	
	# 4. Movimento
	direction = direction.normalized()
	velocity = direction * move_speed * delta * 200 * sprint_multiplier
	move_and_slide()

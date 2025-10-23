extends Node2D

@export var player_controller : PlayerController
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

var default_animation_speed

func _ready():
	default_animation_speed = animation_player.speed_scale

# Renomeado para _delta para remover o aviso (opcional)
func _process(_delta):
	
	if player_controller.velocity.length() > 0.0:
		# --- LÓGICA DE ANDAR (move_left olha para ESQUERDA) ---
		if player_controller.player_facing == player_controller.Facing.DOWN:
			animation_player.play("move_down")
		elif player_controller.player_facing == player_controller.Facing.UP:
			animation_player.play("move_up")
		elif player_controller.player_facing == player_controller.Facing.RIGHT:
			animation_player.play("move_left")
			sprite_2d.flip_h = true # Espelha (ESQUERDA -> DIREITA)
		elif player_controller.player_facing == player_controller.Facing.LEFT:
			animation_player.play("move_left")
			sprite_2d.flip_h = false # Não espelha (ESQUERDA)
			
		if player_controller.sprinting:
			animation_player.speed_scale = default_animation_speed + player_controller.sprint_increase * .5
		else:
			animation_player.speed_scale = default_animation_speed
	else:
		# --- LÓGICA DE PARAR (idle_left olha para DIREITA) ---
		if player_controller.player_facing == player_controller.Facing.DOWN:
			animation_player.play("idle_down")
		elif player_controller.player_facing == player_controller.Facing.UP:
			animation_player.play("idle_up")
		elif player_controller.player_facing == player_controller.Facing.RIGHT:
			animation_player.play("idle_left")
			sprite_2d.flip_h = false # Não espelha (DIREITA)
		elif player_controller.player_facing == player_controller.Facing.LEFT:
			animation_player.play("idle_left")
			sprite_2d.flip_h = true # Espelha (DIREITA -> ESQUERDA)
			
		animation_player.speed_scale = default_animation_speed

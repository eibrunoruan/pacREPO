extends Node2D

@export var player_controller : PlayerController
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D

var default_animation_speed

func _ready():
	default_animation_speed = animation_player.speed_scale

func _process(delta):
	sprite_2d.flip_h = false
	if player_controller.velocity.length() > 0.0:
		# play movement animations
		if player_controller.player_facing == player_controller.Facing.DOWN:
			animation_player.play("move_down")
		elif player_controller.player_facing == player_controller.Facing.UP:
			animation_player.play("move_up")
		elif player_controller.player_facing == player_controller.Facing.RIGHT:
			animation_player.play("move_left")
			sprite_2d.flip_h = true
		elif player_controller.player_facing == player_controller.Facing.LEFT:
			animation_player.play("move_left")
		if player_controller.sprinting:
			animation_player.speed_scale = default_animation_speed + player_controller.sprint_increase * .5
		else:
			animation_player.speed_scale = default_animation_speed
	else:
		# play idle animations
		if player_controller.player_facing == player_controller.Facing.DOWN:
			animation_player.play("idle_down")
		elif player_controller.player_facing == player_controller.Facing.UP:
			animation_player.play("idle_up")
		elif player_controller.player_facing == player_controller.Facing.RIGHT:
			animation_player.play("idle_left")
			sprite_2d.flip_h = true
		elif player_controller.player_facing == player_controller.Facing.LEFT:
			animation_player.play("idle_left")
		animation_player.speed_scale = default_animation_speed

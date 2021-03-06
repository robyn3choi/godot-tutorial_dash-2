extends Node2D

signal dash_ended

const dash_delay = 0.4

onready var duration_timer = $DurationTimer
onready var ghost_timer = $GhostTimer
onready var dust_trail = $DustTrail
onready var dust_burst = $DustBurst

var ghost_scene = preload("res://DashGhost.tscn")
var can_dash = true
var sprite


func start_dash(sprite, duration, direction):
	duration_timer.wait_time = duration
	duration_timer.start()
	
	self.sprite = sprite
	sprite.material.set_shader_param("mix_weight", 0.7)
	sprite.material.set_shader_param("whiten", true)
	
	ghost_timer.start()
	instance_ghost()
	
	dust_trail.restart()
	dust_trail.emitting = true
	
	dust_burst.rotation = (direction * -1).angle()
	dust_burst.restart()
	dust_burst.emitting = true


func instance_ghost():
	var ghost: Sprite = ghost_scene.instance()
	get_parent().get_parent().add_child(ghost)

	ghost.global_position = global_position
	ghost.texture = sprite.texture
	ghost.vframes = sprite.vframes
	ghost.hframes = sprite.hframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	
	
func is_dashing():
	return !duration_timer.is_stopped()


func end_dash():
	emit_signal('dash_ended')
	sprite.material.set_shader_param("whiten", false)
	ghost_timer.stop()
	
	can_dash = false
	yield(get_tree().create_timer(dash_delay), 'timeout')
	can_dash = true


func _on_DurationTimer_timeout() -> void:
	end_dash()	


func _on_GhostTimer_timeout() -> void:
	instance_ghost()

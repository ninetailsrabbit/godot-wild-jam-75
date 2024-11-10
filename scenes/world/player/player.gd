class_name Player extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 25.0
@export var friction: float = 50.0
@export var health: int = 100

@onready var hurtbox_2d: Hurtbox2D = $Hurtbox2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_tree: AnimationTree = $AnimationTree


var motion_input: TransformedInput = TransformedInput.new(self)
var last_facing_direction: Vector2 = Vector2.DOWN

func _enter_tree() -> void:
	collision_layer = GameGlobals.player_collision_layer


func _ready() -> void:
	animation_tree.active = true
	## Change the time scale value for animations, combine with player speed for better results.
	animation_tree.set("parameters/TimeScale/scale", 1.0)
	
	
func _physics_process(delta: float) -> void:
	motion_input.update()
	
	if not motion_input.previous_input_direction.is_zero_approx():
		last_facing_direction = motion_input.previous_input_direction
	
	animation_tree.set("parameters/Player States/Idle/blend_position", last_facing_direction)
	animation_tree.set("parameters/Player States/Walk/blend_position", last_facing_direction)

	if motion_input.input_direction.is_zero_approx():
		velocity = velocity.lerp(Vector2.ZERO, friction * delta) if friction > 0 else Vector2.ZERO
	else:
		velocity = velocity.lerp(motion_input.input_direction * speed, acceleration * delta) if acceleration > 0 else motion_input.input_direction * speed
	
	move_and_slide()

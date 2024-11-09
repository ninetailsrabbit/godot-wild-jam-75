class_name Player extends CharacterBody2D

@export var speed: float = 300.0
@export var acceleration: float = 25.0
@export var friction: float = 20.0
@export var health: int = 100

@onready var hurtbox_2d: Hurtbox2D = $Hurtbox2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_tree: AnimationTree = $AnimationTree


var motion_input: TransformedInput = TransformedInput.new(self)
var last_facing_direction: Vector2 = Vector2.RIGHT


func _physics_process(delta: float) -> void:
	last_facing_direction = velocity.normalized()
	motion_input.update()
	
	velocity = velocity.lerp(motion_input.input_direction * speed, acceleration * delta)
	
	move_and_slide()
	
	animation_tree.set("parameters/blend_position", velocity.normalized())
	

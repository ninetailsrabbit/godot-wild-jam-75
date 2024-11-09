class_name Bullet extends Node2D

const GroupName = "bullets"

@export var damage: int = 10
@export var impact_force: Vector2 = Vector2.ONE
@export_range(0, 100.0, 0.01) var trace_display_chance: float = 50.0
@export var direction: Vector2
@export var speed: float = 10.0
@export var delete_after_seconds: float = 2.5

@onready var hitbox_2d: Hitbox2D = $Hitbox2D
@onready var shape_area: Area2D = $ShapeArea
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var timer: Timer = $Timer


func _enter_tree() -> void:
	add_to_group(GroupName)
	

func _physics_process(delta: float) -> void:
	global_position += speed * direction
	

func _ready() -> void:
	shape_area.monitoring = true
	shape_area.monitorable = true
	shape_area.priority = 1
	shape_area.collision_layer = GameGlobals.bullets_collision_layer
	shape_area.collision_mask = GameGlobals.world_collision_layer | GameGlobals.bullets_collision_layer
	

	if delete_after_seconds > 0 and is_instance_valid(timer):
		timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		timer.wait_time = delete_after_seconds
		timer.one_shot = true
		timer.timeout.connect(on_timer_timeout)
		timer.start()
	
	#visible_on_screen_notifier_2d.screen_exited.connect(on_screen_exited)
	

func on_timer_timeout() -> void:
	print("bullet timeout")
	
	if not is_queued_for_deletion():
		queue_free()


func on_screen_exited() -> void:
	timer.stop()
	print("screen exited")
	if not is_queued_for_deletion():
		queue_free()

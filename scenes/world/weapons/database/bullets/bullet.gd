class_name Bullet extends RigidBody2D

const GroupName = "bullets"

@export var damage: int = 10
@export var impact_force: Vector2 = Vector2.ONE
@export_range(0, 100.0, 0.01) var trace_display_chance: float = 50.0
@export var direction: Vector2
@export var speed: float = 500.0
@export var delete_after_seconds: float = 5.0

@onready var hitbox_2d: Hitbox2D = $Hitbox2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var timer: Timer = $Timer

var origin_weapon: FirearmWeapon
var distance_traveled: float = 0.0
var is_mirrored: bool = false


func _enter_tree() -> void:
	add_to_group(GroupName)
	
	contact_monitor = true
	max_contacts_reported = 1
	gravity_scale = 0
	lock_rotation = true
	
	body_entered.connect(on_body_entered)


func _ready() -> void:
	if not is_mirrored:
		global_position = origin_weapon.barrel_marker.global_position
		look_at(get_global_mouse_position())
	
	if direction.is_zero_approx():
		direction = global_position.direction_to(get_global_mouse_position())
	
	collision_layer = GameGlobals.bullets_collision_layer
	collision_mask = GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer
	
	if delete_after_seconds > 0 and is_instance_valid(timer):
		timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		timer.wait_time = delete_after_seconds
		timer.one_shot = true
		timer.timeout.connect(on_timer_timeout)
		timer.start()
	
	visible_on_screen_notifier_2d.screen_exited.connect(on_screen_exited)
	
	apply_impulse(direction * impact_force * speed, -position)


func _physics_process(_delta: float) -> void:
	distance_traveled = NodePositioner.global_distance_to_v2(origin_weapon, self)

## Use as data when the hurtbox detects this hitbox to calculate the damage
func collision_damage() -> float:
	var total_damage = origin_weapon.configuration.fire.shoot_damage + damage
	
	if distance_traveled <= origin_weapon.configuration.bullet.close_distance_to_apply_damage_multiplier:
		total_damage *= origin_weapon.configuration.bullet.close_distance_damage_multiplier
	
	if origin_weapon.configuration.fire.multiplier_for_distance_traveled.size() > 1:
		var distance_splitted: int = ceil(distance_traveled / origin_weapon.configuration.bullet.multiplier_for_distance_traveled[0])
		
		for i in range(distance_splitted):
			total_damage *= origin_weapon.configuration.bullet.multiplier_for_distance_traveled[1]
	
	return total_damage


func mirror() -> Bullet:
	var duplicated: Bullet = self.duplicate()
	duplicated.origin_weapon = origin_weapon
	duplicated.is_mirrored = true
	
	return duplicated
	

func on_body_entered(other_body: Node) -> void:
	hide()
	## TODO - HANDLE THE IMPACT BASED ON THE OTHER BODY
	if not is_queued_for_deletion():
		queue_free()
		

func on_timer_timeout() -> void:
	if not is_queued_for_deletion():
		queue_free()


func on_screen_exited() -> void:
	timer.stop()
	
	if not is_queued_for_deletion():
		queue_free()

class_name FirearmWeaponHolder extends Node2D

signal dropped_weapon(weapon: FirearmWeapon)
signal changed_weapon(from: WeaponDatabase.WeaponRecord, to: WeaponDatabase.WeaponRecord)
signal stored_weapon(weapon: WeaponDatabase.WeaponRecord)
signal drawed_weapon(weapon: WeaponDatabase.WeaponRecord)


@export var gun_pivot_point: Marker2D
@onready var reload_timer: Timer = $ReloadTimer


@export var slots: Dictionary = {
	InputControls.PrimaryWeapon: "",
	InputControls.SecondaryWeapon: "",
	InputControls.HeavyWeapon: "",
	InputControls.MeleeWeapon: "",
}

@export var weapon_positions_from_pivot: Dictionary = {
	## Example, this is the weapon position to move when equipped, always keep FireArmWeaponHolder node on Vector3.Zero
	#WeaponDatabase.IdentifierRifleAr15: Vector3(0.23, -0.215, -0.5),
	WeaponDatabase.IdentifierRevolver: Vector2(10, -4)
}


enum WeaponHolderStates {
	Draw,
	Store,
	Neutral,
	Dismantle
}

var current_state: WeaponHolderStates = WeaponHolderStates.Neutral:
		set(value):
			if value != current_state:
				current_state = value
				set_physics_process(current_state == WeaponHolderStates.Neutral)
				set_process_unhandled_input(current_state in [WeaponHolderStates.Neutral, WeaponHolderStates.Dismantle])
	
var current_weapon: WeaponDatabase.WeaponRecord:
	set(value):
		if value != current_weapon:
			current_weapon = value
			
			if current_weapon == null:
				current_state = WeaponHolderStates.Dismantle
			else:
				current_state = WeaponHolderStates.Neutral
				
var smoothed_mouse_position: Vector2 = Vector2.ZERO
var apply_rotation_angle_limit: bool = false
var angle: float = 0.0
var rotation_speed: float = 10.0
var orbit_speed = 7.5
var radius = 7.5


func _unhandled_input(_event: InputEvent) -> void:
	if current_state == WeaponHolderStates.Neutral:
		for input_action: String in slots.keys():
			if WeaponDatabase.exists(slots[input_action]) and InputHelper.action_just_pressed_and_exists(input_action):
				change_weapon_to(slots[input_action])
				break
	

func _ready() -> void:
	## TODO - TEMPORARY
	assign_primary_weapon_slot(WeaponDatabase.IdentifierRevolver)
	

func _physics_process(delta):
	if current_weapon:
		smoothed_mouse_position = lerp(
			smoothed_mouse_position, 
			get_global_mouse_position(), 
			delta * current_weapon.configuration.rotation_speed
		)
		
		look_at(smoothed_mouse_position)
		
		## Flip sprite when rotate on the other plane
		var result = cos(rotation) < 0.0
		
		if result != current_weapon.scene.sprite.flip_v:
			current_weapon.scene.sprite.flip_v = result
		
		
func change_weapon_to(id: StringName) -> void:
	if current_weapon and current_weapon.id == id:
		return
	
	var previous_weapon = current_weapon
	var new_weapon: WeaponDatabase.WeaponRecord = WeaponDatabase.get_weapon(id)
	
	if previous_weapon != null:
		await unequip_current_weapon()

	await equip_new_weapon(new_weapon)
	
	if previous_weapon and new_weapon:
		changed_weapon.emit(previous_weapon, new_weapon)


		
func equip_new_weapon(new_weapon: WeaponDatabase.WeaponRecord) -> void:
	if not new_weapon.scene.is_inside_tree():
		gun_pivot_point.add_child(new_weapon.scene)
		new_weapon.scene.position = weapon_positions_from_pivot[new_weapon.id]
	
	current_weapon = new_weapon
	
	#await current_weapon.draw_animation()
	
	current_state = WeaponHolderStates.Neutral


func unequip_current_weapon() -> void:
	if current_weapon:
		current_state = WeaponHolderStates.Store
		
		#await weapon.store_animation()
		#weapon.hide()
		#weapon.process_mode = Node.PROCESS_MODE_DISABLED
		#
	
		current_weapon = null
		
		stored_weapon.emit(current_weapon)
		

func assign_primary_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.PrimaryWeapon] = id


func assign_secondary_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.SecondaryWeapon] = id


func assign_heavy_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.HeavyWeapon] = id


func assign_melee_weapon_slot(id: StringName) -> void:
	if WeaponDatabase.exists(id):
		slots[InputControls.MeleeWeapon] = id

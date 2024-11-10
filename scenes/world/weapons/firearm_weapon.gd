class_name FirearmWeapon extends Node2D

const GroupName = "firearm-weapons"

signal stored
signal drawed
signal fired
signal reloaded
signal out_of_ammo

@export var configuration: FireArmWeaponConfiguration
@export var use_fire_timer: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var barrel_marker: Marker2D = $BarrelMarker
@onready var muzzle_marker: Marker2D = $MuzzleMarker


enum CombatStates {
	Neutral,
	Fire,
	Reload,
}


var current_state: CombatStates = CombatStates.Neutral

var fire_timer: float = 0.0
var fire_impulse_timer: float = 0.0
var original_position: Vector2 = Vector2.ZERO

var active: bool = true:
	set(value):
		if value != active:
			active = value
			
			set_physics_process(active)
			set_process_unhandled_input(active)


func _physics_process(delta: float) -> void:
	if use_fire_timer and fire_timer < configuration.fire.fire_rate:
		fire_timer += delta
		
	match configuration.fire.burst_type:
		configuration.fire.BurstTypes.Single:
			if InputHelper.action_just_pressed_and_exists(InputControls.Shoot):
				shoot()


func _ready() -> void:
	original_position = position
	
	
func flip_sprite(on_left_plane: bool) -> void:
	## A short approach to flip the sprite without the need of modify positions of other nodes
	if on_left_plane and sign(scale.y) != -1:
		scale.y *= -1
			
	elif not on_left_plane and sign(scale.y) != 1:
		scale.y *= -1
	
	#if result != sprite.flip_v:
		#sprite.flip_v = result
		#barrel_marker.position.y *= -1
		#muzzle_marker.position.y *= -1
		#
		#if sprite.flip_v:
			#position.y = -position.x / 2.0 if sprite.flip_v else original_position.y


func shoot() -> void:
	if _can_shoot(use_fire_timer):
		current_state = CombatStates.Fire
		
		configuration.ammo.current_ammunition -= configuration.fire.bullets_per_shoot
		configuration.ammo.current_magazine -= configuration.fire.bullets_per_shoot
		fire_timer = 0.0
		
		spawn_bullet()
		
		fired.emit()
		
	if configuration.fire.auto_reload_on_empty_magazine and configuration.ammo.magazine_empty():
		reload()


func spawn_bullet() -> void:
	var bullet: Bullet = configuration.bullet.scene.instantiate() as Bullet
	bullet.origin_weapon = self
	
	get_tree().current_scene.add_child(bullet)
	

func reload() -> void:
	if configuration.ammo.can_reload() and not current_state == CombatStates.Reload:
		current_state = CombatStates.Reload
		
		var ammo_needed = configuration.ammo.magazine_size - configuration.ammo.current_magazine
		
		## If there is more ammunition available than the current cartridge
		if configuration.ammo.current_ammunition >= ammo_needed:
			configuration.ammo.current_magazine = ammo_needed
			configuration.ammo.current_ammunition -= ammo_needed
			
		else: ## If the available ammunition is less than the ammunition needed to reload, the remaining ammunition is taken.
			configuration.ammo.current_magazine = configuration.ammo.current_ammunition
			configuration.ammo.current_ammunition = 0
		
		await reload_animation()
		
		reloaded.emit()
		
		current_state = CombatStates.Neutral


func reload_animation() -> void:
	pass


func _can_shoot(use_fire_timer: bool = true) -> bool:
	if not active:
		return false
		
	if use_fire_timer and fire_timer < configuration.fire.fire_rate:
		return false
		
	if current_state == CombatStates.Reload:
		return false
		
	if not configuration.ammo.has_ammunition_to_shoot():
		out_of_ammo.emit()
		return false
		
	return true

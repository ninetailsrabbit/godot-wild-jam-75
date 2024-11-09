class_name FireArmWeaponConfiguration extends Resource


@export var id: StringName
@export var name: String = ""
@export var description: String = ""
@export var rotation_speed: float = 15.0
@export_range(0, 100, 0.1) var durability: float = 95.0
@export_range(0, 100, 0.1) var accuracy: float = 90.0
@export_group("Configuration")
@export var ammo: FireArmWeaponAmmo
@export var bullet: FireArmWeaponBullet
@export var fire: FireArmWeaponFire
@export_group("Muzzle flash")
@export var muzzle_texture: Texture2D
@export var muzzle_lifetime: float = 0.03
@export var muzzle_min_size: Vector2 = Vector2(0.05, 0.05)
@export var muzzle_max_size: Vector2 = Vector2(0.35, 0.35)
@export var muzzle_emit_on_ready: bool = true
@export var muzzle_spawn_light: bool = true
@export var muzzle_light_lifetime: float = 0.01
@export_range(0, 16, 0.1) var muzzle_min_light_energy: float = 1.0
@export_range(0, 16, 0.1) var muzzle_max_light_energy: float = 1.0
@export var muzzle_light_color: Color = Color("FFD700")

class_name WeaponDatabase

#region Weapon IDs
## EXAMPLE
#const IdentifierPistol9MM: StringName = &"9mm"
const IdentifierRevolver: StringName = &"revolver"
#endregion

#region Preloads
const RevolverScene: PackedScene = preload("res://scenes/world/weapons/database/guns/revolver/revolver.tscn")
const RevolverConfiguration: FireArmWeaponConfiguration = preload("res://scenes/world/weapons/database/guns/revolver/revolver_configuration.tres")
#endregion

#region Weapon categories
enum WeaponCategory {
	Pistol,
	Revolver,
	AssaultRifle,
	SubMachineGun,
	SniperRifle,
	Shotgun,
	Grenades,
	RocketLauncher,
	Melee,
	MeleeBlunt,
	MeleeSharpen
}
#endregion


class WeaponRecord:
	var id: StringName
	var scene: FirearmWeapon
	var configuration: FireArmWeaponConfiguration
	var category: WeaponCategory
	
	func _init(_id: StringName, _scene: FirearmWeapon, _configuration: Resource, weapon_category: WeaponCategory) -> void:
		id = _id
		scene = _scene
		configuration = _configuration
		category = weapon_category


static var available_weapons: Dictionary = {
	## EXAMPLE
	#IdentifierPistol9MM: WeaponRecord.new(IdentifierPistol9MM, Preloader.Pistol9MM.instantiate(), Preloader.Pistol9MMConfiguration, WeaponCategory.Pistol),
	IdentifierRevolver: WeaponRecord.new(IdentifierRevolver, RevolverScene.instantiate(), RevolverConfiguration, WeaponCategory.Pistol),
}


static func get_weapon(id: StringName) -> WeaponRecord:
	assert(exists(id), "WeaponDatabase: The weapon id %s does not exists, weapon cannot be retrieved and equipped" % id)
	
	return available_weapons.get(id)


static func exists(id: StringName) -> bool:
	return available_weapons.has(id)

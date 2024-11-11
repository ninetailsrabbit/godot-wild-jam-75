class_name Mirror extends Node2D

const MirrorImpactWavesShader: Shader = preload("res://shaders/shield_impact_waves.gdshader")

@export var mesh_instance: MeshInstance2D
@export var duplicate_enemies: bool = true
@export var duplicate_player: bool = true
@export var number_of_uses_per_charge: int = 10
@export var recharge_time: int = 3
@export var top_color: Color = Color.DARK_RED
@export var bottom_color: Color = Color.DARK_GRAY


var detection_area: Area2D
var shader_material: ShaderMaterial = ShaderMaterial.new()


func _ready() -> void:
	if mesh_instance == null:
		mesh_instance = NodeTraversal.first_node_of_type(self, MeshInstance2D.new())
	
	assert(mesh_instance is MeshInstance2D, "Mirror: This mirror needs a MeshInstance2D to works properly and prepare the detection area")
		
	_prepare_detection_area()
	_prepare_shader_material()

## To override on inherited classes
func apply_enter_effect(other_body: Node) -> void:
	pass


func apply_exit_effect(other_body: Node) -> void:
	pass


func _prepare_detection_area() -> void:
	detection_area = Area2D.new()
	detection_area.name = "DetectionArea"
	detection_area.collision_layer = GameGlobals.mirrors_collision_layer
	detection_area.collision_mask = GameGlobals.player_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.bullets_collision_layer
	detection_area.priority = 1
	detection_area.monitorable = false
	detection_area.monitoring = true
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CapsuleShape2D.new()
	collision_shape.shape.radius = mesh_instance.mesh.radius
	collision_shape.shape.height = mesh_instance.mesh.height
	
	detection_area.add_child(collision_shape)
	mesh_instance.add_child(detection_area)
	
	detection_area.body_entered.connect(on_body_detected)
	detection_area.body_exited.connect(on_body_exited)
	

func _prepare_shader_material() -> void:
	shader_material.shader = MirrorImpactWavesShader
	shader_material.set_shader_parameter("shield_tint", top_color)
	shader_material.set_shader_parameter("shield_saturation", bottom_color)
	
	mesh_instance.material = shader_material
	

func on_body_detected(other_body: Node) -> void:
	call_deferred("apply_enter_effect",other_body)


func on_body_exited(other_body: Node) -> void:
	call_deferred("apply_exit_effect",other_body)
	

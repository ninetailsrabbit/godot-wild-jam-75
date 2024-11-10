class_name Mirror extends Node2D


@export var mesh_instance: MeshInstance2D
@export var duplicate_enemies: bool = true
@export var duplicate_player: bool = true
@export var number_of_uses_per_charge: int = 10
@export var recharge_time: int = 3


var detection_area: Area2D

func _ready() -> void:
	if mesh_instance == null:
		mesh_instance = NodeTraversal.first_node_of_type(self, MeshInstance2D.new())
	
	assert(mesh_instance is MeshInstance2D, "Mirror: This mirror needs a MeshInstance2D to works properly and prepare the detection area")
		
	_prepare_detection_area()


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
	

func on_body_detected(other_body: Node) -> void:
	print("other body success ", other_body)

class_name GunSpriteRotator extends Sprite2D

@onready var parent = get_parent()

func _process(_delta):
	if parent:
		var result =  cos(parent.rotation) < 0.0
		
		if result != flip_v:
			flip_v = result

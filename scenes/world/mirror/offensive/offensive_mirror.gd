class_name OffensiveMirror extends Mirror



func apply_exit_effect(other_body: Node) -> void:
	if other_body is Bullet:
		var duplicated_bullet: Bullet = other_body.mirror() as Bullet
		duplicated_bullet.direction = other_body.direction.rotated(PI / 4)
		
		get_tree().root.add_child(duplicated_bullet)

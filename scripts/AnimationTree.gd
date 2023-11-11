extends AnimationTree

func setAnimation(animation):
	get_tree_root().get_node("MainAnimation").animation = animation

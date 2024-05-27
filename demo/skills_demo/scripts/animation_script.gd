extends Node
class_name AnimationScript

@export var anim_tree: AnimationTree

func play_animation(path: String, val):
	anim_tree.set(path, val)

func play_blend(parameter: String, blend: float):
	anim_tree.set("parameters/" + parameter + "/blend", blend)

func play_blend_clamped(parameter: String, blend: float):
	blend = clamp(blend, 0, 1)
	play_blend(parameter, blend)

func play_oneshot(parameter: String):
	anim_tree.set("parameters/" + parameter + "/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
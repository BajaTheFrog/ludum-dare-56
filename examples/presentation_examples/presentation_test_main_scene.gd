extends Node
# PresentationTest-MainScene

var title_context_scene = preload("res://examples/presentation_examples/presentation_test_title_scene.tscn")
var gameplay_context_scene = preload("res://examples/presentation_examples/presentation_test_game_scene.tscn")

onready var context_root = $ContextRoot

func _ready():
	# wire up the preloaded scenes
	var context_scene_dictionary = { 
		"title" : title_context_scene, 
		"gameplay" : gameplay_context_scene
		}
		
	PresentationServices.context_service.context_root = context_root
	PresentationServices.context_service.load_with_context_scene_dictionary(context_scene_dictionary)
	PresentationServices.context_service.go_to("title")

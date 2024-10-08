extends Node2D

onready var spawner_2D = $Spawner2D

func _ready():
	spawner_2D.spawn()


func _on_Spawner2D_node_spawned(spawned_node):
	(spawned_node as Node).connect("tree_exited", self, "_on_node_exiting_tree")


func _on_node_exiting_tree():
	yield(Wait.on(self, 1.0), Wait.END)
	spawner_2D.spawn()

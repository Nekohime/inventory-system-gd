# inventory-system-gd

An inventory system for the Godot Engine (4.x)  

(Work in Progress, mostly a backup - also comes with a test UI)  

CC0-licensed.  

Usage:

```gdscript
var Inventory = load("scripts/Inventory.gd")
var pinv: Inventory

func _ready() -> void:
	pinv = Inventory.new()
	pinv.set_inventory("res://data/player.json")
	pinv.give_item("strawberry", 2)
	pinv.give_item("useless_dust", 10)
	pinv.take_item("strawberry", 1)
	pinv.take_item("useless_dust", 5)

	if pinv.has_item("useless_dust") >= 6:
		print("beep!")
```

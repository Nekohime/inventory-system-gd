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

API:

```gdscript
    func set_inventory(file) -> void
    func give_item(id: String, amount: int = 1, item_data = null) -> void
    func take_item(id, amount: int = 1) -> void
    func take_item_at_index(idx: int, amount: int = 1) -> void
    func set_itemdb() -> void
    func get_item_db() -> Dictionary
    func get_item_from_db(id) -> Dictionary
    func get_inventory() -> Array
    func get_inventory_size() -> int
    func has_item(id) -> int
    func get_item_at_index(idx) -> Dictionary
    func get_item_name(item) -> String
    func get_item_type(item) -> String
    func get_item_quality(item) -> String
    func get_item_examine(item) -> String
    func get_item_amount(item) -> int
    func get_item_data(item) -> Dictionary
    func get_food_health(item) -> int
    func get_json(path) -> Dictionary
    func save_player_inventory() -> void
    func unit_test() -> void
```

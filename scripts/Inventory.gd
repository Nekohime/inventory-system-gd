# In an Autoload
extends Control

var itemdb: Dictionary
var player_data: Dictionary
var inventory: Array
var is_item_debugging: bool = false

# TODO: Item modifiers in give_item (enchantments, names, etc.)
#  take_item(?) and has_item logic to handle modified items?

func unit_test(): # Assume empty inventory

	Inventory.give_item("strawberry", 2)
	print("Strawberries: 0 PLUS 2 == 2: " + str(Inventory.has_item("strawberry") == 2))

	Inventory.take_item("strawberry", 2)
	print("Strawberries: 2 MINUS 2 == 0: " + str(Inventory.has_item("strawberry") == 0))

	Inventory.take_item("strawberry", 1)
	print("Strawberries: 0 MINUS 1 == 0: " + str(Inventory.has_item("strawberry") == 0))


	Inventory.give_item("useless_dust", 4)

	print("Useless Dust: 0 PLUS 4 == 4: " + str(Inventory.has_item("useless_dust") == 4))

	Inventory.take_item("useless_dust", 2)
	print("Useless Dust: 4 MINUS 2 == 2: " + str(Inventory.has_item("useless_dust") == 2))

	Inventory.take_item("useless_dust", 2)
	print("Useless Dust: 2 MINUS 2 == 0: " + str(Inventory.has_item("useless_dust") == 0))

	Inventory.take_item("useless_dust", 3)
	print("Useless Dust: 0 MINUS 3 == 0: " + str(Inventory.has_item("useless_dust") == 0))

func _ready():
	load_data()
	#unit_test()

func load_data():
	itemdb = Global.get_json("res://data/items.json")
	player_data = Global.get_json("res://data/player.json")
	inventory = player_data.items  #Sugar

func give_item(id, amount: int = 1):
	if itemdb[id].stackable: # Item is Stackable
		var existing_stack = null

		for item in inventory: # Iterate through Player Item Stacks
			if item["id"] == id:
				existing_stack = item # We already have a stack of this item!
				break

		if existing_stack: # We already have a stack of this item!
			existing_stack["amount"] += amount
		else: # We create a new stack
			inventory.append({"id": id, "amount": amount})
	else: # Item is NOT Stackable
		for i in range(amount):
			inventory.append({"id": id})

	if !is_item_debugging:
		save_player_data() # Save player data to file


func take_item(id, amount: int = 1):
	var total_of_item_stack = 0
	var indices_to_remove = []

	for i in range(inventory.size()):
		var item = inventory[i]
		if item.id != id:
			continue

		if itemdb[id].stackable:
			item.amount -= amount
			if item.amount <= 0:
				indices_to_remove.append(i)
			break
		else:
			indices_to_remove.append(i)
			total_of_item_stack += 1
			if total_of_item_stack >= amount:
				break

	# Remove the items after the loop has completed.
	while indices_to_remove.size() > 0:
		var index = indices_to_remove.pop_back()
		inventory.remove_at(index)

	if !is_item_debugging:
		save_player_data() # Save player data to file

func has_item(id) -> int:
	var total_amount = 0

	for item in inventory:
		if item["id"] == id:
			if itemdb[id].stackable:
				total_amount += item["amount"]
			else:
				total_amount += 1

	return total_amount

func get_item_db() -> Dictionary:
	return itemdb

func get_inventory() -> Array:
	return inventory

func get_item_at_index(idx) -> Dictionary:
	return inventory[idx]

func get_item_name(item) -> String:
	return itemdb[item.id].name

func get_item_type(item) -> String:
	return itemdb[item.id].type

func get_item_quality(item) -> String:
	return itemdb[item.id].quality

func get_item_examine(item) -> String:
	return itemdb[item.id].examine

func get_item_amount(item) -> int:
	return has_item(item.id)

func get_item_data(item) -> Dictionary:
	if "data" in item:
		return item.data
	else:
		return {}

func get_food_health(food_item) -> int:
	return itemdb[food_item.id].health

func save_player_data():
	var file = FileAccess.open("res://data/player.json", FileAccess.WRITE)
	var json = JSON.stringify(player_data)
	file.store_string(json)

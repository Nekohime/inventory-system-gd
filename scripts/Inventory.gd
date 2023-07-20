class_name Inventory

var itemdb: Dictionary
var player_data: Dictionary
var inventory: Array
var is_item_debugging: bool = false
var inventory_file: String

# TODO: Item modifiers in give_item (enchantments, names, etc.)
#  take_item(?) and has_item logic to handle modified items?

func unit_test() -> void: # Assume empty inventory

	self.give_item("strawberry", 2)
	print("Strawberries: 0 PLUS 2 == 2: " + str(self.has_item("strawberry") == 2))

	self.take_item("strawberry", 2)
	print("Strawberries: 2 MINUS 2 == 0: " + str(self.has_item("strawberry") == 0))

	self.take_item("strawberry", 1)
	print("Strawberries: 0 MINUS 1 == 0: " + str(self.has_item("strawberry") == 0))


	self.give_item("useless_dust", 4)

	print("Useless Dust: 0 PLUS 4 == 4: " + str(self.has_item("useless_dust") == 4))

	self.take_item("useless_dust", 2)
	print("Useless Dust: 4 MINUS 2 == 2: " + str(self.has_item("useless_dust") == 2))

	self.take_item("useless_dust", 2)
	print("Useless Dust: 2 MINUS 2 == 0: " + str(self.has_item("useless_dust") == 0))

	self.take_item("useless_dust", 3)
	print("Useless Dust: 0 MINUS 3 == 0: " + str(self.has_item("useless_dust") == 0))


func set_itemdb() -> void:
	self.itemdb = self.get_json("res://data/items.json")

func _ready() -> void:
	if is_item_debugging:
		unit_test()
	#print(get_item_at_index(3), " - Heals: ", get_item_healing(get_item_at_index(3)))

# Sets Inventory to be handled in the class instance
# TODO: Handle different types of inventories (chests, bank, floor drops, etc.)
func set_inventory(file):
	self.set_itemdb()

	self.inventory_file = file
	self.inventory = self.get_json(self.inventory_file).items

func get_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

	#player_data = self.get_json("res://data/player.json")
	#set_inventory(player_data.items)

# This function gives the player an item or adds to an existing stack if the item is stackable.
# If the item is not stackable, it creates new individual items for the specified amount.
func give_item(id, amount: int = 1) -> void:
	if self.itemdb[id].stackable:       # If the item is stackable:
		var existing_stack = null      # Initialize a variable to store an existing stack.

		for item in inventory:         # Iterate through the player's item stacks.
			if item["id"] == id:         # If we find a stack with the same item ID:
				existing_stack = item       # Store the existing stack.
				break                      # Exit the loop since we found a stack.

		if existing_stack:           # If we found an existing stack:
			existing_stack["amount"] += amount   # Add the given amount to the stack.
		else:                        # If no existing stack is found:
			inventory.append({"id": id, "amount": amount})   # Create a new stack with the item and amount.

	else:                          # If the item is not stackable:
		for i in range(amount):       # Repeat the following loop 'amount' times.
			inventory.append({"id": id})   # Create individual items for the specified amount.

	if !is_item_debugging:         # If not in debugging mode:
		save_player_inventory()        # Save player data to a file.

# This function takes an item from the inventory and removes it or decreases its stack size.
# If the item is stackable, it decreases the stack size by the given amount.
# If the item is not stackable, it removes all occurrences up to the specified amount.
func take_item(id, amount: int = 1) -> void:

	# Initialize a variable to count the total items found in the inventory.
	var total_of_item_stack = 0
	# Initialize a list to store the indices of items to be removed.
	var indices_to_remove = []

	for i in range(inventory.size()):     # Iterate over the inventory.
		var item = inventory[i]           # Get the current item.
		if item.id != id:                 # Check if it's not the item we want to remove.
			continue                      # Skip to the next iteration.

		if itemdb[id].stackable:          # If the item is stackable:
			item.amount -= amount         # Reduce the item's stack size by the given amount.
			if item.amount <= 0:          # If the stack size becomes zero or negative:
				indices_to_remove.append(i)   # Add the item's index to the removal list.
			break                         # Exit the loop since we have updated the item.

		else:                            # If the item is not stackable:
			indices_to_remove.append(i)      # Add the item's index to the removal list.
			total_of_item_stack += 1         # Increase the count of found items.
			if total_of_item_stack >= amount: # If we have found enough items:
				break                         # Exit the loop.

	# Remove the items after the loop has completed.
	while indices_to_remove.size() > 0:      # While there are items to remove:
		var index = indices_to_remove.pop_back()   # Get the last index to remove.
		inventory.remove_at(index)                # Remove the item at that index.

	if !is_item_debugging:                # If not in debugging mode:
		save_player_inventory()               # Save player data to a file.


# This function checks how many items of a given ID are in the player's inventory.
# It returns the total number of items found, accounting for stackable and non-stackable items.
func has_item(id) -> int:
	var total_amount = 0      # Initialize a variable to store the total number of items found.

	for item in inventory:       # Iterate through the player's inventory.
		if item["id"] == id:        # If we find an item with the same ID:
			if itemdb[id].stackable:      # If the item is stackable:
				total_amount += item["amount"]   # Add the item's stack size to the total amount.
			else:                         # If the item is not stackable:
				total_amount += 1             # Increment the total amount by 1.

	return total_amount       # Return the total number of items found.

# Returns the size of the inventory
func get_inventory_size() -> int:
	return inventory.size()

#Returns the Item Database (Unused)
func get_item_db() -> Dictionary:
	return self.itemdb

# Returns the Inventory Array (Unused)
func get_inventory() -> Array:
	return inventory

# Returns Item in Player Inventory at index number
func get_item_at_index(idx) -> Dictionary:
	return inventory[idx]

# Returns Item Name
func get_item_name(item) -> String:
	return itemdb[item.id].name

# Returns Item Type
func get_item_type(item) -> String:
	return itemdb[item.id].type

# Returns Item Quality
func get_item_quality(item) -> String:
	return itemdb[item.id].quality

# Returns Item Examine
func get_item_examine(item) -> String:
	return itemdb[item.id].examine

# Returns Item Amount (Stackables: Amount in Stack) (Non-stackables: Amount of Stacks)
func get_item_amount(item) -> int:
	return has_item(item.id)

# Returns Custom Item Data Dictionary
func get_item_data(item) -> Dictionary:
	if "data" in item:
		return item.data
	#else:
		#return {}
	return {}

# Returns Food Item Healing Value
func get_food_health(item) -> int:
	if "health" in itemdb[item.id]:
		return itemdb[item.id].health
	#else:
		#return 0
	return 0
# This function saves the player data to a JSON file.


#func save_inventory_data() -> void:

# Open the JSON file for writing.
#	var file = FileAccess.open("res://data/player.json", FileAccess.WRITE)
# Convert the current inventory dictionary to a JSON string.
#	var json = JSON.stringify(inventory)
# Write the JSON string to the file.
#	file.store_string(json)
#
# This function saves the player's inventory data to the "player.json" file.

func save_player_inventory() -> void:

	# Open the "player.json" file in read mode.
	var player_data_file = FileAccess.open("res://data/player.json", FileAccess.READ)
	# Read the JSON data as a string from the file.
	var string_json = player_data_file.get_as_text()
	# Parse the JSON data from the string into a dictionary.
	var json = JSON.parse_string(string_json)

	# Update the 'items' key in the JSON dictionary with the contents of the player's inventory.
	json.items = self.inventory
	player_data = json
	player_data_file.close()        # Close the file after reading.

	# Open the "player.json" file in write mode.
	var file = FileAccess.open("res://data/player.json", FileAccess.WRITE)

	# Convert the updated JSON dictionary to a string and write it back to the file.
	file.store_string(JSON.stringify(json))
	# Close the file after writing.
	file.close()

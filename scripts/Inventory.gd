class_name Inventory

var itemdb: Dictionary
var player_data: Dictionary
var inventory: Array
var is_item_debugging: bool = true
var inventory_file: String

# TODO: has_item(id, item_data)
#       returns amount of items matching with item_data
#       always returns 0 on stackables, if item_data is given
# TODO: take_item(id, amount, item_data)
#       amount with item_data only works for unstackables
#       item_data only works on unstackables
# TODO: modify_item_at_index(idx, amount, item_data)
#       amount only works on stackables
#       item_data is only applied if item is unstackable
# TODO: get_item_from_db(id)
#       returns item db data for a given item

# TODO: Item Enchantment, Engraving, Item Naming

# Function to set the current inventory using the data from a JSON file.
# Parameters:
# - file: The path to the JSON file containing inventory data.
func set_inventory(file) -> void:
	# Call the function to set up the item database.
	self.set_itemdb()
	# Store the file path in the 'inventory_file' variable.
	self.inventory_file = file
	# Retrieve the JSON data from the file and extract the 'items' key as the inventory.
	self.inventory = self.get_json(self.inventory_file).items

# Inventory Operations

# Function to give an item to a player's inventory.
# Adds to an existing stack, if the item is stackable and already present in inventory
# If the item is not stackable, it creates new individual items for the specified amount.
# Parameters:
# - id: The ID of the item to give.
# - amount: The number of items to give (default is 1).
# - item_data: Custom data for the item (optional, default is null).
func give_item(id: String, amount: int = 1, item_data = null) -> void:

	# Retrieve item information from the database based on the given ID.
	var item_in_db = itemdb[id]

	# Check if the item is stackable.
	if item_in_db.stackable:

		# Initialize a variable to store an existing stack of the same item.
		var existing_stack = null

		# Iterate through the player's inventory to find an existing stack of the item.
		for item in inventory:
			if item["id"] == id:
				existing_stack = item
				break

		# If an existing stack is found:
		if existing_stack:
			# Increase the amount of the existing stack by the given amount.
			existing_stack["amount"] += amount
		else:
			# If no existing stack is found, create a new stack with the item and amount.
			inventory.append({"id": id, "amount": amount})
	else:
		# If the item is not stackable:
		# Repeat the following loop 'amount' times to give multiple individual items.
		for i in range(amount):
			# Check if custom item data is given.
			if item_data:
				# Create individual items for the specified amount, with custom item data.
				inventory.append({"id": id, "data": item_data})
			else:
				# Create individual items for the specified amount without custom data.
				inventory.append({"id": id})

	# Check if the game is not in debugging mode.
	if !is_item_debugging:
		# Save the player's inventory to a file to persist changes.
		save_player_inventory()

# Function to remove items from the player's inventory.
# Removes an item, or decreases its stack size.
# If the item is stackable, it decreases the stack size by the given amount.
#  If the item amount is zero, we remove the stack from the inventory
# If the item is not stackable, it removes all occurrences up to the specified amount.
# Parameters:
# - id: The ID of the item to remove.
# - amount: The number of items to remove (default is 1).
func take_item(id, amount: int = 1) -> void:

	# Retrieve item information from the database based on the given ID.
	var item_in_db = itemdb[id]

	# Initialize a variable to count the total items found in the inventory.
	var total_of_item_stack = 0

	# Initialize a list to store the indices of items to be removed.
	var indices_to_remove = []

	# Iterate over the inventory to find the items to be removed.
	for i in range(inventory.size()):
		var item = inventory[i]

		# Check if the current item is not the one we want to remove.
		if item.id != id:
			continue   # Skip to the next iteration.

		# If the item is stackable:
		if item_in_db.stackable:
			item.amount -= amount   # Reduce the item's stack size by the given amount.
			if item.amount <= 0:    # If the stack size becomes zero or negative:
				indices_to_remove.append(i)   # Add the item's index to the removal list.
			break   # Exit the loop since we have updated the item.

		# If the item is not stackable:
		else:
			indices_to_remove.append(i)   # Add the item's index to the removal list.
			total_of_item_stack += 1      # Increase the count of found items.
			if total_of_item_stack >= amount:   # If we have found enough items:
				break   # Exit the loop.

	# Remove the items after the loop has completed.
	while indices_to_remove.size() > 0:
		var index = indices_to_remove.pop_back()   # Get the last index to remove.
		inventory.remove_at(index)   # Remove the item at that index.

	# Check if the game is not in debugging mode.
	if !is_item_debugging:
		save_player_inventory()   # Save the player's inventory to a file to persist changes.


# Function to remove an item from the player's inventory at a specific index.
# If the item is stackable, it decreases the stack size by 1;
#  if the stack becomes empty, it removes the stack.
# For non-stackable items, it removes the individual item at the specified index.
# Parameters:
# - idx: The index of the item in the inventory to remove.
func take_item_at_index(idx: int, amount: int = 1) -> void:

	# Check if the index is within the valid range of the inventory.
	if idx < 0 or idx >= inventory.size():
		print("Invalid index. The index must be within the range of the inventory.")
		return

	# Get the item at the specified index.
	var item = inventory[idx]

	# Retrieve item information from the database based on the item's ID.
	var item_in_db = itemdb[item["id"]]

	# If the item is stackable:
	if item_in_db.stackable:
		# Decrease the stack size by 1.
		item["amount"] -= amount
		# If the stack size becomes zero or negative:
		if item["amount"] <= 0:
			# Remove the stack from the inventory.
			inventory.remove_at(idx)
	else:
		# For non-stackable items, remove the individual item at the specified index.
		inventory.remove_at(idx)

	# Check if the game is not in debugging mode.
	if !is_item_debugging:
		# Save the player's inventory to a file to persist changes.
		save_player_inventory()


## Set/Get Item Database

# Sets the Item Database to use (hardcoded for now.)
func set_itemdb() -> void:
	self.itemdb = self.get_json("res://data/items.json")

#Returns the Item Database (Unused)
func get_item_db() -> Dictionary:
	return self.itemdb

## Get Inventory

# Returns the Inventory Array (Unused)
func get_inventory() -> Array:
	return inventory

# Returns the size of the inventory
func get_inventory_size() -> int:
	return inventory.size()

## Get Inventory Item

# Function to check how many items of a given ID are in the player's inventory.
# It returns the total number of items found, accounting for stackable and non-stackable items.

# Parameters:
# - id: The ID of the item to check for.
# Returns:
# - The total number of items found in the inventory.
func has_item(id) -> int:

	# Retrieve item information from the database based on the given ID.
	var item_in_db = itemdb[id]

	# Initialize a variable to store the total number of items found.
	var total_amount = 0

	# Iterate through the player's inventory to find the item with the specified ID.
	for item in inventory:
		# Check if we find an item with the same ID as the one we are looking for.
		if item["id"] == id:
			# If the item is stackable, add the item's stack size to the total amount.
			if item_in_db.stackable:
				total_amount += item["amount"]
			# If the item is not stackable, increment the total amount by 1 (found one item).
			else:
				total_amount += 1

	# Return the total number of items found in the inventory.
	return total_amount


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

## JSON Handling

func get_json(path) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

	#player_data = self.get_json("res://data/player.json")
	#set_inventory(player_data.items)

#func save_inventory_data() -> void:

# Open the JSON file for writing.
#	var file = FileAccess.open("res://data/player.json", FileAccess.WRITE)
# Convert the current inventory dictionary to a JSON string.
#	var json = JSON.stringify(inventory)
# Write the JSON string to the file.
#	file.store_string(json)

# Function to save the player's inventory data to a JSON file.
func save_player_inventory() -> void:
	# Open the "player.json" file in read mode to read existing data.
	var player_data_file = FileAccess.open("res://data/player.json", FileAccess.READ)
	# Read the JSON data as a string from the file.
	var string_json = player_data_file.get_as_text()
	# Parse the JSON data from the string into a dictionary.
	var json = JSON.parse_string(string_json)
	# Update the 'items' key in the JSON dictionary with the contents of the player's inventory.
	json.items = self.inventory
	# Store the updated JSON dictionary into a new variable called 'player_data'.
	player_data = json
	# Close the file after reading to release the resource.
	player_data_file.close()
	# Open the "player.json" file in write mode to update the data.
	var file = FileAccess.open("res://data/player.json", FileAccess.WRITE)

	# Convert the updated JSON dictionary to a string and write
	file.store_string(JSON.stringify(json))
	# Close the file after writing.
	file.close()



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


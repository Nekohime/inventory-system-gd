extends ItemList

var Inventory = load("scripts/Inventory.gd")
var pinv: Inventory
var inventory: Array
var itemdb: Dictionary

var item_qualities = {
	"legendary": "#ff8000",
	"epic": "#a335ee",
	"rare": "#0070dd",
	"uncommon": "#1eff00",
	"common": "#fff",
	"junk": "#9d9d9d"
}

@onready var item_infobox_name = $'../ItemInformationBox/VBoxContainer/ItemNameLabel'
@onready var item_infobox_type = $'../ItemInformationBox/VBoxContainer/ItemTypeLabel'
@onready var item_infobox_examine = $'../ItemInformationBox/VBoxContainer/ItemExamineLabel'
@onready var item_infobox_data = $'../ItemInformationBox/VBoxContainer/ItemDataLabel'

func _ready():
	self.item_activated.connect(_on_item_activated)
	self.item_clicked.connect(_on_item_clicked)

	pinv = Inventory.new()
	pinv.set_inventory("res://data/player.json")
	itemdb = pinv.get_item_db()
	do_inventory_display()
	if pinv.get_inventory_size():
		set_examine()

func _on_item_activated(_index):
	var single_selected_item = get_selected_items()[0];
	var selected_item = pinv.get_item_at_index(single_selected_item)
	if pinv.get_item_type(selected_item) == "food":
		#Global.player_data.health += pinv.get_food_health(selected_item) #TODO: Increase health

		remove_item(get_selected_items()[0])
		pinv.take_item(selected_item.id)

func _on_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int):
	set_examine()
	var single_selected_item = get_selected_items()[0];
	var selected_item = pinv.get_item_at_index(single_selected_item)
	print("A Stick with custom data: " + str(pinv.get_item_data(selected_item)))

func set_examine():
	var single_selected_item = get_selected_items()[0];
	var selected_item = pinv.get_item_at_index(single_selected_item)
	var item_quality = item_qualities[pinv.get_item_quality(selected_item)]
	var item_name = pinv.get_item_name(selected_item)
	var item_type = pinv.get_item_type(selected_item)
	var item_examine = pinv.get_item_examine(selected_item)
	var item_amount = pinv.get_item_amount(selected_item)
	var item_data = pinv.get_item_data(selected_item)
	var _item_heals = pinv.get_food_health(selected_item)

	if "amount" in selected_item:
		item_infobox_name.set_text(
			"[center][color="+ item_quality +"]" + item_name +
			" x" + str(item_amount) + "[/color][/center]"
			)
	else:
		item_infobox_name.set_text(
			"[center][color=" + item_quality + "]" +
			item_name + "[/color][/center]"
			)
	item_infobox_type.set_text(item_type.capitalize() + " Item")
	item_infobox_examine.set_text("[i][color=yellow]\"" + item_examine + "\"[/color][/i]")

	if "data" in selected_item:
		item_infobox_data.set_text(str(item_data))
	else:
		item_infobox_data.set_text("")

func do_inventory_display():
	clear()
	inventory = pinv.get_inventory()

	for item in inventory:
		if itemdb[item.id].stackable:
			self.add_item("[" + itemdb[item.id].name + "] x" + str(item.amount))
		else:
			var charges = item.charges if "charges" in item else -1
			if charges > 0:
				print("charges: " + str(charges))
			if itemdb[item.id].type == "food":
				self.add_item("[" + itemdb[item.id].name + " (+" + str(itemdb[item.id].health) + " HP)]")
			else:
				self.add_item("[" + itemdb[item.id].name + "]")
		select(0)

func _on_button_pressed() -> void:
	#pinv.give_item("strawberry", 1)
	#pinv.give_item("useless_dust", 1)
	pinv.give_item("wooden_stick", 1, { "test": "yep"})
	do_inventory_display()


func _on_button_2_pressed() -> void:
	pinv.take_item_at_index(0, 2)
	do_inventory_display()
	pass


func _on_button_3_pressed() -> void:
	var single_selected_item = get_selected_items()[0];
	var selected_item = pinv.get_item_at_index(single_selected_item)
	print(pinv.get_item_from_db(selected_item.id))


func _on_item_instance_button_pressed() -> void:
	var single_selected_item = get_selected_items()[0];
	var selected_item = pinv.get_item_at_index(single_selected_item)
	print(selected_item)
	pass

func _on_inventory_data_button_pressed() -> void:
	print(pinv.get_inventory())
	pass # Replace with function body.

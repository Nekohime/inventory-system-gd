extends ItemList

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
	itemdb = Inventory.get_item_db()
	do_inventory_display()
	set_examine()

func _on_item_activated(_index):
	var single_selected_item = get_selected_items()[0];
	var selected_item = Inventory.get_item_at_index(single_selected_item)
	if Inventory.get_item_type(selected_item) == "food":
		Global.player_data.health += Inventory.get_food_health(selected_item)
		remove_item(get_selected_items()[0])
		Inventory.take_item(selected_item.id)

func _on_item_clicked(_index: int, _at_position: Vector2, _mouse_button_index: int):
	set_examine()
	var single_selected_item = get_selected_items()[0];
	var selected_item = Inventory.get_item_at_index(single_selected_item)
	print("A Stick with custom data: " + str(Inventory.get_item_data(selected_item)))

func set_examine():
	var single_selected_item = get_selected_items()[0];
	var selected_item = Inventory.get_item_at_index(single_selected_item)
	var item_quality = item_qualities[Inventory.get_item_quality(selected_item)]
	var item_name = Inventory.get_item_name(selected_item)
	var item_type = Inventory.get_item_type(selected_item)
	var item_examine = Inventory.get_item_examine(selected_item)
	var item_amount = Inventory.get_item_amount(selected_item)
	var item_data = Inventory.get_item_data(selected_item)
	
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
	inventory = Inventory.get_inventory()

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
	Inventory.give_item("strawberry", 1)
	Inventory.give_item("useless_dust", 1)
	do_inventory_display()

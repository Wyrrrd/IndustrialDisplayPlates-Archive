------------------------------------------------------------------------------------------------------------------------------------------------------

-- DEADLOCK'S INDUSTRIAL DISPLAYS
-- Forked from Industrial Revolution, for your signage pleasure

------------------------------------------------------------------------------------------------------------------------------------------------------

-- constants shared by data and control stages

return {
	displays = {
		["copper-display-small"] = {
			ingredients = {{"copper-plate",1}},
		},
		["copper-display-medium"] = {
			ingredients = {{"copper-plate",4}},
		},
		["copper-display"] = {
			ingredients = {{"copper-plate",9}},
		},
		["iron-display-small"] = {
			ingredients = {{"iron-plate",1}},
			IR_unlock = "ir2-iron-milestone",
		},
		["iron-display-medium"] = {
			ingredients = {{"iron-plate",4}},
			IR_unlock = "ir2-iron-milestone",
		},
		["iron-display"] = {
			ingredients = {{"iron-plate",9}},
			IR_unlock = "ir2-iron-milestone",
		},
		["steel-display-small"] = {
			ingredients = {{"steel-plate",1}},
			unlock = "steel-processing",
			IR_unlock = "ir2-steel-milestone",
		},
		["steel-display-medium"] = {
			ingredients = {{"steel-plate",4}},
			unlock = "steel-processing",
			IR_unlock = "ir2-steel-milestone",
		},
		["steel-display"] = {
			ingredients = {{"steel-plate",9}},
			unlock = "steel-processing",
			IR_unlock = "ir2-steel-milestone",
		},
	},
	sizes = {
		default = 3,
		medium = 2,
		small = 1,
	},
	elem_prototypes = {
		item = "item_prototypes",
		fluid = "fluid_prototypes",
	},
	group_blacklist = {
		["creative-mod_creative-tools"] = true,
	},
	icon_size = 64,
	icon_mipmaps = 4,
	icon_path = "__IndustrialDisplayPlates__/graphics/icons",
	sprites_path = "__IndustrialDisplayPlates__/graphics/entities",
	sound_path = "__IndustrialDisplayPlates__/sound",
	base_sound_path = "__base__/sound",
	core_sound_path = "__core__/sound",
	base_icons_path = "__base__/graphics/icons",
	custom_gui = "DID_gui",
	mod_name = "IndustrialDisplayPlates",
	grid_columns = 10,
	pending_translation_value = "",
}

------------------------------------------------------------------------------------------------------------------------------------------------------

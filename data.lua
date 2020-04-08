------------------------------------------------------------------------------------------------------------------------------------------------------

-- DEADLOCK'S INDUSTRIAL DISPLAYS
-- Forked from Industrial Revolution, for your signage pleasure

------------------------------------------------------------------------------------------------------------------------------------------------------

-- constants

local DID = require("globals")

------------------------------------------------------------------------------------------------------------------------------------------------------

-- functions

local function get_icon_path(name, icon_size)
    return string.format("%s/%s/%s.png", DID.icon_path, tostring(icon_size or DID.icon_size), name)
end

------------------------------------------------------------------------------------------------------------------------------------------------------

-- prototypes

local dimensions = {
	[1] = {width = 80, height = 80},
	[2] = {width = 134, height = 134},
	[3] = {width = 196, height = 196},
}

local shadow_dimensions = {
	[1] = {width = 80, height = 80, sprite = "display-shadow-small"},
	[2] = {width = 146, height = 134, sprite = "display-shadow-medium"},
	[3] = {width = 204, height = 204, sprite = "display-shadow"},
}

data:extend({{
	name = "display-plates",
	type = "item-subgroup",
	group = "logistics",
	order = "z[display-plates]"
}})

local count = 1
for display,displaydata in pairs(DID.displays) do
	local size = (string.find(display,"small") and 1) or (string.find(display,"medium") and 2) or 3
	local box_size = size * 0.5
	data:extend({
		{
			name = display,
			type = "simple-entity-with-owner",
			localised_description = {"entity-description.display"},
			render_layer = "lower-object",
			icon = get_icon_path(display),
			icon_size = DID.icon_size,
			icon_mipmaps = DID.icon_mipmaps,
			corpse = "small-remnants",
			minable = {
				mining_time = 0.2,
				result = display,
			},
			max_health = 10 + size * 30,
			flags = {"placeable-player", "placeable-neutral", "player-creation"},
			collision_box = { {-box_size+0.1, -box_size+0.1}, {box_size-0.1, box_size-0.1} },
			selection_box = { {-box_size, -box_size}, {box_size, box_size} },
			collision_mask = {
				"object-layer",
				"water-tile",
			},
			open_sound = {
				filename = DID.base_sound_path.."/machine-open.ogg",
				volume = 0.5
			},
			close_sound = {
				filename = DID.base_sound_path.."/machine-close.ogg",
				volume = 0.5
			},
			mined_sound = {
				filename = DID.core_sound_path.."/deconstruct-medium.ogg"
			},
			resistances = {
				{
					type = "fire",
					percent = 75
				},
			},
			picture = {
				layers = {
					{
						filename = string.format("%s/"..display..".png", DID.sprites_path),
						priority = "high",
						shift = {0,0},
						height = dimensions[size].height,
						width = dimensions[size].width,
						scale = 0.5,
					},
					{
						filename = string.format("%s/%s.png", DID.sprites_path, shadow_dimensions[size].sprite),
						priority = "high",
						shift = {0,0},
						height = shadow_dimensions[size].height,
						width = shadow_dimensions[size].width,
						scale = 0.5,
						draw_as_shadow = true,
					},
				}
			},
			random_variation_on_create = false,
		},
		{
			type = "item",
			name = display,
			order = "z["..count.."]",
			subgroup = "display-plates",
			stack_size = 100,
			icon = get_icon_path(display),
			icon_size = DID.icon_size,
			icon_mipmaps = DID.icon_mipmaps,
			place_result = display,
		},
		{
			type = "recipe",
			name = display,
			order = "z["..count.."]",
			result = display,
			result_count = 1,
			category = "crafting",
			enabled = mods["IndustrialRevolution"] and (displaydata.IR_unlock == nil) or (displaydata.unlock == nil),
			ingredients = displaydata.ingredients,
			energy_required = 1,
		}
	})
	count = count + 1
end

------------------------------------------------------------------------------------------------------------------------------------------------------

-- styles

local function add_styles(styles)
    local default_styles = data.raw["gui-style"]["default"]
    for name, style in pairs(styles) do
        default_styles[name] = style
    end
end

add_styles({
    display_tabbed_pane = {
        tab_container = {
            horizontal_spacing = 0,
            left_padding = 0,
            right_padding = 0,
            horizontal_align = "center",
            type = "horizontal_flow_style",
        },
        tab_content_frame = {
            bottom_padding = 8,
            left_padding = 10,
            right_padding = 10,
            top_padding = 8,
            graphical_set = data.raw["gui-style"]["default"]["tabbed_pane"]["tab_content_frame"].graphical_set,
            type = "frame_style",
        },
        type = "tabbed_pane_style",
        parent = "tabbed_pane",
        width = 420,
    },
    display_tab = {
        type = "tab_style",
        parent = "filter_group_tab",
        font = "did-tab-font",
        top_padding = 8,
        bottom_padding = 8,
        minimal_width = 32,
        horizontally_stretchable = "on",
        horizontally_squashable = "on",
    },
    display_frame = {
        type = "frame_style",
        parent = "frame",
        bottom_padding = 8,
        vertical_flow_style = {
            type = "vertical_flow_style",
            vertical_spacing = 0,
            horizontal_align = "center",
        },
    },
    display_deep_frame = {
        type = "frame_style",
        parent = "inside_deep_frame",
        vertical_flow_style = {
            type = "vertical_flow_style",
            vertical_spacing = 0,
            horizontal_align = "center",
        },
    },
    display_tab_deep_frame = {
        type = "frame_style",
        parent = "subpanel_inset_frame",
        vertical_flow_style = {
            type = "vertical_flow_style",
            vertical_spacing = 0,
            padding = 0,
        },
        graphical_set = {
          base = {
            center = {
              position = {42,8},
              size = {1,1},
            },
            corner_size = 8,
            draw_type = "outer",
            position = {85,0},
          },
		  shadow = data.raw["gui-style"]["default"]["inside_deep_frame"].graphical_set.shadow,
        },
        background_graphical_set = {
            corner_size = 8,
            overall_tiling_horizontal_padding = 5,
            overall_tiling_horizontal_size = 30,
            overall_tiling_horizontal_spacing = 10,
            overall_tiling_vertical_padding = 5,
            overall_tiling_vertical_size = 30,
            overall_tiling_vertical_spacing = 10,
            position = { 282, 17 },
        },
    },
    display_buttons = {
        type = "table_style",
        horizontal_spacing = 0,
        vertical_spacing = 0,
    },
    display_button_selected = {
        type = "button_style",
        parent = "quick_bar_slot_button",
        default_graphical_set = data.raw["gui-style"]["default"]["CGUI_filter_slot_button"].selected_graphical_set
    },
    display_fake_header = {
        type = "frame_style",
        height = 24,
        graphical_set = data.raw["gui-style"]["default"]["draggable_space"].graphical_set,
        use_header_filler = false,
        horizontally_stretchable = "on",
        vertical_align = "center",
        alignment = "right",
        left_margin = data.raw["gui-style"]["default"]["draggable_space"].left_margin,
        right_margin = data.raw["gui-style"]["default"]["draggable_space"].right_margin,
    },
    display_small_button = {
        type = "button_style",
        parent = "frame_action_button_no_border",
		left_margin = 1,
		right_margin = 1,
    },
    display_small_button_active = {
        type = "button_style",
        parent = "display_small_button",
        default_graphical_set = data.raw["gui-style"]["default"]["frame_button"].clicked_graphical_set,
    },
})

------------------------------------------------------------------------------------------------------------------------------------------------------

-- controls / misc media

data:extend({
    {
        type = "custom-input",
        name = "deadlock-open-gui",
        key_sequence = "",
        linked_game_control = "open-gui",
    },
    {
        type = "custom-input",
        name = "deadlock-focus-search",
        key_sequence = "",
        linked_game_control = "focus-search",
    },
    {
        type = "font",
        name = "did-tab-font",
        from = "default",
        size = 32,
    },
    {
        type = "sprite",
        name = "display-map-marker",
        filename = get_icon_path("map-marker",32),
        priority = "extra-high",
        width = 32,
        height = 32,
        mipmap_count = 2,
		scale = 0.5,
		flags = {"gui-icon"},
    },
    {
        type = "sound",
        name = "map-marker-ping",
        variations = {
            filename = DID.sound_path.."/ping.ogg",
            volume = 0.9
        }
    },
    {
        type = "sound",
        name = "map-marker-pong",
        variations = {
            filename = DID.sound_path.."/pong.ogg",
            volume = 0.9
        }
    },
})


------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------

-- DEADLOCK'S INDUSTRIAL DISPLAYS
-- Forked from Industrial Revolution, for your signage pleasure

------------------------------------------------------------------------------------------------------------------------------------------------------

-- constants

local DID = require("globals")

------------------------------------------------------------------------------------------------------------------------------------------------------

-- functions

local function get_global_player_info(player_index,info)
	if global[info] == nil then global[info] = {} end
	return global[info][player_index]
end

local function set_global_player_info(player_index,info,value)
	if global[info] == nil then global[info] = {} end
	global[info][player_index] = value
end

local function splitstring(s, d)
    result = {};
    for m in (s..d):gmatch("(.-)"..d) do
        table.insert(result, m);
    end
    return result;
end

local function get_map_markers(entity)
	return entity.force.find_chart_tags(entity.surface, entity.bounding_box)
end

local function add_map_marker(entity, icon_type, icon_name)
	if icon_type and icon_name then
		entity.force.add_chart_tag(entity.surface, { icon = { type = icon_type, name = icon_name}, position = entity.position })
		entity.surface.play_sound{path = "map-marker-ping", position = entity.position, volume_modifier = 1}
	end
end

local function change_map_markers(entity, icon_type, icon_name)
	local markers = get_map_markers(entity)
	if markers then
		for _,marker in pairs(markers) do
			marker.icon = { type = icon_type, name = icon_name}
		end
	end
end

local function get_has_map_marker(entity)
	return next(get_map_markers(entity)) ~= nil
end

local function remove_markers(entity)
	if entity and entity.valid then
		for _,marker in pairs(get_map_markers(entity)) do
			marker.destroy()
		end
	end
end

local function find_entity_render(entity) 
	for _,id in pairs(rendering.get_all_ids(DID.mod_name)) do
		if rendering.get_target(id).entity == entity then return id end
	end
	return nil
end

local function get_render_sprite_info(entity)
	local id = find_entity_render(entity)
	if id then
		local strings = splitstring(rendering.get_sprite(id), "/")
		if #strings == 2 then return strings[1], strings[2] end
	end
	return nil, nil
end


local function gui_close(event)
    local player = game.players[event.player_index]
    local frame = player.gui.screen[DID.custom_gui]
    if frame then
		set_global_player_info(event.player_index,"display_gui_location",player.gui.screen[DID.custom_gui].location)
        return frame.destroy()
    end
	return false
end

local function render_overlay_sprite(entity,sprite)
	if game.is_valid_sprite_path(sprite) then
		local size = (string.find(entity.name,"small") and 0.65) or (string.find(entity.name,"medium") and 1.5) or 2.5
		rendering.draw_sprite{
			sprite = sprite,
			x_scale = size,
			y_scale = size,
			render_layer = "lower-object",
			target = entity,
			surface = entity.surface,
		}
	end
end

local function render_overlay(entity,spritetype,spritename)
	render_overlay_sprite(entity, spritetype.."/"..spritename)
end

local function destroy_render(entity)
	local last_id = find_entity_render(entity)
	if last_id then rendering.destroy(last_id) end
end

local function get_all_children_with_style(root,style,children)
	if not root then return nil end
	if children == nil then children = {} end
	for _,child in pairs(root.children) do
		if child.style.name == style then table.insert(children,child) end
		children = get_all_children_with_style(child,style,children)
	end
	return children
end

local function get_all_children_with_name(root,name,children)
	if children == nil then children = {} end
	if not root or not root.children then return children end
	for _,child in pairs(root.children) do
		if child.name and string.find(child.name, name, 1, true) then table.insert(children,child) end
		children = get_all_children_with_name(child,name,children)
	end
	return children
end

local function display_filter_tabs(player,filter)
	local textfield = player.gui.screen[DID.custom_gui]["display-header"]["display-search-textfield"]
	local tabs = player.gui.screen[DID.custom_gui]["inner-frame"]["display-tabs"]
	local selected = tabs.selected_tab_index
	for index,tab in pairs(tabs.tabs) do
		tabs.selected_tab_index = index -- shenanigans
		local count = 0
		for _,child in pairs(get_all_children_with_name(tab.content,"display-symbol")) do
			if child.sprite and string.find(string.lower(child.sprite), string.lower(filter), 1, true) then
				count = count + 1
				child.visible = true
			else
				child.visible = false
			end
		end
		tab.tab.enabled = (count > 0)
		local name = splitstring(tab.tab.name,":")
	end
	tabs.selected_tab_index = selected or 1 -- end of shenanigans
	if textfield.visible then textfield.focus() end -- fix textfield focus 
end

local function toggle_search(player,element,override) 
	local textfield = player.gui.screen[DID.custom_gui]["display-header"]["display-search-textfield"]
	if textfield then
		textfield.visible = override or not textfield.visible
		element.style = (override or textfield.visible) and "display_small_button_active" or "display_small_button"
		if not textfield.visible and not override then
			textfield.text = ""
			display_filter_tabs(player,"")
		else
			textfield.focus()
		end
	end
end

local display_gui_click = {
	["display-symbol"] = function (event,sprite)
		local player = game.players[event.player_index]
		local last_display = get_global_player_info(player.index,"last_display")
		if last_display then
			destroy_render(last_display)
			render_overlay_sprite(last_display, event.element.sprite)
			for _,child in pairs(get_all_children_with_style(player.gui.screen[DID.custom_gui], "display_button_selected")) do
				child.style = "quick_bar_slot_button"
				child.ignored_by_interaction = false
			end
			event.element.style = "display_button_selected"
			event.element.ignored_by_interaction = true
			local map_button = player.gui.screen[DID.custom_gui]["display-header"]["display-map-marker"]
			if map_button then
				if not map_button.enabled then
					map_button.enabled = true
				elseif get_has_map_marker(last_display) then
					local spritetype, spritename = get_render_sprite_info(last_display)
					change_map_markers(last_display, spritetype, spritename)
				end
			end
		end
	end,
	["display-search-button"] = function (event)
		toggle_search(game.players[event.player_index], event.element)
	end,
    ["display-map-marker"] = function (event)
		local last_display = get_global_player_info(event.player_index,"last_display")
		if last_display then 
			if get_has_map_marker(last_display) then
				event.element.style = "display_small_button"
				remove_markers(last_display)
				local player = game.players[event.player_index]
				player.play_sound{path = "map-marker-pong"}
			else
				local spritetype, spritename = get_render_sprite_info(last_display)
				add_map_marker(last_display, spritetype, spritename)
				event.element.style = "display_small_button_active"
			end
		end
    end,
    ["display-header-close"] = function (event)
        gui_close(event)
    end,
}

local function is_a_display(entity)
	return DID.displays[entity.name] ~= nil
end

local function get_display_event_filter()
	local filters = {}
	for display,_ in pairs(DID.displays) do
		table.insert(filters, { filter = "name", name = display })
	end
	return filters
end

local function event_raised_destroy(event)
    if event.entity and event.entity.valid and is_a_display(event.entity) then
		-- remove any map markers
		remove_markers(event.entity)
		-- close any/all open guis
		for _,player in pairs(game.players) do
			local last_display = get_global_player_info(player.index, "last_display")
			local frame = player.gui.screen[DID.custom_gui]
			if frame and event.entity == last_display then frame.destroy() end
		end
    end
end

local function gui_click(event)
	-- check the entity this gui refers to - in multiplayer it could have been removed while player wasn't logged in
	if event.player_index then
		local player = game.players[event.player_index]
		local frame = player.gui.screen[DID.custom_gui]
		local last_display = get_global_player_info(player.index, "last_display")
		if frame and (not last_display or not last_display.valid) then
			frame.destroy()
			return
		end
	end	
	-- is there a method for this element?
	local clicked = splitstring(event.element.name,":")
	if display_gui_click[clicked[1]] then
		display_gui_click[clicked[1]](event,clicked[2])
		return
	end
end

local function create_display_gui(player, selected)

    if not player or not selected then return end

	-- cache which entity this gui belongs to
	set_global_player_info(player.index,"last_display",selected)
	
	-- close any existing gui
	local frame = player.gui.screen[DID.custom_gui]
	if frame then frame.destroy() end
	player.opened = player.gui.screen
	
	-- get markers and currently rendered sprite
	local markers = next(get_map_markers(selected)) ~= nil
	local sname, stype = get_render_sprite_info(selected)
	local render_sprite = (sname and stype) and sname.."/"..stype or nil 

	-- create frame
	frame = player.gui.screen.add {
		type = "frame",
		name = DID.custom_gui,
		direction = "vertical",
		style = "display_frame",
	}
	
	-- update frame location if cached
	if get_global_player_info(player.index,"display_gui_location") then
		frame.location = get_global_player_info(player.index,"display_gui_location")
	else
		frame.force_auto_center()
	end

	-- header
	local header = frame.add {
		type = "flow",
		direction = "horizontal",
		name = "display-header",
	}
	header.style.bottom_padding = -4
	header.style.horizontally_stretchable = true
	
	-- title
	header.add {
		type = "label",
		caption = {"controls.display-plate"},
		style = "frame_title",
	}

	-- "drag filler"
	local filler = header.add {
		type = "empty-widget",
		style = "draggable_space_header",
	}
	filler.style.natural_height = 24
	filler.style.horizontally_stretchable = true
	filler.drag_target = frame

	-- search textfield
	local search_textfield = header.add {
		name = "display-search-textfield",
		type = "textfield",
		style = "search_popup_textfield",
	}
	search_textfield.style.height = 24
	search_textfield.style.width = 100
	search_textfield.visible = false

	-- search button
	local search_button = header.add {
		name = "display-search-button",
		type = "sprite-button",
		sprite = "utility/search_white",
		style = "display_small_button",
		tooltip = {"gui.search-with-focus","__CONTROL__focus-search__"},
	}

	-- map marker button
	local map_button = header.add {
		name = "display-map-marker",
		type = "sprite-button",
		sprite = "display-map-marker",
		style = markers and "display_small_button_active" or "display_small_button",
		tooltip = {"controls.display-map-marker"},
	}
	map_button.enabled = (find_entity_render(selected) ~= nil)

	-- close button
	local close_button = header.add {
		name = "display-header-close",
		type = "sprite-button",
		style = "display_small_button",
		sprite = "utility/close_white",
		tooltip = {"controls.close-gui"},
	}

	-- body frame
	local content_frame = frame.add {
		type = "frame",
		name = "inner-frame",
		style = "display_inside_frame",
		direction = "vertical",
	}
	content_frame.style.top_margin = 8

	-- tabbed pane
	local display_tabs = content_frame.add {
		name = "display-tabs",
		type = "tabbed-pane",
		style = "display_tabbed_pane",
	}
	
	-- build a table of info about existing items/fluids
	-- groups of subgroups of sprites -> localised_string
	local button_table = {}
	for prototype_type,prototypes in pairs(DID.elem_prototypes) do
		for _,prototype in pairs(game[prototypes]) do
			if not DID.displays[prototype.name] and not ((prototype_type == "item" and prototype.has_flag("hidden")) or (prototype_type == "fluid" and prototype.hidden)) then
				local group = (prototype.group.name == "fluids") and "intermediate-products" or prototype.group.name 
				if not DID.group_blacklist[group] then
					if button_table[group] == nil then button_table[group] = {}	end
					if button_table[group][prototype.subgroup.name] == nil then	button_table[group][prototype.subgroup.name] = {} end
					button_table[group][prototype.subgroup.name][prototype_type.."/"..prototype.name] = prototype.localised_name
				end
			end
		end
	end
	
	-- determine the biggest tab size
	local max_rows = 0
	for group,subgroups in pairs(button_table) do
		local rows = 0
		for subgroup,entries in pairs(subgroups) do
			rows = rows + math.ceil(table_size(entries)/DID.grid_columns)
		end
		max_rows = math.max(rows,max_rows)
	end
	
	-- set up tabs
	local tab_index = 1
	for group,subgroups in pairs(button_table) do
		-- this tab
		local this_tab = false
		local tab = display_tabs.add{
			type = "tab",
			name = "display-tab:"..group,
			caption = "[img=item-group/"..group.."]",
			tooltip = game.item_group_prototypes[group].localised_name,
			style = "display_tab",
		}
		tab.style.width = (420/table_size(button_table))
		local tab_content = display_tabs.add {
			type = "frame",
			direction = "vertical",
			name = "display-group:"..group,
			style = "display_tab_deep_frame",
		}
		tab_content.style.width = 400

		-- add table of buttons
		for subgroup,entries in pairs(subgroups) do
			local subgroup_table = tab_content.add{
				type = "table",
				column_count = DID.grid_columns,
				style = "display_buttons",
			}
			local count = 0
			for sprite,localised_name in pairs(entries) do
				-- add the button
				local button = subgroup_table.add{
					type = "sprite-button",
					name = "display-symbol:"..sprite,
					sprite = sprite,
					style = (render_sprite and render_sprite == sprite) and "display_button_selected" or "quick_bar_slot_button",
					tooltip = localised_name,
				}
				button.ignored_by_interaction = (render_sprite and render_sprite == sprite)
				if not this_tab and (render_sprite and render_sprite == sprite) then this_tab = true end
				count = count + 1
			end
		end
		display_tabs.add_tab(tab,tab_content)

		-- switch selection to this tab if rendered sprite exists
		if this_tab then
			display_tabs.selected_tab_index = tab_index
		end
		tab_index = tab_index + 1
	end
	
	-- make all tabs as big as biggest
	for _,tab in pairs(display_tabs.tabs) do
		tab.content.style.height = math.min(640, max_rows * 40)
	end
end

local function player_cannot_reach(player,entity)
	player.play_sound{path = "utility/cannot_build"}
	player.create_local_flying_text{text={"cant-reach"}, position=entity.position}
end

local function set_up_display_from_ghost(entity,tags)
	if tags["display-plate-sprite-type"] and tags["display-plate-sprite-name"] then
		render_overlay(entity, tags["display-plate-sprite-type"], tags["display-plate-sprite-name"])
		if tags["display-plate-sprite-map-marker"] then
			add_map_marker(entity, tags["display-plate-sprite-type"], tags["display-plate-sprite-name"])
		end
	end
end

-- local function reset_globals()
	-- global.translations = nil
-- end

------------------------------------------------------------------------------------------------------------------------------------------------------

-- event handlers

-- script.on_configuration_changed(reset_globals)
script.on_event(defines.events.on_gui_closed, gui_close)
script.on_event(defines.events.on_gui_click, gui_click)
script.on_event(defines.events.on_player_mined_entity, event_raised_destroy, get_display_event_filter())
script.on_event(defines.events.on_robot_mined_entity, event_raised_destroy, get_display_event_filter())
script.on_event(defines.events.on_entity_died, event_raised_destroy, get_display_event_filter())

script.on_event(defines.events.on_built_entity, function (event)
	if event.tags and event.created_entity and event.created_entity.valid then
		set_up_display_from_ghost(event.created_entity, event.tags)
	end
end, get_display_event_filter())

script.on_event(defines.events.on_robot_built_entity, function (event)
	if event.tags and event.created_entity and event.created_entity.valid then
		set_up_display_from_ghost(event.created_entity, event.tags)
	end
end, get_display_event_filter())

script.on_event(defines.events.script_raised_revive, function (event)
	if event.tags and event.entity and event.entity.valid and is_a_display(event.entity) then
		set_up_display_from_ghost(event.entity, event.tags)
	end
end)

script.on_event("deadlock-open-gui", function(event)
    local player = game.players[event.player_index]
	if player.cursor_stack and player.cursor_stack.valid_for_read then return end
    local selected = player and player.selected
    if selected and selected.valid and is_a_display(selected) then 
		if player.can_reach_entity(selected) then
			create_display_gui(player, selected)
		else
			player_cannot_reach(player, selected)
		end
	end
end)

script.on_event("deadlock-focus-search", function(event)
    local player = game.players[event.player_index]
	local frame = player.gui.screen[DID.custom_gui]
	if frame then
		local search = player.gui.screen[DID.custom_gui]["display-header"]["display-search-button"]
		toggle_search(player, search, true)
	end
end)

script.on_event(defines.events.on_entity_settings_pasted, function (event)
	if event.destination and event.destination.valid and event.source and event.source.valid and is_a_display(event.destination) and is_a_display(event.source) then
		local spritetype, spritename = get_render_sprite_info(event.source)
		if spritetype and spritename then
			destroy_render(event.destination)
			render_overlay(event.destination, spritetype, spritename)
			remove_markers(event.destination)
			if get_has_map_marker(event.source) then
				add_map_marker(event.destination, spritetype, spritename)
			end
		end
	end
end)

script.on_event(defines.events.on_player_setup_blueprint, function (event)
    local player = game.players[event.player_index]
	local blueprint = nil
	if player and player.blueprint_to_setup and player.blueprint_to_setup.valid_for_read then blueprint = player.blueprint_to_setup
	elseif player and player.cursor_stack.valid_for_read and player.cursor_stack.name == "blueprint" then blueprint = player.cursor_stack end
	if blueprint then
		for index,entity in pairs(event.mapping.get()) do
			local stype,sname = get_render_sprite_info(entity)
			if stype and sname then
				blueprint.set_blueprint_entity_tag(index, "display-plate-sprite-type", stype)
				blueprint.set_blueprint_entity_tag(index, "display-plate-sprite-name", sname)
				blueprint.set_blueprint_entity_tag(index, "display-plate-sprite-map-marker", get_has_map_marker(entity))
			end
		end
	end
end)

script.on_event(defines.events.on_gui_location_changed, function (event)
	if event.element.name == DID.custom_gui then
		set_global_player_info(event.player_index, "display_gui_location", event.element.location)
	end
end)

script.on_event(defines.events.on_player_changed_position, function (event)
    local player = game.players[event.player_index]
	if player.gui.screen[DID.custom_gui] then
		local last_display = get_global_player_info(event.player_index, "last_display")
		if last_display and last_display.valid and not player.can_reach_entity(last_display) then
			gui_close(event)
		end
	end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    local player = game.players[event.player_index]
	if player and event.element.name == "display-search-textfield" then
		display_filter_tabs(player, event.element.text)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------

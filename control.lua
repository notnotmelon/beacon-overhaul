local function get_bounding_points(entity, area)
	area = area or 0
	
	local box = entity.prototype.collision_box
	local position = entity.position
	local right_bottom_x = math.ceil(position.x + box.right_bottom.x + area - 1)
	local right_bottom_y = math.ceil(position.y + box.right_bottom.y + area - 1)
	local left_top_x = math.floor(position.x + box.left_top.x - area)
	local left_top_y = math.floor(position.y + box.left_top.y - area)
	
	return right_bottom_x, right_bottom_y, left_top_x, left_top_y
end

local function check_machine(machine)
	if machine.type == 'beacon' then return end
	local allowed_effects = machine.prototype.allowed_effects
	if allowed_effects == nil or next(allowed_effects) == nil then return end
	
	local index = machine.unit_number
	local surface = machine.surface
	local surface_name = surface.name
	local beacon_tiles = global.beacon_tiles[surface_name] or {}
	global.beacon_tiles[surface_name] = beacon_tiles
	local right_bottom_x, right_bottom_y, left_top_x, left_top_y = get_bounding_points(machine)
	local seen
	
	for x = left_top_x, right_bottom_x do
		local row = beacon_tiles[x]
		if row then for y = left_top_y, right_bottom_y do
			if row[y] then for _, v in pairs(row[y]) do
				if seen and seen ~= v then
					if global.overloaded_machines[index] == nil then
						surface.create_entity{
							name = 'flying-text',
							position = machine.position,
							text = {'beacon-overload'}
						}
						machine.active = false
						global.overloaded_machines[index] = {
							machine,
							rendering.draw_sprite{
								sprite = 'beacon-overload',
								x_scale = 0.5,
								y_scale = 0.5,
								target = machine,
								surface = surface
							}
						}
					end
					return
				end
				
				seen = v
				
			end end
		end end
    end

	if global.overloaded_machines[index] then
		surface.create_entity{
			name = 'flying-text',
			position = machine.position,
			text = {'beacon-overload-ended'}
		}
		machine.active = true
		rendering.destroy(global.overloaded_machines[index][2])
		global.overloaded_machines[index] = nil
	end
end

local function safe_insert(t, v)
	for _, v_ in ipairs(t) do
		if v_ == v then return end
	end
	t[#t + 1] = v
end

local function remove_all(t, v)
	local n = #t
	for i = 1, n do
		if t[i] == v then
			table.remove(t, i)
			i = i - 1
			n = n - 1
		end
	end
end

local function update_beacon_tiles(beacon, mode)
	local prototype = beacon.prototype
	local area = prototype.supply_area_distance
	local surface = beacon.surface
	local unit_number = beacon.unit_number
	local right_bottom_x, right_bottom_y, left_top_x, left_top_y = get_bounding_points(beacon, area)
	local surface_name = surface.name
	local beacon_tiles = global.beacon_tiles[surface_name] or {}
	global.beacon_tiles[surface_name] = beacon_tiles
	
	for x = left_top_x, right_bottom_x do
		local row = beacon_tiles[x] or {}
		beacon_tiles[x] = row
		for y = left_top_y, right_bottom_y do
			if mode == 'add' then
				row[y] = row[y] or {}
				safe_insert(row[y], unit_number)
			else
				remove_all(row[y], unit_number)
				if #row[y] == 0 then row[y] = nil end
			end
		end
		
		if mode == 'subtract' and next(row) == nil then
			beacon_tiles[x] = nil
		end
    end
	
	for _, entity in ipairs(surface.find_entities{{left_top_x, left_top_y}, {right_bottom_x + 1, right_bottom_y + 1}}) do
		check_machine(entity)
	end
end

local function setup()
	global.overloaded_machines = {}
	global.beacon_tiles = {}
	
	for _, surface in pairs(game.surfaces) do
		for _, beacon in ipairs(surface.find_entities_filtered{type = 'beacon'}) do
			if beacon.name ~= 'productivity-beacon' then
				update_beacon_tiles(beacon, 'add')
			end
		end
	end
end

script.on_init(setup)
script.on_configuration_changed(setup)

local function on_built(event)
	local entity = event.created_entity or event.entity
	
	if entity.type == 'beacon' then
		if entity.name == 'productivity-beacon' then
			entity.insert{name = 'beacon-productivity-module', count = 2}
		else
			update_beacon_tiles(entity, 'add')
		end
	else
		check_machine(entity)
	end
end

script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)

local function on_destroyed(event)
	local entity = event.entity
	if entity.name == 'productivity-beacon' then
		if event.player_index or event.robot then
			local destroyer = event.robot or game.players[event.player_index]
			destroyer.remove_item{name = 'beacon-productivity-module', count = 100}
		end
	else
		update_beacon_tiles(entity, 'subtract')
	end
end

local filter = {{filter = 'type', type = 'beacon'}}
script.on_event(defines.events.on_player_mined_entity, on_destroyed, filter)
script.on_event(defines.events.on_robot_mined_entity, on_destroyed, filter)
script.on_event(defines.events.on_entity_died, on_destroyed, filter)
script.on_event(defines.events.script_raised_destroy, on_destroyed, filter)

script.on_event(defines.events.on_gui_opened, function(event)
	if event.entity and event.entity.name == 'productivity-beacon' then
		game.players[event.player_index].opened = nil
	end
end)

script.on_event(defines.events.on_player_fast_transferred, function(event)
	local entity = event.entity
	if entity.name ~= 'productivity-beacon' then return end
	entity.insert{name = 'beacon-productivity-module', count = 2}
	game.players[event.player_index].remove_item{name = 'beacon-productivity-module', count = 100}
end)

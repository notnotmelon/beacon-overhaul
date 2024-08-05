local function merge(prototype, new_data)
    prototype = table.deepcopy(prototype)
    for k, v in pairs(new_data) do
        if v == 'nil' then
            prototype[k] = nil
        else
            prototype[k] = v
        end
    end
    return prototype
end

data:extend {
    merge(data.raw.beacon.beacon, {
		allowed_effects = {'productivity'},
		distribution_effectivity = 1,
		drawing_box = {{-1.5, -2.2}, {1.5, 1.3}},
		graphics_set = require('beacon-graphics'),
		icon = '__base__/graphics/icons/beacon.png',
		icon_mipmaps = 4,
		icon_size = 64,
		minable = {
			mining_time = 0.2,
			result = 'productivity-beacon'
		},
		module_specification = {
			module_info_icon_shift = {0, 0},
			module_info_max_icons_per_row = 2,
			module_info_multi_row_initial_height_modifier = -0.3,
			module_slots = 2
		},
		name = 'productivity-beacon',
		energy_usage = '600kW',
		flags = {'no-automated-item-removal', 'no-automated-item-insertion', 'player-creation', 'placeable-player', 'not-rotatable'}
	}),
	{
		category = 'productivity',
		effect = {productivity = {bonus = 0.02}},
		icon = '__base__/graphics/icons/productivity-module.png',
		icon_mipmaps = 4,
		icon_size = 64,
		flags = {'hidden', 'only-in-cursor', 'not-stackable'},
		name = 'beacon-productivity-module',
		order = 'c[productivity]-b[productivity-module-1]',
		stack_size = 1,
		subgroup = 'module',
		tier = 1,
		type = 'module',
		art_style = 'vanilla',
		beacon_tint = {primary = {255, 112, 10}, secondary = {255, 209, 3}, tertiary = {180, 116, 102}, quaternary = {255, 138, 66}},
		requires_beacon_alt_mode = false
    },
	{
		icon = '__base__/graphics/icons/beacon.png',
		icon_mipmaps = 4,
		icon_size = 64,
		name = 'productivity-beacon',
		order = 'a[productivity-beacon]',
		place_result = 'productivity-beacon',
		stack_size = 50,
		subgroup = 'module',
		type = 'item'
    },
	{
		enabled = false,
		energy_required = 15,
		ingredients = {
			{'productivity-module', 2},
			{'advanced-circuit', 20},
			{'low-density-structure', 10},
			{'copper-cable', 10}
		},
		name = 'productivity-beacon',
		result = 'productivity-beacon',
		type = 'recipe'
    },
	{
		effects = {{
			recipe = 'productivity-beacon',
			type = 'unlock-recipe'
		}},
		icon = '__base__/graphics/technology/effect-transmission.png',
		icon_size = 256,
		icon_mipmaps = 4,
		name = 'productivity-beacon',
		prerequisites = {
			'effect-transmission',
			'low-density-structure'
		},
		type = 'technology',
		unit = {
			count = 100,
			ingredients = {
				{'automation-science-pack', 1},
				{'logistic-science-pack', 1},
				{'chemical-science-pack', 1},
				{'production-science-pack', 1}
			},
			time = 30
		}
    },
	{
		type = 'sprite',
		name = 'beacon-overload',
		filename = '__beacon-overhaul__/graphics/beacon-overload.png',
		priority = 'extra-high-no-scale',
		width = 64,
		height = 64,
		flags = {'icon'}
	}
}

data.raw.beacon.beacon.energy_usage = '1.6MW'

data.raw.technology['productivity-beacon'].enabled = settings.startup['productivity-beacon'].value

for _, beacon in pairs(data.raw.beacon) do
	if beacon.name ~= 'productivity-beacon' then
		beacon.module_specification.module_slots = math.min(65535, beacon.module_specification.module_slots * 2)
		beacon.supply_area_distance = math.min(64, beacon.supply_area_distance * 3)
	end
end

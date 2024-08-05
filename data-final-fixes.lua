local productivity_3 = data.raw.module['productivity-module-3']

if productivity_3 then
	data.raw.module['beacon-productivity-module'].limitation = productivity_3.limitation
	data.raw.module['beacon-productivity-module'].limitation_blacklist = productivity_3.limitation_blacklist
	data.raw.module['beacon-productivity-module'].limitation_message_key = productivity_3.limitation_message_key
end

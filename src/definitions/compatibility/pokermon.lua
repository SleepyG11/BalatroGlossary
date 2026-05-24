if not next(SMODS.find_mod("Pokermon")) then
	return
end

if open_pokedex then
	function open_pokedex(target)
		return Glossary.show_card_info(target)
	end
end
if not get_family_keys then
	get_family_keys = function(target)
		return {}
	end
end

Glossary.InfoSection({
	key = "poke_evolutions",
	order = -10,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return CardArea(0, 0, 7, G.CARD_H, {
			type = "title_2",
			highlight_limit = 0,
			collection = true,
		})
	end,
	is_empty = function(self, area)
		return #area.cards == 0
	end,
	destroy = function(self, area)
		area:remove()
	end,
	render = function(self, area)
		return Glossary.UI.basic_section(self, { n = G.UIT.O, config = { object = area } })
	end,
	insert = function(self, area, result)
		area:emplace(result)
	end,
})
Glossary.InfoSection({
	key = "poke_evolution_materials",
	order = -5,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return CardArea(0, 0, 7, G.CARD_H, {
			type = "title_2",
			highlight_limit = 0,
			collection = true,
		})
	end,
	is_empty = function(self, area)
		return #area.cards == 0
	end,
	destroy = function(self, area)
		area:remove()
	end,
	render = function(self, area)
		return Glossary.UI.basic_section(self, { n = G.UIT.O, config = { object = area } })
	end,
	insert = function(self, area, result)
		area:emplace(result)
	end,
})

Glossary.InfoQueueProcessor({
	key = "poke_evolutions",
	order = 25,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if
			context.target_type == "card"
			and context.target.facing ~= "back"
			and not context.target.poke_change_sprite
			and (context.target.config.center.stage or context.target.config.center.poke_multi_item)
		then
			local keys = get_family_keys(context.target)
			local full_keys = {}
			for _, key in ipairs(keys) do
				keys[key] = true
			end

			for _, key in ipairs(keys) do
				local center = G.P_CENTERS[key]
				Glossary.insert(
					center and center.set == "Joker" and "poke_evolutions" or "poke_evolution_materials",
					function(area)
						local card = Glossary.safe_card_from_center(key, area)
						if card then
							local subkeys = get_family_keys(card)
							if center.megas then
								table.insert(subkeys, "c_poke_megastone")
							end
							for _, subkey in ipairs(subkeys) do
								if not keys[subkey] then
									keys[subkey] = true
									table.insert(full_keys, subkey)
								end
							end
							return card
						end
					end
				)
			end
			for _, key in ipairs(full_keys) do
				local center = G.P_CENTERS[key]
				Glossary.insert(
					center and center.set == "Joker" and "poke_evolutions" or "poke_evolution_materials",
					function(area)
						return Glossary.safe_card_from_center(key, area)
					end
				)
			end
		end
	end,

	conditions = { before = true },
})

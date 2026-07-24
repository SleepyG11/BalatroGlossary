if not next(SMODS.find_mod("Pokermon")) then
	return
end

local pokermon_api = pokermon
if not pokermon_api then
	pokermon_api = {
		open_pokedex = open_pokedex,
		get_family_keys = get_family_keys,
		get_type = get_type,
		set_type_badge = poke_set_type_badge,
		energy = {
			is_energizable = is_energizable,
			get_total_energy = get_total_energy,
			max = energy_max,
		},
	}
end

pokermon_api.open_pokedex = function(target)
	return Glossary.show_card_info(target)
end

local poke_process_family_keys = function(keys)
	local r = {}
	for _, key in ipairs(keys) do
		if type(key) == "string" then
			table.insert(r, { key = key })
		else
			table.insert(r, key)
		end
	end
	return r
end

local function poke_energy_render(info)
	local energy_card_area = CardArea(0, 0, 1, 1, {
		type = "title_2",
		collection = true,
		highlight_limit = 0,
	})
	local exceptions = {
		Dark = "darkness",
	}
	local energy_key = exceptions[info.etype] or string.lower(info.etype)
	local energy_card = Glossary.safe_card_from_center("c_poke_" .. energy_key .. "_energy", energy_card_area)
	if energy_card then
		energy_card:hard_set_T(0, 0, G.CARD_W / 2, G.CARD_H / 2)
		energy_card_area:emplace(energy_card)
	else
		energy_card_area:remove()
		energy_card_area = nil
	end

	local energy_badges = {}
	pokermon_api.set_type_badge(nil, info.card, energy_badges)

	local progress = info.max_energy == 0 and 0 or info.current_energy / info.max_energy
	progress = math.max(0, math.min(1, progress))

	local max_energy = 0
	if info.can_get_energy then
		max_energy = (info.unlimited_energy_config or info.unlimited_energy) and "∞" or info.max_energy
	end
	local is_infinte_because_config = info.can_get_energy and info.unlimited_energy_config and not info.unlimited_energy

	local progress_text_render = {
		n = G.UIT.ROOT,
		config = { colour = { 0, 0, 0, 0.0 }, padding = 0.1, r = 0.25, align = "cm" },
		nodes = {
			{
				n = G.UIT.T,
				config = {
					text = info.current_energy,
					scale = 0.32,
					colour = G.C.UI.TEXT_LIGHT,
					shadow = true,
				},
			},
			{
				n = G.UIT.T,
				config = {
					text = "/",
					scale = 0.32,
					colour = G.C.UI.TEXT_LIGHT,
					shadow = true,
				},
			},
			{
				n = G.UIT.T,
				config = {
					text = max_energy,
					scale = 0.32,
					colour = G.C.UI.TEXT_LIGHT,
					shadow = true,
					font = max_energy == "∞" and G.FONTS[2] or nil,
				},
			},
			is_infinte_because_config and {
				n = G.UIT.T,
				config = {
					text = "(" .. string.lower(localize("b_config")) .. ")",
					scale = 0.24,
					colour = mix_colours(G.C.UI.TEXT_LIGHT, { 0, 0, 0, 1 }, 0.8),
					shadow = true,
				},
			} or nil,
		},
	}

	local progress_bar = {
		n = G.UIT.R,
		config = {
			minh = 0.475,
			minw = 3.8,
			r = 0.25,
			colour = mix_colours(info.sticker.badge_colour, G.C.BLACK, 0.2),
			func = "glossary_attach_uibox",
			ref_table = {
				definition = progress_text_render,
				config = {
					align = "cm",
				},
			},
		},
		nodes = {
			progress > 0 and {
				n = G.UIT.R,
				config = {
					minh = 0.475,
					minw = 3.8 * progress,
					r = 0.25,
					colour = info.sticker.badge_colour,
					emboss = 0.05,
				},
			} or nil,
		},
	}

	local content_render = {
		n = G.UIT.R,
		config = {},
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cm", maxw = 2 },
				nodes = energy_badges,
			},
			{ n = G.UIT.C, config = { minw = 0.1 } },
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = {
					progress_bar,
				},
			},
		},
	}

	local area_render = energy_card_area and {
		n = G.UIT.O,
		config = {
			object = energy_card_area,
		},
	} or nil

	return content_render, area_render
end

Glossary.InfoSection({
	key = "poke_energy",
	order = -15,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return {}
	end,
	is_empty = function(self, info)
		return not info.sticker
	end,
	destroy = function(self, info) end,
	render = function(self, info)
		local content_render, area_render = poke_energy_render(info)
		return Glossary.UI.extendable_section(self, content_render, {
			right_content = area_render,
		})
	end,
	insert = function(self, info, card)
		info.card = card
		info.etype = pokermon_api.get_type(card)
		info.sticker = SMODS.Stickers[string.lower(info.etype) .. "_sticker"]

		info.current_energy = pokermon_api.energy.get_total_energy(card) or 0
		info.max_energy = (
			pokermon_api.energy.max
			+ (G.GAME and G.GAME.energy_plus or 0)
			+ (card.ability.extra.e_limit_up or 0)
		) or 0
		info.unlimited_energy = card.config.center.no_energy_limit or info.etype == "Bird" or false
		info.unlimited_energy_config = pokermon_config.unlimited_energy
		info.can_get_energy = pokermon_api.energy.is_energizable(card)
	end,
})
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
	key = "poke_energy",
	order = 25,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if
			context.target_type == "card"
			and context.target.facing ~= "back"
			and pokermon_api.get_type(context.target)
		then
			Glossary.insert("poke_energy", function()
				return context.target
			end)
		end
	end,

	conditions = { before = true },
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
			local family_keys = poke_process_family_keys(pokermon_api.get_family_keys(context.target))
			local get_family_table_key = function(item)
				return item.key .. "_" .. (item.form or "nil")
			end
			local full_keys = {}
			for _, family_key in ipairs(family_keys) do
				family_keys[get_family_table_key(family_key)] = true
			end

			for _, family_item in ipairs(family_keys) do
				local center = G.P_CENTERS[family_item.key]
				Glossary.insert(
					center and center.set == "Joker" and "poke_evolutions" or "poke_evolution_materials",
					function(area)
						local card = Glossary.safe_card_from_center(center and center.key, area)
						if card then
							if family_item.form then
								card.ability.extra.form = family_item.form
								center:set_sprites(card)
								if center.set_ability then
									center:set_ability(card)
								end
							end
							local subfamily = poke_process_family_keys(pokermon_api.get_family_keys(card))
							if center.megas then
								table.insert(subfamily, { key = "c_poke_megastone" })
							end
							for _, subkey in ipairs(subfamily) do
								local full_subkey = get_family_table_key(subkey)
								if not family_keys[full_subkey] then
									family_keys[full_subkey] = true
									table.insert(full_keys, subkey)
								end
							end
							return card
						end
					end
				)
			end
			for _, key in ipairs(full_keys) do
				local center = G.P_CENTERS[key.key]
				Glossary.insert(
					center and center.set == "Joker" and "poke_evolutions" or "poke_evolution_materials",
					function(area)
						local card = Glossary.safe_card_from_center(center and center.key, area)
						if card then
							if key.form then
								card.ability.extra.form = key.form
								center:set_sprites(card)
								if center.set_ability then
									center:set_ability(card)
								end
							end
							return card
						end
					end
				)
			end
		end
	end,

	conditions = { before = true },
})
Glossary.InfoQueueProcessor({
	key = "poke_energy_info_queue",
	order = 10,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if
			context.entry.set == "Other"
			and context.entry.key == "energy"
			and context.target_type == "card"
			and pokermon_api.get_type(context.target)
		then
			return true
		end
	end,
})

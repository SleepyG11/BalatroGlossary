Glossary.InfoSection({
	key = "target_center",
	order = 0,
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
		return {
			n = G.UIT.R,
			config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1 },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, minh = 0.5 },
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = "Card modifiers",
								scale = 0.32,
								shadow = true,
								colour = G.C.UI.TEXT_LIGHT,
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
					nodes = {
						{ n = G.UIT.O, config = { object = area } },
					},
				},
			},
		}
	end,
	insert = function(self, area, result)
		area:emplace(result)
	end,
})
Glossary.InfoSection({
	key = "center",
	order = 100,
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
		return {
			n = G.UIT.R,
			config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1 },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, minh = 0.5 },
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = "Related objects",
								scale = 0.32,
								shadow = true,
								colour = G.C.UI.TEXT_LIGHT,
							},
						},
					},
				},
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
					nodes = {
						{ n = G.UIT.O, config = { object = area } },
					},
				},
			},
		}
	end,
	insert = function(self, area, result)
		area:emplace(result)
	end,
})
Glossary.InfoSection({
	key = "skip_tag",
	order = 2,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return {}
	end,
	is_empty = function(self, nodes)
		return #nodes == 0
	end,
	destroy = function(self, nodes) end,
	render = function(self, nodes)
		return {
			n = G.UIT.R,
			config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, padding = 0.1, align = "cm", minw = 7 },
			nodes = {
				{
					n = G.UIT.R,
					nodes = nodes,
				},
			},
		}
	end,
	insert = function(self, nodes, result)
		table.insert(nodes, {
			n = G.UIT.C,
			config = { align = "cm" },
			nodes = {
				result,
			},
		})
	end,
})

--

Glossary.InfoQueueProcessor({
	key = "playing_card_center",
	order = -100,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if
			context.source_type == "card"
			and context.source.config.center_key ~= "c_base"
			and context.source.config.card
			and (context.source.config.card.value or context.source.config.card.suit)
		then
			local insert_result = Glossary.insert("target_center", function(area)
				local card = SMODS.create_card({ key = "c_base", front = false, area = area })
				local success = pcall(function()
					card:set_ability(context.source.config.center_key, false, false)
				end)
				if success then
					return card
				else
					card:remove()
				end
			end)
			if not insert_result then
				table.insert(context.info_queue, 1, context.source.config.center)
			end
		end
	end,
	conditions = { before = true },
})

Glossary.InfoQueueProcessor({
	key = "sticker",
	order = 1,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local is_collection_card = Glossary.is_collection_card_junk(context)
		if context.entry.set == "Other" and SMODS.Stickers[context.entry.key] then
			if is_collection_card and context.target.ability[context.entry.key] then
				Glossary.specify_mod(SMODS.Stickers[context.entry.key].mod)
			else
				local is_card_modifier = context.target_type == "card"
					and context.target.ability[context.entry.key]
					and not context.extra.processed_card_modifiers[context.entry.key]
				if is_card_modifier then
					context.extra.processed_card_modifiers[context.entry.key] = true
				end
				return Glossary.insert(is_card_modifier and "target_center" or "center", function(area)
					local card = SMODS.create_card({ key = "c_base", front = false, area = area })
					SMODS.Stickers[context.entry.key]:apply(card, true)
					return card
				end)
			end
		end
	end,
})
Glossary.InfoQueueProcessor({
	key = "seal",
	order = 2,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local is_collection_card = Glossary.is_collection_card_junk(context)
		if context.entry.set == "Other" then
			local seal_key_match = context.entry.key:match("^(.*)_seal$")
			if seal_key_match then
				local seal = G.P_SEALS[seal_key_match] or G.P_SEALS[seal_key_match:gsub("^%l", string.upper)]
				if seal then
					if is_collection_card and context.target.seal == seal.key then
						Glossary.specify_mod(seal.mod)
					else
						local is_card_modifier = context.target_type == "card"
							and context.target.seal == seal.key
							and not context.extra.processed_card_modifiers[seal.key]
						if is_card_modifier then
							context.extra.processed_card_modifiers[seal.key] = true
						end
						return Glossary.insert(is_card_modifier and "target_center" or "center", function(area)
							local card =
								SMODS.create_card({ key = "c_base", front = false, seal = seal.key, area = area })
							return card
						end)
					end
				end
			end
		end
		if context.entry.set == "Seal" and G.P_SEALS[context.entry.key] then
			if is_collection_card and context.target.seal == context.entry.key then
				Glossary.specify_mod(G.P_SEALS[context.entry.key].mod)
			else
				local is_card_modifier = context.target_type == "card"
					and context.target.seal == context.entry.key
					and not context.extra.processed_card_modifiers
				if is_card_modifier then
					context.extra.processed_card_modifiers[context.entry.key] = true
				end
				return Glossary.insert(is_card_modifier and "target_center" or "center", function(area)
					local card =
						SMODS.create_card({ key = "c_base", front = false, seal = context.entry.key, area = area })
					return card
				end)
			end
		end
	end,
})
Glossary.InfoQueueProcessor({
	key = "skip_tag",
	order = 3,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if G.P_TAGS[context.entry.key] then
			return Glossary.insert("skip_tag", function(nodes)
				local tag_ui = Tag(context.entry.key, true):generate_UI()
				return tag_ui
			end)
		end
	end,
})
Glossary.InfoQueueProcessor({
	key = "edition",
	order = 4,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if context.entry.set == "Edition" and G.P_CENTERS[context.entry.key] then
			local is_card_modifier = context.target_type == "card"
				and context.target.edition
				and context.target.edition.key == context.entry.key
				and not context.extra.processed_card_modifiers[context.entry.key]
			if is_card_modifier then
				context.extra.processed_card_modifiers[context.entry.key] = true
			end
			return Glossary.insert(is_card_modifier and "target_center" or "center", function(area)
				local card = SMODS.create_card({
					key = context.entry.key,
					front = false,
					edition = context.entry.key,
					area = area,
				})
				return card
			end)
		end
	end,
})
Glossary.InfoQueueProcessor({
	key = "center",
	order = 1000,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if context.individual and G.P_CENTERS[context.entry.key] then
			return Glossary.insert("center", function(area)
				local card = SMODS.create_card({ key = "c_base", front = false, area = area })
				local success = pcall(function()
					card:set_ability(context.entry.key, false, false)
				end)
				if success then
					return card
				else
					card:remove()
				end
			end)
		end
	end,
})

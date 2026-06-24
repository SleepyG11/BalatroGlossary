Glossary.InfoQueueProcessor({
	key = "pre_meta",
	order = -100,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if
			context.target_type == "card"
			and context.source_type == "card"
			and context.source.config.center_key ~= "c_base"
			and not (
				context.source.playing_card
				or (
					context.source.config.card
					and (context.source.config.card.value or context.source.config.card.suit)
				)
			)
		then
			Glossary.process_meta("centers", context.target.config.center)
		end
		if context.target_type == "back" then
			Glossary.process_meta("centers", context.target)
		end
		if context.target_type == "blind" then
			Glossary.process_meta("blinds", context.target)
		end
		if context.target_type == "tag" then
			Glossary.process_meta("tags", context.target)
		end
	end,
	conditions = { before = true },
})

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
			and (
				context.source.playing_card
				or (
					context.source.config.card
					and (context.source.config.card.value or context.source.config.card.suit)
				)
			)
		then
			local insert_result = Glossary.insert("target_modifiers", function(area)
				return Glossary.safe_card_from_center(context.source.config.center_key, area)
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
				Glossary.process_meta("stickers", SMODS.Stickers[context.entry.key])
			else
				local is_card_modifier = context.target_type == "card"
					and context.target.ability[context.entry.key]
					and not context.extra.processed_card_modifiers[context.entry.key]
				if is_card_modifier then
					context.extra.processed_card_modifiers[context.entry.key] = true
				end
				return Glossary.insert(is_card_modifier and "target_modifiers" or "centers", function(area)
					return SMODS.create_card({
						key = "c_base",
						front = false,
						area = area,
						stickers = { context.entry.key },
						force_stickers = true,
					})
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
						Glossary.process_meta("seals", seal)
					else
						local is_card_modifier = context.target_type == "card"
							and context.target.seal == seal.key
							and not context.extra.processed_card_modifiers[seal.key]
						if is_card_modifier then
							context.extra.processed_card_modifiers[seal.key] = true
						end
						return Glossary.insert(is_card_modifier and "target_modifiers" or "centers", function(area)
							return SMODS.create_card({ key = "c_base", front = false, seal = seal.key, area = area })
						end)
					end
				end
			end
		end
		if context.entry.set == "Seal" and G.P_SEALS[context.entry.key] then
			if is_collection_card and context.target.seal == context.entry.key then
				Glossary.specify_mod(G.P_SEALS[context.entry.key].mod)
				Glossary.process_meta("seals", G.P_SEALS[context.entry.key])
			else
				local is_card_modifier = context.target_type == "card"
					and context.target.seal == context.entry.key
					and not context.extra.processed_card_modifiers
				if is_card_modifier then
					context.extra.processed_card_modifiers[context.entry.key] = true
				end
				return Glossary.insert(is_card_modifier and "target_modifiers" or "centers", function(area)
					return SMODS.create_card({ key = "c_base", front = false, seal = context.entry.key, area = area })
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
			return Glossary.insert("skip_tags", function(nodes)
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
		if context.entry.set == "Edition" then
			local edition_key = context.entry.key
			if edition_key:match("^e_negative_") then
				edition_key = "e_negative"
			end
			if G.P_CENTERS[edition_key] then
				local is_card_modifier = context.target_type == "card"
					and context.target.edition
					and context.target.edition.key == edition_key
					and not context.extra.processed_card_modifiers[edition_key]
				if is_card_modifier then
					context.extra.processed_card_modifiers[edition_key] = true
				end
				return Glossary.insert(is_card_modifier and "target_modifiers" or "centers", function(area)
					return SMODS.create_card({
						key = edition_key,
						front = false,
						edition = edition_key,
						area = area,
					})
				end)
			end
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
		if G.P_CENTERS[context.entry.key] then
			return Glossary.insert("centers", function(area)
				return Glossary.safe_card_from_center(context.entry.key, area)
			end)
		end
	end,
})

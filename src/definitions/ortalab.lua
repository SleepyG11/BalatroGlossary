if not next(SMODS.find_mod("ortalab")) or not Ortalab then
	return
end

Glossary.InfoQueueProcessor({
	key = "ortalab_curse",
	order = 4,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local is_collection_card = Glossary.is_collection_card_junk(context)
		if context.entry.set == "Curse" and Ortalab.Curses[context.entry.key] then
			if is_collection_card and context.target.curse == context.entry.key then
				Glossary.specify_mod(Ortalab.Curses[context.entry.key].mod)
			else
				local is_card_modifier = context.target_type == "card"
					and context.target.curse == context.entry.key
					and not context.extra.processed_card_modifiers[context.entry.key]
				if is_card_modifier then
					context.extra.processed_card_modifiers[context.entry.key] = true
				end
				return Glossary.insert(is_card_modifier and "target_modifiers" or "centers", function(area)
					local card = SMODS.create_card({
						key = "c_base",
						front = false,
						area = area,
					})
					card:set_curse(context.entry.key, false, true)
					return card
				end)
			end
		end
	end,
})

Glossary.InfoQueueProcessor({
	key = "ortalab_zodiac_mod",
	order = -50,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if context.target_type == "tag" and getmetatable(context.target) == Zodiac then
			Glossary.specify_mod(SMODS.Mods["ortalab"])
		end
	end,
	conditions = { before = true },
})

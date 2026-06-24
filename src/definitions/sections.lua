Glossary.InfoSection({
	key = "target_modifiers",
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
		return Glossary.UI.basic_section(self, { n = G.UIT.O, config = { object = area } })
	end,
	insert = function(self, area, result)
		area:emplace(result)
	end,
})
Glossary.InfoSection({
	key = "centers",
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
		return Glossary.UI.basic_section(self, { n = G.UIT.O, config = { object = area } })
	end,
	insert = function(self, area, result)
		area:emplace(result)
	end,
})
Glossary.InfoSection({
	key = "skip_tags",
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
		return Glossary.UI.basic_section(self, {
			n = G.UIT.R,
			config = { minw = 7, align = "cm" },
			nodes = nodes,
		})
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
Glossary.InfoSection({
	key = "collection_parts",
	order = 3,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return {}
	end,
	is_empty = function(self, items)
		return #items == 0
	end,
	destroy = function(self, items) end,
	render = function(self, items)
		local nodes = {}
		for _, item in ipairs(items) do
			local button = Glossary.UI.collection_part_button(item)
			if button then
				table.insert(nodes, button)
			end
		end
		return Glossary.UI.basic_section(self, {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.05 },
			nodes = nodes,
		})
	end,
	insert = function(self, items, result)
		if type(result) == "string" then
			result = {
				type = result,
			}
		end
		for _, item in ipairs(items) do
			if item.type == result.type and item.set == result.set then
				return
			end
		end
		table.insert(items, result)
	end,
})
Glossary.InfoSection({
	key = "poker_hands",
	order = 4,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return {}
	end,
	is_empty = function(self, items)
		return #items == 0
	end,
	destroy = function(self, items) end,
	render = function(self, items)
		local nodes = {}
		for _, item in ipairs(items) do
			table.insert(nodes, Glossary.UI.simple_poker_hand(item.type, item.simple, G.STAGE ~= G.STAGES.RUN))
		end
		return Glossary.UI.basic_section(self, {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.05 },
			nodes = nodes,
		})
	end,
	insert = function(self, items, result)
		if type(result) == "string" then
			result = {
				type = result,
			}
		end
		for _, item in ipairs(items) do
			if item.type == result.type then
				return
			end
		end
		table.insert(items, result)
	end,
})

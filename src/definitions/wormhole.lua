Glossary.InfoSection({
	key = "worm_spaceship_modules",
	order = -10,
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
			config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1 },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, minh = 0.5 },
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = "Spaceship modules",
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
					nodes = nodes,
				},
			},
		}
	end,
	insert = function(self, nodes, result)
		nodes[#nodes + 1] = result
	end,
})
Glossary.InfoSection({
	key = "worm_spacetarts",
	order = -9,
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
								text = "Spacetarts",
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

Glossary.InfoQueueProcessor({
	key = "worm_spaceship_modules",
	order = 50,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local entry = context.entry
		if entry.set == "tbp_module" then
			local desc_nodes = {}
			localize({
				type = "descriptions",
				set = "tbp_module",
				key = entry.key,
				nodes = desc_nodes,
				text_colour = darken(Wormhole.tbp.module_colours[entry.module_type], 0.15),
				vars = entry.vars,
				background_colour = G.C.BLUE,
			})
			desc_nodes.tbp_module = entry.module_type
			desc_nodes.module_info = entry.module_info
			return Glossary.insert("worm_spaceship_modules", function(nodes)
				return {
					n = G.UIT.R,
					config = { align = "cl" },
					nodes = {
						{
							n = G.UIT.R,
							config = {
								align = "cl",
								colour = darken(Wormhole.tbp.module_colours[desc_nodes.tbp_module], 0.5),
								padding = 0.05,
								emboss = 0.1,
								-- minw = 7,
							},
							nodes = {
								Wormhole.tbp.module_tooltip(desc_nodes),
							},
						},
					},
				}
			end)
		end
	end,
})
Glossary.InfoQueueProcessor({
	key = "worm_spacetarts",
	order = 50,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		if context.source_type == "card" and context.source.tarts and #context.source.tarts > 0 then
			context.target.tarts = context.source.tarts
			for _, v in ipairs(context.source.tarts) do
				Glossary.insert("worm_spacetarts", function(area)
					local card = SMODS.create_card({ key = "c_base", front = false, area = area })
					local success = pcall(function()
						card:set_ability(v.center_key, false, false)
					end)
					if success then
						return card
					else
						card:remove()
					end
				end)
			end
		end
	end,
	conditions = { before = true },
})

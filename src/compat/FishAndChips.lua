if not next(SMODS.find_mod("FishAndChips")) then
	return
end

-- Related fish
Glossary.InfoSection({
	key = "fac_related_fish_centers",
	order = 10,
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
		local cardareas = {}
		local current_area
		local next_index = 1
		local items_per_line = nodes.per_line or 8
		for _, center in ipairs(nodes) do
			if next_index % items_per_line == 1 or not current_area then
				current_area = CardArea(0, 0, 7, G.CARD_H / 2.5, {
					collection = true,
					type = "title_2",
					fac_compendium = true,
				})
				table.insert(cardareas, {
					n = G.UIT.R,
					nodes = {
						{
							n = G.UIT.O,
							config = {
								object = current_area,
							},
						},
					},
				})
			end
			local card = Glossary.safe_card_from_center(center, current_area)
			if card then
				current_area:emplace(card)
				card:hard_set_T(nil, nil, card.T.w / 2, card.T.h / 2)
			end
			next_index = next_index + 1
		end

		return Glossary.UI.basic_section(self, nodes, {
			n = G.UIT.R,
			config = { colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1 },
			nodes = cardareas,
		})
	end,
	insert = function(self, nodes, result)
		nodes[#nodes + 1] = result
	end,
})

-- Environments

local function create_environment_image(environment, scale, collideable)
	scale = scale or 1
	local environment_key = environment.key
	return {
		n = G.UIT.C,
		config = {
			align = "tm",
			colour = G.C.WHITE,
			func = collideable and "glossary_setup_fac_environment" or nil,
			button = collideable and "glossary_open_fac_environment" or nil,
			glossary_fac_environment = environment,
			can_collide = not not collideable,
			hover = not not collideable,
			button_dist = 0,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					shader = "fac_ui_image",
					atlas = "fac_comp_locations",
					pos = environment.background_pos,
					colour = G.C.WHITE,
					minw = 293 / 73.25 * scale,
					minh = 174 / 73.25 * scale,
					align = "tl",
				},
				nodes = {},
			},
			{
				n = G.UIT.R,
				config = { minh = 1, colour = G.C.WHITE, align = "br", padding = 0.1 },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cr", maxw = 293 / 73.25 * scale - 0.4 },
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = localize({ key = environment_key, set = "fac_Env", type = "name_text" }),
									scale = 0.5,
									colour = FishAndChips.C.COMPENDIUM_TEXT,
									font = SMODS.Fonts.fac_collection,
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { align = "tr", maxw = 293 / 73.25 * scale - 0.4 },
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = localize("ph_fac_by") .. environment.ppu_artist[1],
									scale = 0.35,
									colour = FishAndChips.C.COMPENDIUM_TEXT,
									font = SMODS.Fonts.fac_collection,
								},
							},
						},
					},
				},
			},
		},
	}
end
function G.FUNCS.glossary_open_fac_environment(e)
	Glossary.show_info("fac_environment", e.config.glossary_fac_environment, "ui_button", e)
end
function G.FUNCS.glossary_setup_fac_environment(e)
	e.config.func = nil
	e.glossary_func = function()
		Glossary.show_info("fac_environment", e.config.glossary_fac_environment, "ui_button", e)
	end
end

Glossary.InfoSection({
	key = "fac_enviroments",
	order = 5,
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
		local images = {}
		local current_row = nil

		local next_index = 1
		for _, env in ipairs(nodes) do
			local environment = FishAndChips.Environments[env]
			if environment then
				if next_index % 3 == 1 or not current_row then
					current_row = { n = G.UIT.R, config = { padding = 0.1, minw = 7, align = "cm" }, nodes = {} }
					table.insert(images, current_row)
				end

				table.insert(current_row.nodes, create_environment_image(environment, 2.1 / 3.85, true))
				next_index = next_index + 1
			end
		end

		return Glossary.UI.basic_section(self, nodes, {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = images,
		})
	end,
	insert = function(self, nodes, result)
		nodes[#nodes + 1] = result
	end,
})
Glossary.InfoQueueProcessor({
	key = "fac_environments",
	order = 0,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local center = context.target_center
		if center then
			local envs = center.environments
			if envs then
				for env, weight in pairs(envs) do
					Glossary.insert("fac_enviroments", function()
						return env
					end)
				end
			end
		end
	end,

	conditions = { before = true },
})

Glossary.entry_points.fac_environment = function(target, source_type, source)
	Glossary.UI.prepare_overlay_menu()

	local context = Glossary.processing.new_context("fac_environment", target, source_type, source)
	Glossary.specify_mod(target.mod)
	Glossary.processing.process_context(context)

	local env_nodes = {}
	localize({
		type = "descriptions",
		set = "fac_Env",
		key = target.key,
		nodes = env_nodes,
	})

	local main_render = {
		n = G.UIT.R,
		config = {
			padding = 0.1,
			colour = { 0, 0, 0, 0.1 },
			align = "cm",
			r = 0.25,
		},
		nodes = {
			create_environment_image(target, 1, false),
		},
	}

	for _, k in ipairs(SMODS.get_attribute_pool(target.key)) do
		if not SMODS.hide_from_collection(G.P_CENTERS[k]) then
			Glossary.insert("fac_related_fish_centers", function()
				return G.P_CENTERS[k]
			end)
		end
	end

	local description = {
		n = G.UIT.R,
		config = {
			padding = 0.05,
			r = 0.12,
			colour = lighten(G.C.JOKER_GREY, 0.5),
			emboss = 0.07,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					padding = 0.07,
					r = 0.1,
					colour = adjust_alpha(darken(G.C.BLACK, 0.1), 0.8),
				},
				nodes = {
					desc_from_rows(env_nodes, nil, 5),
				},
			},
		},
	}

	Glossary.show_info_ui({
		context = context,
		main = main_render,
		description = {
			description,
		},
	})
end

-- Fishing stats

local function create_empty_stats_section(section, data, text)
	return Glossary.UI.basic_section(section, data, {
		n = G.UIT.R,
		config = { align = "cm", minw = 7 },
		nodes = {
			{
				n = G.UIT.R,
				config = {
					align = "cm",
					padding = 0.1,
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = text,
							scale = 0.32,
							colour = adjust_alpha(G.C.UI.TEXT_LIGHT, 0.6),
						},
					},
				},
			},
		},
	})
end

local function create_fish_stats_section(section, data, stats, profile_stats)
	local is_catched = stats and stats.first_catch
	if not is_catched then
		return create_empty_stats_section(section, data, localize("gloss_fac_not_caught_yet"))
	end

	local first_catch = stats.first_catch
	local first_rod = stats.rod
	local times_caught = stats.times_caught or 0

	-- Left part
	local rod_area = CardArea(0, 0, 0.65, G.CARD_H / 3, {
		type = "title_2",
		collection = true,
		card_limit = 1,
	})
	local rod_card = Glossary.safe_card_from_center(first_rod, rod_area)
	if rod_card then
		rod_card:hard_set_T(0, 0, rod_card.T.w / 3, rod_card.T.h / 3)
		rod_area:emplace(rod_card)
	end
	local left_render = {
		n = G.UIT.C,
		config = {
			padding = 0.1,
			r = 0.25,
			colour = { 0, 0, 0, 0.1 },
			align = "cm",
		},
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cm", padding = 0.1 },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", maxw = 1.7, minw = 1.7 },
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = localize("gloss_fac_first_catch"),
									scale = 0.32,
									colour = G.C.UI.TEXT_LIGHT,
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { align = "cm", maxw = 1.7, minw = 1.7 },
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = first_catch,
									scale = 0.4,
									colour = G.C.ORANGE,
								},
							},
						},
					},
				},
			},
			{
				n = G.UIT.O,
				config = {
					object = rod_area,
				},
			},
		},
	}

	-- Right part
	local row = function(left, right, colour)
		return {
			n = G.UIT.R,
			nodes = {
				{
					n = G.UIT.C,
					config = {
						minw = 2.35,
						maxw = 2.35,
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = left,
								scale = 0.32,
								colour = G.C.UI.TEXT_LIGHT,
							},
						},
					},
				},
				{
					n = G.UIT.C,
					config = {
						minw = 1.5,
						maxw = 1.5,
						align = "r",
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = right,
								scale = 0.32,
								colour = colour or G.C.ORANGE,
							},
						},
					},
				},
			},
		}
	end

	local colours = { -- TODO: are these colours okay?
		darken(G.C.RED, 0.1),
		G.C.RED,
		G.C.ORANGE,
		G.C.YELLOW,
		G.C.GREEN,
		G.ARGS.LOC_COLOURS.edition,
	}

	local fish_center = G.P_CENTERS[data.center.key]
	local stat_proto = fish_center.stats

	local weight_perc = (stats.record_weight - stat_proto.weight.min)
		/ (stat_proto.weight.max - stat_proto.weight.min)
		* 100
	local length_perc = (stats.record_length - stat_proto.length.min)
		/ (stat_proto.length.max - stat_proto.length.min)
		* 100

	local weight_col_index = math.min(5, math.max(math.floor(weight_perc / 20), 1))
	local weight_col = stats.record_weight == stat_proto.weight.max and colours[6]
		or mix_colours(
			colours[weight_col_index + 1],
			colours[math.max(weight_col_index, 1)],
			(weight_perc - (weight_col_index * 20)) / 20
		)

	local length_col_index = math.min(5, math.max(math.floor(length_perc / 20), 1))
	local length_col = stats.record_length == stat_proto.length.max and colours[6]
		or mix_colours(
			colours[length_col_index + 1],
			colours[length_col_index],
			(length_perc - (length_col_index * 20)) / 20
		)

	local right_render = {
		n = G.UIT.C,
		config = {
			padding = 0.1,
			r = 0.25,
			colour = { 0, 0, 0, 0.1 },
			align = "cm",
		},
		nodes = {
			-- TODO: wait for new API
			row(localize("gloss_fac_times_caught"), times_caught),
			row(
				localize("gloss_fac_biggest_fish"),
				FishAndChips.format_measurement(stats.record_weight, "weight"),
				weight_col
			),
			row(
				localize("gloss_fac_longest_fish"),
				FishAndChips.format_measurement(stats.record_length, "length"),
				length_col
			),
		},
	}

	return Glossary.UI.basic_section(section, data, {
		n = G.UIT.R,
		config = { align = "cm" },
		nodes = {
			right_render,
			{
				n = G.UIT.C,
				config = { minw = 0.1 },
			},
			left_render,
		},
	})
end
local function create_bait_stats_section(section, data, stats, profile_stats)
	if not stats then
		return create_empty_stats_section(section, data, localize("gloss_fac_not_used_yet"))
	end
	local row = function(left, right, colour)
		return {
			n = G.UIT.R,
			config = {},
			nodes = {
				{
					n = G.UIT.C,
					config = {
						minw = 2.25,
						maxw = 2.25,
						align = "cl",
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = left,
								scale = 0.32,
								colour = G.C.UI.TEXT_LIGHT,
							},
						},
					},
				},
				{
					n = G.UIT.C,
					config = {
						minw = 1,
						maxw = 1,
						align = "cr",
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = right,
								scale = 0.32,
								colour = colour or G.C.ORANGE,
							},
						},
					},
				},
			},
		}
	end

	local left = {
		n = G.UIT.C,
		config = { padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
		nodes = {
			row(localize("gloss_fac_fish_caught"), stats.fish_caught),
			row(localize("gloss_fac_fish_lost"), stats.fish_lost),
		},
	}
	local right = {
		n = G.UIT.C,
		config = { padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
		nodes = {
			row(localize("gloss_fac_perfect_catches"), stats.perfect_catch),
			row(localize("gloss_fac_treasures"), stats.treasure),
		},
	}

	return Glossary.UI.basic_section(section, data, {
		n = G.UIT.R,
		config = { align = "cm" },
		nodes = {
			left,
			{ n = G.UIT.C, config = { minw = 0.1 } },
			right,
		},
	})
end
local function create_rod_stats_section(section, data, stats, profile_stats)
	if not stats then
		return create_empty_stats_section(section, data, localize("gloss_fac_not_used_yet"))
	end

	local row = function(left, right, colour)
		return {
			n = G.UIT.R,
			config = {},
			nodes = {
				{
					n = G.UIT.C,
					config = {
						minw = 2.25,
						maxw = 2.25,
						align = "cl",
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = left,
								scale = 0.32,
								colour = G.C.UI.TEXT_LIGHT,
							},
						},
					},
				},
				{
					n = G.UIT.C,
					config = {
						minw = 1,
						maxw = 1,
						align = "cr",
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = right,
								scale = 0.32,
								colour = colour or G.C.ORANGE,
							},
						},
					},
				},
			},
		}
	end

	local left = {
		n = G.UIT.C,
		config = { padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
		nodes = {
			row(localize("gloss_fac_fish_caught"), stats.fish_caught),
			row(localize("gloss_fac_fish_lost"), stats.fish_lost),
		},
	}
	local right = {
		n = G.UIT.C,
		config = { padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
		nodes = {
			row(localize("gloss_fac_perfect_catches"), stats.perfect_catch),
			row(localize("gloss_fac_treasures"), stats.treasure),
		},
	}

	return Glossary.UI.basic_section(section, data, {
		n = G.UIT.R,
		config = { align = "cm" },
		nodes = {
			left,
			{ n = G.UIT.C, config = { minw = 0.1 } },
			right,
		},
	})
end

Glossary.InfoSection({
	key = "fac_fishing_stats",
	order = 0,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return {}
	end,
	is_empty = function(self, nodes)
		return not nodes.center
	end,
	destroy = function(self, nodes) end,
	render = function(self, nodes)
		local profile_data = G.PROFILES[G.SETTINGS.profile].fac_fishing or {}
		local target_data
		if nodes.type == "fish" then
			target_data = profile_data.fish_data or {}
			return create_fish_stats_section(self, nodes, target_data[nodes.center.key], profile_data)
		elseif nodes.type == "rod" then
			target_data = profile_data.rod_data or {}
			return create_rod_stats_section(self, nodes, target_data[nodes.center.key], profile_data)
		elseif nodes.type == "bait" then
			target_data = profile_data.bait_data or {}
			return create_bait_stats_section(self, nodes, target_data[nodes.center.key], profile_data)
		end
	end,
	insert = function(self, nodes, result)
		nodes.type = result.type
		nodes.center = result.center
	end,
	loc_vars = function(self, nodes)
		return {
			key = self.key .. "_" .. nodes.type,
		}
	end,
})
Glossary.InfoQueueProcessor({
	key = "fac_fishing_stats",
	order = 0,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local center = context.target_center
		if center then
			local type
			if center.set == "fac_Fish" then
				type = "fish"
			elseif center.set == "fac_Rod" then
				type = "rod"
			elseif center.set == "fac_Bait" then
				type = "bait"
			end
			if type then
				Glossary.insert("fac_fishing_stats", function()
					return {
						center = center,
						type = type,
					}
				end)
			end
		end
	end,

	conditions = { before = true },
})

--

local old_info_ui = Glossary.show_info_ui
function Glossary.show_info_ui(input, ...)
	if input then
		local content = input.description
		local context = input.context
		if context and context.target_type == "card" and context.target_center then
			if context.target_center.environments then
				local r = table.remove(content, 1)
				if r then
					UIBox({
						definition = r,
						config = {},
					}):remove()
				end
			end
		end
	end
	return old_info_ui(input, ...)
end

local old_save_external = Glossary.history.save_external
function Glossary.history.save_external(target_back_funcs, ...)
	target_back_funcs = target_back_funcs or {}
	target_back_funcs.fac_return_to_mods = true
	target_back_funcs.exit_overlay_menu_mxms = true
	return old_save_external(target_back_funcs, ...)
end

local old_get_center = Glossary.get_target_center
function Glossary.get_target_center(target_type, target, ...)
	if target_type == "fac_environment" then
		return target
	end
	return old_get_center(target_type, target, ...)
end

local old_comped = FishAndChips.Compendium.environment_page
function FishAndChips.Compendium.environment_page(page_number, ...)
	local r = old_comped(page_number, ...)
	pcall(function()
		local target = r.nodes[2].nodes[1]
		if target.nodes[1].config.atlas == "fac_comp_locations" then
			local environment_key = FishAndChips.Environment.obj_buffer[page_number]
			local environment = FishAndChips.Environments[environment_key]
			target.config.glossary_fac_environment = environment
			target.config.func = "glossary_setup_fac_environment"
			target.config.button = "glossary_open_fac_environment"
			target.config.hover = true
			target.config.can_collide = true
			target.config.button_dist = 0
		end
	end)
	return r
end

local old_create_dev_card = FishAndChips.Compendium.dev_card
function FishAndChips.Compendium.dev_card(...)
	Glossary.ARGS.force_ignore_on_cards = true
	local r = old_create_dev_card(...)
	Glossary.ARGS.force_ignore_on_cards = nil
	return r
end

if not next(SMODS.find_mod("FishAndChips")) then
	return
end

local function create_environment_image(environment, scale, collideable)
	scale = scale or 1
	local environment_key = environment.key
	return {
		n = G.UIT.C,
		config = {
			align = "tm",
			colour = G.C.WHITE,
			func = collideable and "glossary_setup_pac_environment" or nil,
			button = collideable and "glossary_open_pac_environment" or nil,
			glossary_pac_environment = environment,
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
						config = { align = "cr" },
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
						config = { align = "tr" },
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

function G.FUNCS.glossary_open_pac_environment(e)
	Glossary.show_info("pac_environment", e.config.glossary_pac_environment, "ui_button", e)
end
function G.FUNCS.glossary_setup_pac_environment(e)
	e.config.func = nil
	e.glossary_func = function()
		Glossary.show_info("pac_environment", e.config.glossary_pac_environment, "ui_button", e)
	end
end

Glossary.InfoSection({
	key = "fac_enviroments",
	order = 0,
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
				if next_index % 2 == 1 or not current_row then
					current_row = { n = G.UIT.R, config = { padding = 0.1 }, nodes = {} }
					table.insert(images, current_row)
				end
				next_index = next_index + 1
				table.insert(current_row.nodes, create_environment_image(environment, 3.25 / 3.85, true))
			end
		end

		return Glossary.UI.basic_section(self, {
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

-- --

Glossary.entry_points.pac_environment = function(target, source_type, source)
	Glossary.UI.prepare_overlay_menu()

	local context = Glossary.processing.new_context("pac_environment", target, source_type, source)
	Glossary.specify_mod(target.mod)
	Glossary.processing.process_context(context)

	local main_render = {
		n = G.UIT.R,
		config = {
			padding = 0.1,
			colour = { 0, 0, 0, 0.1 },
		},
		nodes = {
			create_environment_image(target, 1, false),
		},
	}

	local fish_pool = {}
	for _, k in ipairs(SMODS.get_attribute_pool(target.key)) do
		if not SMODS.hide_from_collection(G.P_CENTERS[k]) then
			table.insert(fish_pool, G.P_CENTERS[k])
		end
	end

	local cardareas = {}
	local current_area
	local next_index = 1
	for _, center in ipairs(fish_pool) do
		if next_index % 8 == 1 or not current_area then
			current_area = CardArea(0, 0, 7, G.CARD_H / 3, {
				collection = true,
				type = "title_2",
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

	Glossary.show_info_ui({
		context = context,
		main = main_render,
		rows = {
			Glossary.UI.section("Fish and Chips: Fish in Environment", {
				n = G.UIT.R,
				config = { colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1 },
				nodes = cardareas,
			}),
		},
	})
end

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
	if target_type == "pac_environment" then
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
			target.config.glossary_pac_environment = environment
			target.config.func = "glossary_setup_pac_environment"
			target.config.button = "glossary_open_pac_environment"
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

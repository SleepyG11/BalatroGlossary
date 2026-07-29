if not next(SMODS.find_mod("FishAndChips")) then
	return
end

local function create_environment_image(environment)
	local environment_key = environment.key
	return {
		n = G.UIT.C,
		config = { align = "tm", colour = G.C.WHITE },
		nodes = {
			{
				n = G.UIT.R,
				config = {
					shader = "fac_ui_image",
					atlas = "fac_comp_locations",
					pos = environment.background_pos,
					colour = G.C.WHITE,
					minw = 293 / 73.25 / 3.85 * 3.25,
					minh = 174 / 73.25 / 3.85 * 3.25,
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
				table.insert(current_row.nodes, create_environment_image(environment))
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

-- Glossary.entry_points.pac_environment = function(target, source_type, source)
-- 	Glossary.UI.prepare_overlay_menu()

-- 	local context = Glossary.processing.new_context("pac_environment", target, source_type, source)
-- 	Glossary.specify_mod(target.mod_id)

-- 	Glossary.show_info_ui({
-- 		context = context,
-- 		main = create_environment_image(target),
-- 		description = {},
-- 	})
-- end

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

local function create_credits_rows()
	local credits_area = CardArea(0, 0, 7, G.CARD_H, {
		type = "title_2",
		highlight_limit = 0,
		collection = true,
	})
	local me_card = SMODS.create_card({ key = "c_base", front = false, area = credits_area })
	me_card.children.center.atlas = G.ASSET_ATLAS["gloss_me_joker"]
	me_card.children.center:set_sprite_pos({ x = 0, y = 0 })
	credits_area:emplace(me_card)

	local configs = {
		n = G.UIT.R,
		config = { minw = 7, align = "cm" },
		nodes = {
			create_toggle({
				label = localize("gloss_toggle_bypass_lock"),
				ref_table = Glossary.cc,
				ref_value = "bypass_lock",
				callback = function(b)
					Glossary.cc.bypass_lock = b
					Glossary.config.save()
				end,
				scale = 0.8,
				label_scale = 0.32,
				w = 5,
			}),
			create_toggle({
				label = localize("gloss_toggle_bypass_discovery"),
				ref_table = Glossary.cc,
				ref_value = "bypass_discovery",
				callback = function(b)
					Glossary.cc.bypass_discovery = b
					Glossary.config.save()
				end,
				scale = 0.8,
				label_scale = 0.32,
				w = 5,
			}),
			create_toggle({
				label = localize("gloss_toggle_use_mods_colours"),
				ref_table = Glossary.cc,
				ref_value = "use_mods_colours",
				callback = function(b)
					Glossary.cc.use_mods_colours = b
					Glossary.config.save()
				end,
				scale = 0.8,
				label_scale = 0.32,
				w = 5,
			}),
		},
	}

	return {
		{
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				Glossary.UI.section(
					localize({
						type = "name_text",
						set = "Glossary_Other",
						key = "config",
						vars = {},
					}),
					configs
				),
				Glossary.UI.section(
					localize({
						type = "name_text",
						set = "Glossary_Other",
						key = "credits",
						vars = {},
					}),
					{ n = G.UIT.O, config = { object = credits_area } }
				),
			},
		},
	}
end

function Glossary.show_mod_config(menu_data, source_type, source)
	menu_data = menu_data or {}
	Glossary.UI.prepare_overlay_menu()

	local tag_sprite = Sprite(0, 0, 1.205 * 1, 1.205 * 1, G.ASSET_ATLAS["gloss_modicon"], { x = 0, y = 0 })
	tag_sprite:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
	})
	tag_sprite.float = true
	tag_sprite.states.hover.can = true
	tag_sprite.states.drag.can = false
	tag_sprite.states.collide.can = true

	local old_check_for_unlock = check_for_unlock
	check_for_unlock = function() end

	local context = Glossary.new_info_queue_context(
		"mod_config",
		{ sprite = tag_sprite, from_smods = menu_data.from_smods },
		source_type,
		source
	)
	context.AUT = { main = {}, info = {}, type = {}, name = {}, badges = {} }

	context.AUT.badges = {
		create_badge("v" .. Glossary.current_mod.version, mix_colours(G.C.CHIPS, G.C.GREEN, 0.5)),
		create_badge("By SleepyG11", G.C.CHIPS),
	}
	context.AUT.name =
		localize({ type = "name", set = "Glossary_Other", key = "mod_card", vars = {}, nodes = context.AUT.name })
	localize({ type = "descriptions", set = "Glossary_Other", key = "mod_card", vars = {}, nodes = context.AUT.main })

	local rows = create_credits_rows()

	check_for_unlock = old_check_for_unlock

	-- TODO: fill ability for credit cards
	-- TODO: fill containers with credits

	local main_render = {
		n = G.UIT.R,
		config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, align = "cm" },
		nodes = {
			{
				n = G.UIT.O,
				config = { object = tag_sprite },
			},
		},
	}

	local description = {
		n = G.UIT.R,
		config = { padding = 0.05, r = 0.12, colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.07 },
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.07, r = 0.1, colour = adjust_alpha(G.C.BLACK, 0.8) },
				nodes = {
					name_from_rows(context.AUT.name),
					desc_from_rows(context.AUT.main),
					{ n = G.UIT.R, config = { align = "cm", padding = 0.03 }, nodes = context.AUT.badges },
				},
			},
		},
	}

	Glossary.show_mod_config_ui({
		context = context,
		main = main_render,
		description = {
			description,
		},
		rows = rows,
	})
end

function Glossary.show_mod_config_ui(input)
	local content = input.description
	local context = input.context
	local rows = input.rows

	local left_content = {
		n = G.UIT.C,
		config = {
			align = "cm",
			padding = 0.1,
		},
		nodes = {
			{
				n = G.UIT.C,
				config = {
					align = "cm",
					padding = 0.1,
					colour = { 0, 0, 0, 0.1 },
					r = 0.25,
				},
				nodes = {
					input.main,
					Glossary.UI.draggable_scrollable_content(content, 7, 6, 0.1),
				},
			},
		},
	}
	local right_content
	if #rows > 0 then
		right_content = {
			n = G.UIT.C,
			config = { align = "cm" },
			nodes = {
				Glossary.UI.draggable_scrollable_content(rows, 10, 6 + G.CARD_H, 0.1),
			},
		}
	end

	context.mod = Glossary.current_mod
	local mod = context.mod

	Glossary.history.save()
	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			colour = mod and ((mod.ui_config or {}).collection_colour or (mod.ui_config or {}).colour),
			bg_colour = mod and ((mod.ui_config or {}).collection_bg_colour or (mod.ui_config or {}).bg_colour),
			back_colour = mod and ((mod.ui_config or {}).collection_back_colour or (mod.ui_config or {}).back_colour),
			outline_colour = mod
				and ((mod.ui_config or {}).collection_outline_colour or (mod.ui_config or {}).outline_colour),
			back_func = context.target.from_smods and "mods_button" or nil,
			contents = {
				Glossary.UI.header(input),
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						left_content,
						right_content,
					},
				},
			},
		}),
	})
	Glossary.history.load()
	Glossary.history.add(context)
end

G.E_MANAGER:add_event(Event({
	trigger = "immediate",
	no_delete = true,
	pause_force = true,
	blocking = false,
	blockable = false,
	func = function()
		local old_open_UI = G.FUNCS.openModUI_Glossary or function() end
		G.FUNCS.openModUI_Glossary = function(e, ...)
			old_open_UI(e, ...)
			Glossary.show_mod_config({ from_smods = true }, "ui_button", e)
		end
		return true
	end,
}))

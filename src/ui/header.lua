function Glossary.UI.header_button(args)
	return {
		n = G.UIT.C,
		config = {
			align = "cm",
			padding = 0.1,
			shadow = true,
			r = 0.25,
			hover = true,
			collideable = true,
			colour = args.colour or G.C.CHIPS,
			func = args.func,
			button = args.button,
			ref_table = args.ref_table,
			minw = args.minw,
		},
		nodes = {
			args.content or {
				n = G.UIT.T,
				config = {
					scale = 0.3,
					text = args.text,
					font = args.font,
					colour = args.text_colour or G.C.UI.TEXT_LIGHT,
				},
			},
		},
	}
end
function Glossary.UI.header_separator()
	return { n = G.UIT.C, config = { minh = 0.4, minw = 0.04, colour = { 1, 1, 1, 0.25 } } }
end

function Glossary.UI.header_move_history_button(dx)
	return Glossary.UI.header_button({
		func = "glossary_can_move_history",
		button = "glossary_move_history",
		colour = G.C.CHIPS,
		minw = 0.75,
		font = G.FONTS[2],
		text = dx < 0 and "←" or "→",
		ref_table = {
			dx = dx,
		},
	})
end
function Glossary.UI.header_mod_additions_button(mod)
	if not mod then
		return
	end
	local old_active_mod_ui = G.ACTIVE_MOD_UI
	G.ACTIVE_MOD_UI = mod
	local has_additions = mod and buildAdditionsTab(mod)
	G.ACTIVE_MOD_UI = old_active_mod_ui

	if not has_additions then
		return
	end
	return Glossary.UI.header_button({
		button = "glossary_open_mod_additions",
		colour = mod.badge_colour,
		minw = 1.5,
		text = mod.name .. ": " .. localize("b_additions"),
		ref_table = {
			mod = mod,
		},
		text_colour = mod.badge_text_colour,
	})
end
function Glossary.UI.header_vanilla_collection_button()
	return Glossary.UI.header_button({
		button = "glossary_open_vanilla_collection",
		colour = G.C.GREEN,
		minw = 1.5,
		text = localize("b_collection"),
	})
end
function Glossary.UI.header_close_button()
	return Glossary.UI.header_button({
		button = "glossary_exit_overlay_menu",
		colour = G.C.MULT,
		text = "X",
		minw = 0.5,
		font = G.FONTS[1],
	})
end
function Glossary.UI.header_back_button(back)
	return Glossary.UI.header_button({
		button = "glossary_show_back_info",
		colour = G.C.ORANGE,
		minw = 1,
		text = localize("b_deck"),
		ref_table = {
			back = back,
		},
	})
end
function Glossary.UI.header_glossary_config_button()
	return Glossary.UI.header_button({
		button = "glossary_open_glossary_mod_config",
		colour = G.C.BLUE,
		minw = 0.5,
		content = {
			n = G.UIT.O,
			config = {
				object = SMODS.create_sprite(0, 0, 0.3, 0.3, "mod_tags", { x = 2, y = 0 }),
			},
		},
	})
end
function Glossary.UI.header_stake_button(stake)
	return Glossary.UI.header_button({
		button = "exit_overlay_menu",
		colour = G.C.ORANGE,
		minw = 1,
		text = localize("b_stake"),
		ref_table = {
			stake = stake,
		},
	})
end

--

G.FUNCS.glossary_move_history = function(e)
	Glossary.history.move(e.config.ref_table.dx)
end
G.FUNCS.glossary_can_move_history = function(e)
	if Glossary.history.can_move(e.config.ref_table.dx) then
		e.config.colour = G.C.CHIPS
		e.config.button = "glossary_move_history"
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

--

G.FUNCS.glossary_open_mod_additions = function(e)
	G.ACTIVE_MOD_UI = e.config.ref_table.mod
	SMODS.LAST_SELECTED_MOD_TAB = "additions"
	G.FUNCS["openModUI_" .. G.ACTIVE_MOD_UI.id](e)
end
G.FUNCS.glossary_open_vanilla_collection = function(e)
	G.ACTIVE_MOD_UI = nil
	G.FUNCS.your_collection(e)
end
G.FUNCS.glossary_show_back_info = function(e)
	Glossary.show_back_info(e.config.ref_table.back, "ui_button", e)
end
G.FUNCS.glossary_show_stake_info = function(e)
	Glossary.show_stake_info(e.config.ref_table.stake, "ui_button", e)
end

G.FUNCS.glossary_open_glossary_mod_config = function(e)
	Glossary.show_mod_config({}, "ui_button", e)
end
--

G.FUNCS.glossary_setup_header_right_buttons = function(e)
	e.config.func = nil
	e.config.ref_table.config.major = e
	e.config.ref_table.config.parent = e
	e.children.glossary_right_buttons = UIBox(e.config.ref_table)
end

function Glossary.UI.header(input)
	local mod = input.context.mod
	local back = G.STAGE == G.STAGES.RUN and G.GAME.selected_back and G.GAME.selected_back.effect.center
	local stake = nil
	-- local stake = G.STAGE == G.STAGES.RUN and G.GAME.stake and G.P_STAKES[SMODS.stake_from_index(G.GAME.stake)]

	return {
		n = G.UIT.R,
		config = {
			colour = { 0, 0, 0, 0.1 },
			r = 0.25,
			padding = 0.1,
			minw = 14,
			func = "glossary_setup_header_right_buttons",
			ref_table = {
				definition = {
					n = G.UIT.ROOT,
					config = { colour = G.C.CLEAR },
					nodes = {
						{
							n = G.UIT.R,
							config = { padding = 0.1, align = "cm" },
							nodes = {
								back and Glossary.UI.header_back_button(back) or nil,
								-- stake and Glossary.UI.header_stake_button(stake) or nil,
								(back or stake) and Glossary.UI.header_separator() or nil,
								Glossary.UI.header_mod_additions_button(mod),
								Glossary.UI.header_vanilla_collection_button(),
								Glossary.UI.header_separator(),
								Glossary.UI.header_glossary_config_button(),
								Glossary.UI.header_close_button(),
							},
						},
					},
				},
				config = {
					align = "cri",
				},
			},
		},
		nodes = {
			Glossary.UI.header_move_history_button(-1),
			Glossary.UI.header_move_history_button(1),
		},
	}
end

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
			{
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
		text = "Mod Additions",
		ref_table = {
			mod = mod,
		},
		text_colour = mod.badge_text_colour,
	})
end
function Glossary.UI.header_vanilla_collection_button()
	return Glossary.UI.header_button({
		button = "glossary_open_vanilla_collection",
		colour = G.C.MULT,
		minw = 1.5,
		text = localize("b_collection"),
	})
end

--

G.FUNCS.glossary_move_history = function(e)
	Glossary.move_history(e.config.ref_table.dx)
end
G.FUNCS.glossary_can_move_history = function(e)
	if Glossary.can_move_history(e.config.ref_table.dx) then
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

--

function Glossary.UI.header(input)
	local mod = Glossary.get_target_mod(input.context.target_type, input.context.target)

	return {
		n = G.UIT.R,
		config = { colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1, minw = 14 },
		nodes = {
			Glossary.UI.header_move_history_button(-1),
			Glossary.UI.header_move_history_button(1),
			Glossary.UI.header_mod_additions_button(mod),
			Glossary.UI.header_vanilla_collection_button(),
		},
	}
end

function Glossary.UI.header_button(args)
	return {
		n = G.UIT.C,
		config = {
			align = "cm",
			shadow = true,
			r = 0.25,
			hover = true,
			collideable = true,
			colour = args.colour or G.C.CHIPS,
			func = args.func,
			button = args.button or "glossary_noop",
			ref_table = args.ref_table,
			minw = args.minw,
			shader = args.shader,
		},
		nodes = {
			args.prepend_content,
			{
				n = G.UIT.C,
				config = { align = "cm", padding = 0.1 },
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
			},
			args.append_content,
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
function Glossary.UI.header_mod_icon(mod)
	if not mod then
		return
	end
	local tag_atlas, tag_pos, tag_message, specific_vars = getModtagInfo(mod)

	local tag_sprite_tab = nil
	local units = 0.5
	local tag_sprite =
		SMODS.create_sprite(0, 0, 0.8 * 1, 0.8 * 1, SMODS.get_atlas(tag_atlas) or SMODS.get_atlas("tags"), tag_pos)
	tag_sprite.T.scale = 1
	tag_sprite_tab = {
		n = G.UIT.C,
		config = { align = "cm", padding = 0 },
		nodes = {
			{
				n = G.UIT.O,
				config = { w = units, h = units, colour = G.C.BLUE, object = tag_sprite, focus_with_object = true },
			},
		},
	}
	tag_sprite:define_draw_steps({
		{ shader = "dissolve", shadow_height = 0.05 },
		{ shader = "dissolve" },
		mod.icon_path and mod.disabled and { shader = "dissolve", shadow_height = 0, tilt_shadow = 1 } or nil, --this is really gross, blame thunk
	})
	tag_sprite.float = true
	tag_sprite.states.hover.can = true
	tag_sprite.states.click.can = true
	tag_sprite.states.drag.can = false
	tag_sprite.states.collide.can = true

	tag_sprite.click = function(self)
		Glossary.history.save_external({
			["mods_button"] = true,
		})
		play_sound("button", 1, 0.3)
		G.ROOM.jiggle = G.ROOM.jiggle + 0.5
		G.FUNCS["openModUI_" .. mod.id](self)
	end
	tag_sprite.stop_hover = function(_self)
		_self.hovering = false
		Node.stop_hover(_self)
		_self.hover_tilt = 0
	end
	tag_sprite.update = function(self, dt)
		if not self.rescaled then
			if type(self.rescale) == "function" then
				self:rescale()
			end
			self.rescaled = true
		end
	end

	return tag_sprite_tab
end
function Glossary.UI.header_mod_additions_button(mod)
	if not mod then
		return
	end
	local old_active_mod_ui = G.ACTIVE_MOD_UI
	G.ACTIVE_MOD_UI = mod
	local has_additions = mod and buildAdditionsTab(mod)
	G.ACTIVE_MOD_UI = old_active_mod_ui

	return Glossary.UI.header_button({
		button = has_additions and "glossary_open_mod_additions" or "glossary_noop",
		colour = mod.badge_colour,
		minw = 1.5,
		text = mod.name .. (has_additions and (": " .. localize("b_additions")) or ""),
		shader = mod.badge_shader,
		ref_table = {
			mod = mod,
		},
		text_colour = mod.badge_text_colour,
		prepend_content = Glossary.UI.header_mod_icon(mod),
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
function Glossary.UI.header_glossary_config_button(disabled)
	return Glossary.UI.header_button({
		button = not disabled and "glossary_open_glossary_mod_config" or "glossary_noop",
		colour = disabled and G.C.UI.BACKGROUND_INACTIVE or G.C.BLUE,
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
		e.config.button = "glossary_noop"
	end
end

--

G.FUNCS.glossary_open_mod_additions = function(e)
	Glossary.history.save_external({
		["mods_button"] = true,
	})
	G.ACTIVE_MOD_UI = e.config.ref_table.mod
	SMODS.LAST_SELECTED_MOD_TAB = "additions"
	G.FUNCS["openModUI_" .. G.ACTIVE_MOD_UI.id](e)
end
G.FUNCS.glossary_open_vanilla_collection = function(e)
	Glossary.history.save_external({
		[G.STAGE == G.STAGES.RUN and "options" or "exit_overlay_menu"] = true,
	})
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
			func = "glossary_attach_uibox",
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
								Glossary.UI.header_glossary_config_button(input.context.target_type == "mod_config"),
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

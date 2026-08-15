if not PotatoPatchUtils then
	return
end

-- Custom type of glossary display
Glossary.entry_points.ppu_team_credits = function(target, source_type, source)
	Glossary.UI.prepare_overlay_menu()

	local context = Glossary.processing.new_context("ppu_team_credits", target, source_type, source)
	Glossary.specify_mod(target.mod_id)

	Glossary.ARGS.force_ignore_on_cards = true
	local content = {
		n = G.UIT.R,
		config = { align = "m", r = 0.1, padding = 0.05, colour = G.C.BLACK, minw = 8, minh = 9 },
		nodes = {
			{
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = {
					PotatoPatchUtils.CREDITS.create_team_credit_page(target),
				},
			},
		},
	}
	Glossary.ARGS.force_ignore_on_cards = nil

	Glossary.show_ui({
		context = context,
		content = content,
	})
end

local function create_member_info_popup_tooltip(dev, team)
	local info_nodes = {
		n = G.UIT.R,
		config = { align = "cm", colour = mix_colours(G.C.L_BLACK, { 0, 0, 0, 1 }, 0.6), r = 0.25, padding = 0.1 },
		nodes = {
			{ n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = {} },
		},
	}
	local is_info_nodes_empty = true
	local text = dev.loc and G.localization.descriptions.PotatoPatch[dev.loc].text_parsed or nil
	local loc_vars = dev.loc_vars and dev:loc_vars() or {}
	loc_vars.text_colour = loc_vars.text_colour or G.C.UI.TEXT_LIGHT
	loc_vars.font = loc_vars.font or SMODS.Fonts.fac_collection
	if text then
		if not text[1][1][1] then
			text = { text }
		end
		for _, box in ipairs(text) do
			is_info_nodes_empty = false
			local node = {
				n = G.UIT.R,
				config = { colour = G.C.L_BLACK, r = 0.1, padding = 0.15, align = "cm", shadow = true },
				nodes = {},
			}
			for _, v in ipairs(box) do
				table.insert(
					node.nodes,
					{ n = G.UIT.R, config = { align = "cm" }, nodes = SMODS.localize_box(v, loc_vars) }
				)
			end
			info_nodes.nodes[1].nodes[#info_nodes.nodes[1].nodes + 1] = {
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						config = { align = "cm", colour = G.C.WHITE, r = 0.1, padding = 0.025 },
						nodes = {
							node,
						},
					},
				},
			}
		end
	end
	return info_nodes, is_info_nodes_empty
end
local function create_member_info_popup(dev, team)
	local name = {}
	if dev.always_use_dynatext or dev.text_effect or dev.shaders or dev.colours then
		name = {
			n = G.UIT.O,
			config = {
				object = DynaText({
					string = dev.loc and localize({ type = "name_text", key = dev.loc, set = "PotatoPatch" })
						or dev.name
						or "ERROR",
					colours = dev.colours or { dev.colour or G.C.UI.BACKGROUND_WHITE },
					scale = 0.47,
					text_effect = dev.text_effect or nil,
					shaders = dev.shaders or nil,
					silent = true,
					shadow = false,
					y_offset = -0.6,
				}),
			},
		}
	else
		localize({
			type = "name",
			set = "PotatoPatch",
			key = dev.loc,
			nodes = name,
			scale = 0.8,
			maxw = 2,
			text_colour = dev.colour,
			stylize = true,
			no_shadow = true,
			no_pop_in = true,
			no_bump = true,
			no_silent = true,
			no_spacing = true,
		})
		name = name[1] and name[1][1]
			or { n = G.UIT.T, config = { scale = 0.47, colour = dev.colour, text = dev.name } }
	end

	local info_nodes, is_info_nodes_empty = create_member_info_popup_tooltip(dev, team)

	local team_name
	if team then
		local temp_team_name = localize({ type = "name_text", set = "PotatoPatch", key = team.loc })
		if temp_team_name == "ERROR" then
			temp_team_name = team.name
		end
		team_name = {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				{
					n = G.UIT.T,
					config = {
						text = temp_team_name,
						scale = 0.32,
						colour = team.colour,
					},
				},
			},
		}
	end

	info_nodes.nodes = {
		{
			n = G.UIT.R,
			config = { colour = G.C.L_BLACK, r = 0.1, align = "cm", emboss = 0.05, padding = 0.1 },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						name,
					},
				},
				team_name and {
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						team_name,
					},
				} or nil,
			},
		},
		not is_info_nodes_empty and {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = info_nodes.nodes,
		} or nil,
	}

	return info_nodes
end

local function create_member_card(dev, team)
	local partner = dev.joint_credits and dev.fac_partner and PotatoPatchUtils.Developers[dev.fac_partner]

	local dev_card =
		Card(0, 0, (dev.joint_credits and 2 or 1) * G.CARD_W / 1.25, G.CARD_H / 1.25, nil, G.P_CENTERS.c_base)
	dev_card.children.center:remove()
	dev_card.children.center = SMODS.create_sprite(
		dev_card.T.x,
		dev_card.T.y,
		dev_card.T.w,
		dev_card.T.h,
		dev.atlas or "Joker",
		dev.pos or { x = 0, y = 0 }
	)
	dev_card.children.center.states.hover = dev_card.states.hover
	dev_card.children.center.states.click = dev_card.states.click
	dev_card.children.center.states.drag = dev_card.states.drag
	dev_card.children.center.states.collide.can = true
	dev_card.children.center:set_role({ major = dev_card, role_type = "Glued", draw_major = dev_card })

	-- Check for dev_card soul
	if dev.soul_pos then
		dev_card.children.ppu_floating_sprite = SMODS.create_sprite(
			dev_card.T.x,
			dev_card.T.y,
			dev_card.T.w,
			dev_card.T.h,
			dev.atlas or "Joker",
			dev.soul_pos
		)
		dev_card.children.ppu_floating_sprite.role.draw_major = dev_card
		dev_card.children.ppu_floating_sprite.states.hover.can = false
		dev_card.children.ppu_floating_sprite.states.click.can = false
	end

	dev_card.ppu_member = dev
	dev_card.ppu_team = team
	dev_card.glossary_func = function()
		if team then
			Glossary.show_info("ppu_team_credits", team, "card", dev_card)
			return true
		end
	end

	dev_card.click = function(self)
		if not dev.click and not (partner and partner.click) then
			return Card.click(dev_card)
		end
		if dev.click then
			dev.click(dev_card)
		end
		if partner and partner.click then
			partner.click(dev_card)
		end
	end

	-- Create tooltip
	dev_card.hover = function(self)
		self:juice_up(0.05, 0.03)
		play_sound("paper1", math.random() * 0.2 + 0.9, 0.35)
		dev_card.config.h_popup = create_member_info_popup(dev, team)
		dev_card.config.h_popup_dir = "cl"
		dev_card.config.h_popup_config = dev_card:align_h_popup("cl")
		if partner then
			dev_card.config.h_popup_2 = create_member_info_popup(partner, team)
			dev_card.config.h_popup_2_dir = "cr"
			dev_card.config.h_popup_2_config = dev_card:align_h_popup("cr")
		end
		Moveable.hover(self)
	end

	local old_align = dev_card.align_h_popup
	function dev_card:align_h_popup(dir, ...)
		local r = old_align(self, ...)
		if not dir or dir == "cl" then
			r.type = "cl"
			r.x = -0.05
			r.y = 0
		elseif dir == "cr" then
			r.type = "cr"
			r.x = 0.05
			r.y = 0
		end
		return r
	end
	return dev_card
end
local function create_not_loaded_member_card(member_key)
	local card = Card(G.ROOM.T.x, G.ROOM.T.y, G.CARD_W / 1.25, G.CARD_H / 1.25, nil, G.P_CENTERS.j_invisible)

	card.glossary_func = function()
		return false
	end

	-- Create tooltip
	card.hover = function(self)
		local name = { n = G.UIT.T, config = { scale = 0.47, colour = G.C.UI.TEXT_LIGHT, text = member_key } }

		local info_nodes = {
			n = G.UIT.R,
			config = { align = "cm", colour = mix_colours(G.C.L_BLACK, { 0, 0, 0, 1 }, 0.6), r = 0.25, padding = 0.1 },
			nodes = {
				{ n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = {} },
			},
		}

		info_nodes.nodes = {
			{
				n = G.UIT.R,
				config = { colour = G.C.L_BLACK, r = 0.1, align = "cm", emboss = 0.05, padding = 0.1 },
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = {
							name,
						},
					},
				},
			},
		}

		self:juice_up(0.05, 0.03)
		play_sound("paper1", math.random() * 0.2 + 0.9, 0.35)
		card.config.h_popup = info_nodes
		card.config.h_popup_config = self:align_h_popup()
		Moveable.hover(self)
	end

	local old_align = card.align_h_popup
	function card:align_h_popup(...)
		local r = old_align(self, ...)
		r.type = "cl"
		r.x = -0.05
		r.y = 0
		return r
	end
	return card
end
local function create_team_name(team)
	local team_name = {}
	localize({
		type = "name",
		set = "PotatoPatch",
		key = team.loc,
		nodes = team_name,
		maxw = 5.5,
		scale = 0.8,
		text_colour = G.C.UI.TEXT_LIGHT,
		stylize = true,
		no_shadow = false,
		no_pop_in = true,
		no_bump = true,
		no_silent = true,
		no_spacing = true,
	})
	team_name = team_name[1] and team_name[1][1]
		or {
			n = G.UIT.C,
			config = {},
			nodes = {
				{
					n = G.UIT.T,
					config = { scale = 0.65 / 1.3 * 0.8, colour = G.C.UI.TEXT_LIGHT, text = team.name, shadow = true },
				},
			},
		}
	team_name.config.minw = 5.5
	team_name.config.align = "cm"
	return {
		n = G.UIT.R,
		config = {
			padding = 0.1,
			r = 0.25,
			hover = true,
			button = "glossary_open_ppu_team_credits",
			ref_table = team,
			emboss = 0.075,
			colour = team.colour,
			align = "cm",
		},
		nodes = {
			team_name,
		},
	}
end

Glossary.InfoSection({
	key = "ppu_credits",
	order = 10000,
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
		local cards = {
			coder = CardArea(0, 0, 3.45, G.CARD_H / 1.25, {
				highlight_limit = 0,
				type = "title_2",
			}),
			artist = CardArea(0, 0, 3.45, G.CARD_H / 1.25, {
				highlight_limit = 0,
				type = "title_2",
			}),
		}
		local team_names_render = {}
		for _, node in ipairs(nodes) do
			if node.type == "team" then
				local team = PotatoPatchUtils.Teams[node.key]
				table.insert(team_names_render, {
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = { create_team_name(team) },
				})
			else
				local member = PotatoPatchUtils.Developers[node.key]
				if member then
					local mod = SMODS.Mods[member.mod_id]
					local team = member.team and PotatoPatchUtils.Teams[mod.prefix .. "_" .. member.team]
					local card = create_member_card(member, team)
					cards[node.type]:emplace(card)
				else
					local card = create_not_loaded_member_card(node.raw_key)
					cards[node.type]:emplace(card)
				end
			end
		end

		local card_areas_render = {}
		for key, area in pairs(cards) do
			if #area.cards == 0 then
				area:remove()
			else
				area.config.spread = true -- small little thing which positions cards in cooler way
				if #card_areas_render > 0 then
					table.insert(card_areas_render, { n = G.UIT.C, config = { minw = 0.1 } })
				end
				table.insert(card_areas_render, {
					n = G.UIT.C,
					config = {
						align = "cm",
					},
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = localize({
											type = "name_text",
											set = "Glossary_InfoSection",
											key = "ppu_credits_area_" .. key,
										}),
										scale = 0.32,
										colour = G.C.UI.TEXT_LIGHT,
									},
								},
							},
						},
						{ n = G.UIT.R, config = { minh = 0.1 } },
						{
							n = G.UIT.R,
							config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25 },
							nodes = {
								{
									n = G.UIT.O,
									config = {
										object = area,
									},
								},
							},
						},
					},
				})
			end
		end

		local result_teams = #team_names_render > 0
				and { n = G.UIT.R, config = { align = "cm", padding = 0.1 }, nodes = team_names_render }
			or nil
		local result_card_areas = #card_areas_render > 0
				and { n = G.UIT.R, config = { align = "cm" }, nodes = card_areas_render }
			or nil

		return Glossary.UI.basic_section(self, nodes, {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				result_teams,
				result_teams and result_card_areas and { n = G.UIT.R, config = { minh = 0.2 } } or nil,
				result_card_areas,
			},
		})
	end,
	insert = function(self, nodes, result)
		nodes[#nodes + 1] = result
	end,
})
Glossary.InfoQueueProcessor({
	key = "ppu_credits",
	order = 1000,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local center = context.target_center
		if center then
			local credits_data = {
				coder = center.ppu_coder,
				artist = center.ppu_artist,
				team = center.ppu_team,
			}
			for credit_type, credits_list in pairs(credits_data) do
				for _, item in ipairs(credits_list) do
					Glossary.insert("ppu_credits", function()
						return {
							type = credit_type,
							key = center.mod.prefix .. "_" .. item,
							raw_key = item,
						}
					end)
				end
			end
		end
	end,

	conditions = { before = true },
})

function G.FUNCS.glossary_open_ppu_team_credits(e)
	Glossary.show_info("ppu_team_credits", e.config.ref_table, "ui_button", e)
end

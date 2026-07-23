if not PotatoPatchUtils then
	return
end

local function create_member_card(member, team)
	local card = Card(G.ROOM.T.x, G.ROOM.T.y, G.CARD_W / 1.25, G.CARD_H / 1.25, nil, G.P_CENTERS.c_base)
	card.children.center:remove()
	card.children.center = SMODS.create_sprite(
		card.T.x,
		card.T.y,
		card.T.w,
		card.T.h,
		member.atlas or "Joker",
		member.pos or { x = 0, y = 0 }
	)
	card.children.center.states.hover = card.states.hover
	card.children.center.states.click = card.states.click
	card.children.center.states.drag = card.states.drag
	card.children.center.states.collide.can = true
	card.children.center:set_role({ major = card, role_type = "Glued", draw_major = card })

	-- Check for card soul
	if member.soul_pos then
		card.children.ppu_floating_sprite =
			SMODS.create_sprite(card.T.x, card.T.y, card.T.w, card.T.h, member.atlas or "Joker", member.soul_pos)
		card.children.ppu_floating_sprite.role.draw_major = card
		card.children.ppu_floating_sprite.states.hover.can = false
		card.children.ppu_floating_sprite.states.click.can = false
	end

	card.ppu_member = member
	card.ppu_team = team

	-- Create tooltip
	card.hover = function(self)
		local name = {}
		if member.always_use_dynatext or member.text_effect or member.shaders or member.colours then
			name = {
				n = G.UIT.O,
				config = {
					object = DynaText({
						string = member.loc and localize({ type = "name_text", key = member.loc, set = "PotatoPatch" })
							or dev.name
							or "ERROR",
						colours = member.colours or { member.colour or G.C.UI.BACKGROUND_WHITE },
						scale = 0.47,
						text_effect = member.text_effect or nil,
						shaders = member.shaders or nil,
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
				key = member.loc,
				nodes = name,
				scale = 0.8,
				maxw = 2,
				text_colour = member.colour,
				stylize = true,
				no_shadow = true,
				no_pop_in = true,
				no_bump = true,
				no_silent = true,
				no_spacing = true,
			})
			name = name[1] and name[1][1]
				or { n = G.UIT.T, config = { scale = 0.47, colour = member.colour, text = member.name } }
		end

		local info_nodes = {
			n = G.UIT.R,
			config = { align = "cm", colour = mix_colours(G.C.L_BLACK, { 0, 0, 0, 1 }, 0.6), r = 0.25, padding = 0.1 },
			nodes = {
				{ n = G.UIT.C, config = { align = "cm", padding = 0.1 }, nodes = {} },
			},
		}

		local text = member.loc and G.localization.descriptions.PotatoPatch[member.loc].text_parsed or nil
		if text then
			if not text[1][1][1] then
				text = { text }
			end
			for _, box in ipairs(text) do
				local node = {
					n = G.UIT.R,
					config = { colour = G.C.L_BLACK, r = 0.1, padding = 0.15, align = "cm", shadow = true },
					nodes = {},
				}
				for _, v in ipairs(box) do
					table.insert(node.nodes, {
						n = G.UIT.R,
						config = { align = "cm" },
						nodes = SMODS.localize_box(v, { text_colour = G.C.UI.TEXT_LIGHT }),
					})
				end
				info_nodes.nodes[1].nodes[#info_nodes.nodes[1].nodes + 1] = {
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "cm", colour = G.C.WHITE, r = 0.1, padding = 0.025 },
							nodes = { node },
						},
					},
				}
			end
		end

		local team_name
		if team then
			team_name = {
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = localize({ type = "name_text", set = "PotatoPatch", key = team.loc }),
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
			#info_nodes.nodes > 0 and {
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = info_nodes.nodes,
			} or nil,
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
			button = "exit_overlay_menu",
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
	order = 1000,
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
					local team = PotatoPatchUtils.Teams[mod.prefix .. "_" .. member.team]
					local card = create_member_card(member, team)
					card.glossary_ignore = true
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

		return Glossary.UI.basic_section(self, {
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
	order = 100,
	prefix_config = {
		key = false,
	},
	func = function(self, context)
		local center
		if context.target_type == "card" and context.target.facing ~= "back" then
			center = context.target.config.center
		else
			center = context.target
		end
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
						}
					end)
				end
			end
		end
	end,

	conditions = { before = true },
})

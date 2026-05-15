Glossary = {}
Glossary.current_mod = SMODS.current_mod

Glossary.sets_blacklist = {
	["DescriptionDummy"] = true,
}

local old_r_press = Controller.queue_R_cursor_press
function Controller:queue_R_cursor_press(...)
	old_r_press(self, ...)
	local hovered_target = self.hovering.target
	if hovered_target then
		if hovered_target.is and hovered_target:is(Card) then
			hovered_target:stop_hover()
			Glossary.show_card_info(hovered_target)
		elseif hovered_target.config and hovered_target.config.tag then
			hovered_target:stop_hover()
			Glossary.show_tag_info(hovered_target.config.tag)
		elseif
			hovered_target.config
			and hovered_target.config.ref_table
			and hovered_target.config.ref_table.config
			and hovered_target.config.ref_table.config.tag
		then
			hovered_target:stop_hover()
			Glossary.show_tag_info(hovered_target.config.ref_table.config.tag)
		end
	end
end

function Glossary.prepare_info_queue(AUT, info_queue)
	info_queue = info_queue or {}
	local special_info_queue = {}

	local i = 1
	while i <= #info_queue do
		local item = info_queue[i]
		if
			item.key
			and not Glossary.sets_blacklist[item.set]
			and (
				(item.set == "Other" and SMODS.Stickers[item.key])
				or G.P_CENTERS[item.key]
				or G.P_SEALS[item.key]
				or G.P_TAGS[item.key]
			)
		then
			table.remove(info_queue, i)
			table.insert(special_info_queue, item)
		else
			i = i + 1
		end
	end

	AUT.glossary_info_queue = special_info_queue
	AUT.glossary_real_info_queue_empty = #info_queue == 0
end

-- TODO::
-- Visual
-- Decks
-- Stakes
-- Blinds

function Glossary.display_ability_table(target_render, AUT, popup)
	local content = popup.nodes[1].nodes
	popup.nodes[1].nodes = {}
	local special_info_queue = AUT.glossary_info_queue
	local info_queue = popup.nodes[1].config.ref_table
	popup.nodes[1].config.ref_table = nil

	UIBox({
		definition = popup,
		config = {},
	}):remove()

	local display_area = CardArea(0, 0, G.CARD_W * 3, G.CARD_H, {
		type = "title_2",
		highlight_limit = 0,
		collection = true,
	})
	local skip_tags = {}

	for _, item in pairs(special_info_queue) do
		if item.set == "Other" and SMODS.Stickers[item.key] then
			local display_card = SMODS.create_card({ key = "c_base", front = false, area = display_area })
			SMODS.Stickers[item.key]:apply(display_card, true)
			-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
			display_area:emplace(display_card)
		elseif G.P_CENTERS[item.key] then
			if item.set == "Edition" then
				local display_card =
					SMODS.create_card({ key = item.key, front = false, edition = item.key, area = display_area })
				-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
				display_area:emplace(display_card)
			else
				local display_card = SMODS.create_card({ key = item.key, front = false, area = display_area })
				-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
				display_area:emplace(display_card)
			end
		elseif G.P_SEALS[item.key] then
			local display_card =
				SMODS.create_card({ key = "c_base", front = false, seal = item.key, area = display_area })
			-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
			display_area:emplace(display_card)
		elseif G.P_TAGS[item.key] then
			local tag_ui = Tag(item.key, true):generate_UI()
			table.insert(skip_tags, {
				n = G.UIT.C,
				config = { align = "cm" },
				nodes = {
					tag_ui,
				},
			})
		end
	end

	if #display_area.cards == 0 then
		display_area:remove()
		display_area = nil
	end
	if #skip_tags == 0 then
		skip_tags = nil
	end
	if #info_queue == 0 or AUT.glossary_real_info_queue_empty then
		info_queue = nil
	end

	local should_display_right = display_area or skip_tags or info_queue

	local max_content_w, max_content_h = 7, 7

	local content_overflow = SMODS.UIScrollBox({
		content = {
			definition = {
				n = G.UIT.ROOT,
				config = { colour = G.C.CLEAR, align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						config = { padding = 0.1, align = "cm" },
						nodes = content,
					},
				},
			},
			config = {},
		},
		overflow = {
			node_config = {
				maxw = max_content_w,
				maxh = max_content_h,
			},
		},
		progress = {
			x = 0,
			y = 0,
		},
	})

	content_overflow.content.states.drag.can = true
	function content_overflow.content:can_drag()
		return true
	end
	function content_overflow.content:drag()
		self.ARGS.drag_cursor_trans = self.ARGS.drag_cursor_trans or {}
		self.ARGS.drag_translation = self.ARGS.drag_translation or {}
		local _p = self.ARGS.drag_cursor_trans
		local _t = self.ARGS.drag_translation
		_p.x = G.CONTROLLER.cursor_position.x / (G.TILESCALE * G.TILESIZE)
		_p.y = G.CONTROLLER.cursor_position.y / (G.TILESCALE * G.TILESIZE)

		_t.x, _t.y = -self.container.T.w / 2, -self.container.T.h / 2
		point_translate(_p, _t)

		point_rotate(_p, self.container.T.r)

		_t.x, _t.y = self.container.T.w / 2 - self.container.T.x, self.container.T.h / 2 - self.container.T.y
		point_translate(_p, _t)

		point_translate(_p, {
			x = -content_overflow.T.x,
			y = -content_overflow.T.y,
		})

		local offset = self.click_offset
		offset.scroll_offset_x = offset.scroll_offset_x or content_overflow.scroll_offset.x
		offset.scroll_offset_y = offset.scroll_offset_y or content_overflow.scroll_offset.y

		content_overflow.scroll_offset.x = offset.scroll_offset_x - (_p.x - offset.x)
		content_overflow.scroll_offset.y = offset.scroll_offset_y - (_p.y - offset.y)

		local max_x, max_y = content_overflow:get_scroll_distance()
		content_overflow.scroll_offset.x = math.max(0, math.min(max_x, content_overflow.scroll_offset.x))
		content_overflow.scroll_offset.y = math.max(0, math.min(max_y, content_overflow.scroll_offset.y))

		content_overflow:sync_scroll_progress()
	end

	local content_w = content_overflow.content.UIRoot.T.w
	local content_h = content_overflow.content.UIRoot.T.h

	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			contents = {
				{
					n = G.UIT.C,
					config = {
						padding = 0.1,
						align = "cm",
					},
					nodes = {
						target_render,
						{
							n = G.UIT.R,
							config = { align = "cm" },
							nodes = {
								{
									n = G.UIT.O,
									config = {
										object = content_overflow,
									},
								},
								content_h > max_content_h and { n = G.UIT.C, config = { minw = 0.1 } } or nil,
								content_h > max_content_h and SMODS.GUI.scrollbar({
									ui_type = G.UIT.C,
									scroll_collision_obj = content_overflow,
									w = 0.25,
									h = max_content_h,
									bg_colour = { 0, 0, 0, 0.15 },
									knob_h = 0.25,
									ref_table = content_overflow.scroll_progress,
									ref_value = "y",
								}) or nil,
							},
						},
						content_w > max_content_w and SMODS.GUI.scrollbar({
							w = max_content_w,
							h = 0.25,
							knob_w = 0.25,
							ui_type = G.UIT.R,
							ref_table = content_overflow.scroll_progress,
							ref_value = "x",
							horizontal = true,
							bg_colour = { 0, 0, 0, 0.15 },
						}) or nil,
					},
				},
				should_display_right and {
					n = G.UIT.C,
					config = { align = "cm" },
					nodes = {
						display_area and {
							n = G.UIT.R,
							nodes = {
								{
									n = G.UIT.R,
									config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, padding = 0.1 },
									nodes = {
										{
											n = G.UIT.O,
											config = {
												object = display_area,
											},
										},
									},
								},
							},
						} or nil,
						skip_tags and {
							n = G.UIT.R,
							nodes = {
								{
									n = G.UIT.R,
									config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, padding = 0.1, align = "cm" },
									nodes = {
										{
											n = G.UIT.R,
											nodes = skip_tags,
										},
									},
								},
							},
						} or nil,
						info_queue and {
							n = G.UIT.R,
							config = { align = "cm", padding = 0.1 },
							nodes = info_queue,
						} or nil,
					},
				} or nil,
			},
		}),
	})
	G.OVERLAY_MENU.glossary_display = true
end

function Glossary.show_tag_info(tag)
	local tag_ui, tag_sprite = tag:generate_UI(1.2)
	Glossary.flitered_info_queue_request = true
	tag:get_uibox_table(tag_sprite)
	Glossary.flitered_info_queue_request = nil
	local popup = G.UIDEF.card_h_popup(tag_sprite)

	tag_sprite.hover = Sprite.hover

	local main_render = {
		n = G.UIT.R,
		config = { r = 0.25, padding = 0.1, colour = { 0, 0, 0, 0.1 }, align = "cm" },
		nodes = {
			tag_ui,
		},
	}

	return Glossary.display_ability_table(main_render, tag_sprite.ability_UIBox_table, popup)
end

function Glossary.show_card_info(card)
	Glossary.flitered_info_queue_request = true
	card.ability_UIBox_table = card:generate_UIBox_ability_table()
	Glossary.flitered_info_queue_request = nil
	local popup = G.UIDEF.card_h_popup(card)

	local main_card_area = CardArea(0, 0, G.CARD_W, G.CARD_H, {
		type = "title",
		highlight_limit = 0,
		collection = true,
	})
	local new_card = copy_card(card, nil, 1, nil, nil)
	main_card_area:emplace(new_card)
	new_card.no_ui = true

	local main_render = {
		n = G.UIT.R,
		config = { r = 0.25, padding = 0.1, colour = { 0, 0, 0, 0.1 }, align = "cm" },
		nodes = {
			{
				n = G.UIT.O,
				config = { object = main_card_area },
			},
		},
	}

	return Glossary.display_ability_table(main_render, card.ability_UIBox_table, popup)

	-- local special_info_queue = card.ability_UIBox_table.glossary_info_queue

	-- local content = popup.nodes[1].nodes
	-- popup.nodes[1].nodes = {}
	-- local info_queue = popup.nodes[1].config.ref_table
	-- popup.nodes[1].config.ref_table = nil

	-- UIBox({
	-- 	definition = popup,
	-- 	config = {},
	-- }):remove()

	-- local display_area = CardArea(0, 0, G.CARD_W * 3, G.CARD_H, {
	-- 	type = "title_2",
	-- 	highlight_limit = 0,
	-- 	collection = true,
	-- })
	-- local skip_tags = {}

	-- for _, item in ipairs(special_info_queue) do
	-- 	if item.set == "Other" and SMODS.Stickers[item.key] then
	-- 		local display_card = SMODS.create_card({ key = "c_base", front = false, area = display_area })
	-- 		SMODS.Stickers[item.key]:apply(display_card, true)
	-- 		-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
	-- 		display_area:emplace(display_card)
	-- 	elseif G.P_CENTERS[item.key] then
	-- 		if item.set == "Edition" then
	-- 			local display_card =
	-- 				SMODS.create_card({ key = item.key, front = false, edition = item.key, area = display_area })
	-- 			-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
	-- 			display_area:emplace(display_card)
	-- 		else
	-- 			local display_card = SMODS.create_card({ key = item.key, front = false, area = display_area })
	-- 			-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
	-- 			display_area:emplace(display_card)
	-- 		end
	-- 	elseif G.P_SEALS[item.key] then
	-- 		local display_card =
	-- 			SMODS.create_card({ key = "c_base", front = false, seal = item.key, area = display_area })
	-- 		-- display_card.ability = SMODS.merge_defaults(display_card.ability, item.config or {})
	-- 		display_area:emplace(display_card)
	-- 	elseif G.P_TAGS[item.key] then
	-- 		local tag_ui = Tag(item.key, true):generate_UI()
	-- 		table.insert(skip_tags, {
	-- 			n = G.UIT.C,
	-- 			config = { align = "cm" },
	-- 			nodes = {
	-- 				tag_ui,
	-- 			},
	-- 		})
	-- 	end
	-- end

	-- if #display_area.cards == 0 then
	-- 	display_area:remove()
	-- 	display_area = nil
	-- end
	-- if #skip_tags == 0 then
	-- 	skip_tags = nil
	-- end
	-- if #info_queue == 0 then
	-- 	info_queue = nil
	-- end

	-- local should_display_right = display_area or skip_tags or info_queue

	-- G.FUNCS.overlay_menu({
	-- 	definition = create_UIBox_generic_options({
	-- 		contents = {
	-- 			{
	-- 				n = G.UIT.C,
	-- 				config = {
	-- 					padding = 0.1,
	-- 					align = "cm",
	-- 				},
	-- 				nodes = {
	-- 					{
	-- 						n = G.UIT.R,
	-- 						config = { align = "cm", padding = 0.1, colour = { 0, 0, 0, 0.1 }, r = 0.25 },
	-- 						nodes = {
	-- 							{
	-- 								n = G.UIT.O,
	-- 								config = {
	-- 									object = main_card_area,
	-- 								},
	-- 							},
	-- 						},
	-- 					},
	-- 					{
	-- 						n = G.UIT.R,
	-- 						config = { align = "cm", padding = 0.1 },
	-- 						nodes = content,
	-- 					},
	-- 				},
	-- 			},
	-- 			should_display_right and {
	-- 				n = G.UIT.C,
	-- 				config = { align = "cm" },
	-- 				nodes = {
	-- 					display_area and {
	-- 						n = G.UIT.R,
	-- 						nodes = {
	-- 							{
	-- 								n = G.UIT.R,
	-- 								config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, padding = 0.1 },
	-- 								nodes = {
	-- 									{
	-- 										n = G.UIT.O,
	-- 										config = {
	-- 											object = display_area,
	-- 										},
	-- 									},
	-- 								},
	-- 							},
	-- 						},
	-- 					},
	-- 					skip_tags and {
	-- 						n = G.UIT.R,
	-- 						nodes = {
	-- 							{
	-- 								n = G.UIT.R,
	-- 								config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, padding = 0.1, align = "cm" },
	-- 								nodes = {
	-- 									{
	-- 										n = G.UIT.R,
	-- 										nodes = skip_tags,
	-- 									},
	-- 								},
	-- 							},
	-- 						},
	-- 					},
	-- 					info_queue and {
	-- 						n = G.UIT.R,
	-- 						config = { align = "cm", padding = 0.1 },
	-- 						nodes = info_queue,
	-- 					},
	-- 				},
	-- 			},
	-- 		},
	-- 	}),
	-- })
end

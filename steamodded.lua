Glossary = {}
Glossary.current_mod = SMODS.current_mod

Glossary._next_id = 1

Glossary.sets_blacklist = {
	["DescriptionDummy"] = true,
}

--

Glossary.RenderSections = {}
Glossary.RenderSectionsPool = {}
Glossary.RenderSection = SMODS.GameObject:extend({
	set = "GlossaryRenderSection",
	obj_table = Glossary.RenderSections,
	obj_buffer = {},
	required_keys = {
		"key",
		"order",
	},
	pre_inject_class = function()
		EMPTY(Glossary.RenderSectionsPool)
	end,
	inject = function(self)
		table.insert(Glossary.RenderSectionsPool, self)
	end,
	post_inject_class = function(self)
		table.sort(Glossary.RenderSectionsPool, function(a, b)
			return a.order < b.order
		end)
	end,
	process_loc_text = function() end,

	is_empty = function(self, c)
		return true
	end,

	create = function(self) end,
	destroy = function(self, c) end,
	insert = function(self, c) end,
	render = function(self, c) end,
})

Glossary.InfoQueueFilters = {}
Glossary.InfoQueueFiltersPool = {}
Glossary.InfoQueueFilter = SMODS.GameObject:extend({
	set = "GlossaryInfoQueueFilter",
	obj_table = Glossary.InfoQueueFilters,
	obj_buffer = {},
	required_keys = {
		"key",
		"order",
	},
	pre_inject_class = function()
		EMPTY(Glossary.InfoQueueFiltersPool)
	end,
	inject = function(self)
		table.insert(Glossary.InfoQueueFiltersPool, self)
	end,
	post_inject_class = function(self)
		table.sort(Glossary.InfoQueueFiltersPool, function(a, b)
			return a.order < b.order
		end)
	end,
	process_loc_text = function() end,

	func = function(self, item, AUT, info_queue) end,
})

--

function Glossary.process_info_queue(AUT, info_queue)
	info_queue = info_queue or {}

	local i = 1
	while i <= #info_queue do
		local filtered = false
		local item = info_queue[i]

		if item then
			for _, filter in ipairs(Glossary.InfoQueueFiltersPool) do
				local result = filter:func(item, AUT, info_queue)
				if result then
					table.remove(info_queue, i)
					filtered = true
					break
				end
			end
		end

		if not filtered then
			i = i + 1
		end
	end

	AUT.glossary_real_info_queue_empty = #info_queue == 0
end

--

function Glossary.insert(key, func) end
function Glossary.create_containers()
	local containers = {}
	function Glossary.insert(key, func)
		if not containers[key] then
			containers[key] = Glossary.RenderSections[key]:create()
		end
		local result = func(containers[key])
		if result then
			Glossary.RenderSections[key]:insert(containers[key], result)
			return true
		end
		return false
	end
	return containers
end

Glossary.RenderSection({
	key = "center",
	order = 0,
	prefix_config = {
		key = false,
	},
	create = function(self)
		return CardArea(0, 0, 7, G.CARD_H, {
			type = "title_2",
			highlight_limit = 0,
			collection = true,
		})
	end,
	is_empty = function(self, area)
		return #area.cards == 0
	end,
	destroy = function(self, area)
		area:remove()
	end,
	render = function(self, area)
		return {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
			nodes = {
				{
					n = G.UIT.O,
					config = {
						object = area,
					},
				},
			},
		}
	end,
	insert = function(self, area, result)
		area:emplace(result)
	end,
})
Glossary.RenderSection({
	key = "skip_tag",
	order = 1,
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
		return {
			n = G.UIT.R,
			config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, padding = 0.1, align = "cm", minw = 7 },
			nodes = {
				{
					n = G.UIT.R,
					nodes = nodes,
				},
			},
		}
	end,
	insert = function(self, nodes, result)
		table.insert(nodes, {
			n = G.UIT.C,
			config = { align = "cm" },
			nodes = {
				result,
			},
		})
	end,
})

Glossary.InfoQueueFilter({
	key = "sticker",
	order = 1,
	prefix_config = {
		key = false,
	},
	func = function(self, item, AUT, info_queue)
		if item.set == "Other" and SMODS.Stickers[item.key] then
			return Glossary.insert("center", function(area)
				local card = SMODS.create_card({ key = "c_base", front = false, area = area })
				SMODS.Stickers[item.key]:apply(card, true)
				return card
			end)
		end
	end,
})
Glossary.InfoQueueFilter({
	key = "seal",
	order = 2,
	prefix_config = {
		key = false,
	},
	func = function(self, item, AUT, info_queue)
		if item.set == "Seal" and G.P_SEALS[item.key] then
			return Glossary.insert("center", function(area)
				local card = SMODS.create_card({ key = "c_base", front = false, seal = item.key, area = area })
				return card
			end)
		end
	end,
})
Glossary.InfoQueueFilter({
	key = "skip_tag",
	order = 3,
	prefix_config = {
		key = false,
	},
	func = function(self, item, AUT, info_queue)
		if G.P_TAGS[item.key] then
			return Glossary.insert("skip_tag", function(nodes)
				local tag_ui = Tag(item.key, true):generate_UI()
				return tag_ui
			end)
		end
	end,
})
Glossary.InfoQueueFilter({
	key = "edition",
	order = 4,
	prefix_config = {
		key = false,
	},
	func = function(self, item, AUT, info_queue)
		if item.set == "Edition" and G.P_CENTERS[item.key] then
			return Glossary.insert("center", function(area)
				local card = SMODS.create_card({ key = item.key, front = false, edition = item.key, area = area })
				return card
			end)
		end
	end,
})
Glossary.InfoQueueFilter({
	key = "center",
	order = 1000,
	prefix_config = {
		key = false,
	},
	func = function(self, item, AUT, info_queue)
		if G.P_CENTERS[item.key] then
			return Glossary.insert("center", function(area)
				local card = SMODS.create_card({ key = "c_base", front = false, area = area })
				local success = pcall(function()
					card:set_ability(item.key, false, false)
				end)
				if success then
					return card
				else
					card:remove()
				end
			end)
		end
	end,
})

function Glossary.can_move_history(dx)
	local history = type(G.OVERLAY_MENU) == "table" and G.OVERLAY_MENU.glossary_history
	return history and history[history.current_index + dx] ~= nil
end
function Glossary.move_history(dx)
	if not Glossary.can_move_history(dx) then
		return
	end
	local history = G.OVERLAY_MENU.glossary_history
	history.current_index = history.current_index + dx
	local entry = history[history.current_index]
	Glossary.keep_history = true
	if entry.type == "tag" then
		Glossary.show_tag_info(entry.item)
	elseif entry.type == "card" then
		Glossary.show_card_info(entry.item)
	end
	Glossary.keep_history = nil
end
function Glossary.get_history()
	if not G.OVERLAY_MENU or not G.OVERLAY_MENU.glossary_history then
		return {
			current_index = 0,
		}
	end
	return G.OVERLAY_MENU.glossary_history
end
function Glossary.add_to_history(type, item)
	if Glossary.keep_history then
		return
	end
	local history = Glossary.get_history()
	for i = history.current_index + 1, #history do
		history[i] = nil
	end
	table.insert(history, {
		type = type,
		item = item,
	})
	history.current_index = #history
end

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

-- TODO::
-- Visual
-- Decks
-- Stakes
-- Blinds

function Glossary.display_ability_table(input)
	local target_render = input.main
	local AUT = input.AUT
	local popup = input.popup
	local containers = input.containers

	local content = popup.nodes[1].nodes
	popup.nodes[1].nodes = {}
	local info_queue = popup.nodes[1].config.ref_table
	popup.nodes[1].config.ref_table = nil

	UIBox({
		definition = popup,
		config = {},
	}):remove()

	local rows = {}

	for k, container in ipairs(Glossary.RenderSectionsPool) do
		local items = containers[container.key]
		if items then
			if not container:is_empty(items) then
				table.insert(rows, {
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						container:render(items),
					},
				})
			else
				container:destroy(items)
			end
		end
	end

	if not AUT.glossary_real_info_queue_empty then
		table.insert(rows, {
			n = G.UIT.R,
			config = { align = "cm", padding = 0.1 },
			nodes = info_queue,
		})
	end

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

	local left_content = {
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
	}
	local right_content = #rows > 0 and {
		n = G.UIT.C,
		config = { align = "cm" },
		nodes = rows,
	} or nil

	local head = {
		n = G.UIT.R,
		config = { colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1, minw = 14 },
		nodes = {
			{
				n = G.UIT.C,
				config = {
					align = "cm",
					colour = G.C.CHIPS,
					padding = 0.1,
					shadow = true,
					r = 0.25,
					func = "glossary_can_move_history",
					button = "glossary_move_history",
					hover = true,
					ref_table = {
						dx = -1,
					},
					minw = 0.75,
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = "←",
							font = G.FONTS[2],
							scale = 0.3,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
			{
				n = G.UIT.C,
				config = {
					align = "cm",
					colour = G.C.CHIPS,
					padding = 0.1,
					shadow = true,
					r = 0.25,
					func = "glossary_can_move_history",
					button = "glossary_move_history",
					hover = true,
					ref_table = {
						dx = 1,
					},
					minw = 0.75,
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = "→",
							font = G.FONTS[2],
							scale = 0.3,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
			{
				n = G.UIT.C,
				config = {
					align = "cm",
					colour = G.C.MULT,
					padding = 0.1,
					shadow = true,
					r = 0.25,
					button = "your_collection",
					minw = 1.5,
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = "Collection",
							scale = 0.3,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
		},
	}

	local history = Glossary.get_history()
	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
			contents = {
				head,
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
	G.OVERLAY_MENU.glossary_display = true
	G.OVERLAY_MENU.glossary_history = history
	Glossary.add_to_history(input.type, input.item)
end

function Glossary.show_tag_info(tag)
	local containers = Glossary.create_containers()

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

	Glossary.display_ability_table({
		type = "tag",
		item = tag,
		main = main_render,
		AUT = tag_sprite.ability_UIBox_table,
		popup = popup,
		containers = containers,
	})
end

function Glossary.show_card_info(card)
	local containers = Glossary.create_containers()

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

	Glossary.display_ability_table({
		type = "card",
		item = new_card,
		main = main_render,
		AUT = card.ability_UIBox_table,
		popup = popup,
		containers = containers,
	})
end

--

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

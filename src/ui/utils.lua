function Glossary.UI.init_draggable_scrollbox(scrollbox)
	scrollbox.content.states.drag.can = true
	function scrollbox.content:can_drag()
		return true
	end
	function scrollbox.content:drag()
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
			x = -scrollbox.T.x,
			y = -scrollbox.T.y,
		})

		local offset = self.click_offset
		offset.scroll_offset_x = offset.scroll_offset_x or scrollbox.scroll_offset.x
		offset.scroll_offset_y = offset.scroll_offset_y or scrollbox.scroll_offset.y

		scrollbox.scroll_offset.x = offset.scroll_offset_x - (_p.x - offset.x)
		scrollbox.scroll_offset.y = offset.scroll_offset_y - (_p.y - offset.y)

		local max_x, max_y = scrollbox:get_scroll_distance()
		scrollbox.scroll_offset.x = math.max(0, math.min(max_x, scrollbox.scroll_offset.x))
		scrollbox.scroll_offset.y = math.max(0, math.min(max_y, scrollbox.scroll_offset.y))

		scrollbox:sync_scroll_progress()
	end
end
function Glossary.UI.draggable_scrollable_content(content, max_content_w, max_content_h, scrolls_padding)
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

	Glossary.UI.init_draggable_scrollbox(content_overflow)

	local content_w = content_overflow.content.UIRoot.T.w
	local content_h = content_overflow.content.UIRoot.T.h

	return {
		n = G.UIT.R,
		nodes = {
			{
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						config = {
							no_overflow = true,
							maxw = max_content_w,
							maxh = max_content_h,
						},
						nodes = {
							{
								n = G.UIT.O,
								config = {
									object = content_overflow,
								},
							},
						},
					},
					content_h > max_content_h and { n = G.UIT.C, config = { minw = scrolls_padding or 0 } } or nil,
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
			content_w > max_content_w and { n = G.UIT.R, config = { minh = scrolls_padding or 0 } } or nil,
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
end

--

function Glossary.UI.prepare_overlay_menu()
	if not G.OVERLAY_MENU then
		G.OVERLAY_MENU = UIBox({ definition = { n = G.UIT.ROOT }, config = {} })
		G.OVERLAY_MENU.states.visible = false
		G.SETTINGS.paused = true
	end
end
-- Takes from Galdur by Eremel
function Glossary.populate_info_queue(set, key)
	local info_queue = {}
	local loc_target = G.localization.descriptions[set][key]
	for _, lines in ipairs(loc_target.text_parsed) do
		for _, part in ipairs(lines) do
			if part.control.T then
				info_queue[#info_queue + 1] = G.P_CENTERS[part.control.T]
					or G.P_TAGS[part.control.T]
					or G.P_BLINDS[part.control.T]
			end
		end
	end
	return info_queue
end

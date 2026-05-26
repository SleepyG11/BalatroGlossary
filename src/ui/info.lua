function G.FUNCS.glossary_overlay_menu(args)
	if not args then
		return
	end
	Glossary.history.save()
	--Remove any existing overlays if there is one
	local y_offset = 10
	if G.GLOSSARY_OVERLAY_MENU then
		G.GLOSSARY_OVERLAY_MENU:remove()
		y_offset = Glossary.cc.slide_on_page_change and 0.25 or 0
	end
	G.CONTROLLER.locks.frame_set = true
	G.CONTROLLER.locks.frame = true
	G.CONTROLLER.cursor_down.target = nil
	G.CONTROLLER:mod_cursor_context_layer(G.NO_MOD_CURSOR_STACK and 0 or 1)

	args.config = args.config or {}
	args.config = {
		align = args.config.align or "cm",
		offset = args.config.offset or { x = 0, y = y_offset },
		major = args.config.major or G.ROOM_ATTACH,
		bond = "Weak",
		no_esc = args.config.no_esc,
		parent = args.config.parent or G.ROOM_ATTACH,
	}
	G.GLOSSARY_OVERLAY_MENU = true
	--Generate the UIBox
	G.GLOSSARY_OVERLAY_MENU = UIBox({
		definition = args.definition,
		config = args.config,
	})

	Glossary.history.load()

	--Set the offset and align. The menu overlay can be initially offset in the y direction and this will ensure it slides to middle
	G.GLOSSARY_OVERLAY_MENU.alignment.offset.y = 0
	G.ROOM.jiggle = G.ROOM.jiggle + 1
	G.GLOSSARY_OVERLAY_MENU:align_to_major()
end

--Removes the overlay menu if one exists, unpauses the game, and saves the settings to file
G.FUNCS.glossary_exit_overlay_menu = function()
	if not G.GLOSSARY_OVERLAY_MENU then
		return
	end
	G.CONTROLLER.locks.frame_set = true
	G.CONTROLLER.locks.frame = true
	G.CONTROLLER:mod_cursor_context_layer(-1000)
	G.GLOSSARY_OVERLAY_MENU:remove()
	G.GLOSSARY_OVERLAY_MENU = nil
	if G.OVERLAY_MENU and G.OVERLAY_MENU.glossary_fake_menu then
		G.OVERLAY_MENU:remove()
		G.OVERLAY_MENU = nil
	end
end

local old_node_remove = Node.remove
function Node:remove(...)
	old_node_remove(self, ...)
	if self == G.OVERLAY_MENU and G.GLOSSARY_OVERLAY_MENU then
		G.GLOSSARY_OVERLAY_MENU:remove()
		G.GLOSSARY_OVERLAY_MENU = nil
	end
end

function Glossary.show_info_ui(input)
	local content = input.description
	local info_queue_render = input.info_queue
	local context = input.context
	local sections = context.sections

	local rows = {}
	for k, section in ipairs(Glossary.InfoSectionsPool) do
		local items = sections[section.key]
		if items then
			if not section:is_empty(items) then
				table.insert(rows, {
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						section:render(items),
					},
				})
			else
				section:destroy(items)
			end
		end
	end

	if info_queue_render and #context.info_queue > 0 then
		table.insert(rows, {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1 },
					nodes = {
						{
							n = G.UIT.R,
							config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, minh = 0.5 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = localize({
											type = "name_text",
											set = "Glossary_Other",
											key = "info_queue",
											vars = {},
										}),
										scale = 0.32,
										shadow = true,
										colour = G.C.UI.TEXT_LIGHT,
									},
								},
							},
						},
						{
							n = G.UIT.R,
							config = { align = "cm", padding = 0.1 },
							nodes = info_queue_render,
						},
					},
				},
			},
		})
	end

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
					Glossary.UI.draggable_scrollable_content(content, 9, 6, 0.1),
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
				Glossary.UI.draggable_scrollable_content(rows, 8, 6 + G.CARD_H, 0.1),
			},
		}
	end

	context.mod = context.mod or Glossary.get_target_mod(context.target_type, context.target)
	local mod = Glossary.cc.use_mods_colours and context.mod or nil

	G.FUNCS.glossary_overlay_menu({
		definition = create_UIBox_generic_options({
			colour = mod and ((mod.ui_config or {}).collection_colour or (mod.ui_config or {}).colour),
			bg_colour = mod and ((mod.ui_config or {}).collection_bg_colour or (mod.ui_config or {}).bg_colour),
			back_colour = mod and ((mod.ui_config or {}).collection_back_colour or (mod.ui_config or {}).back_colour),
			outline_colour = mod
				and ((mod.ui_config or {}).collection_outline_colour or (mod.ui_config or {}).outline_colour),
			back_func = "glossary_exit_overlay_menu",
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
	Glossary.history.add(context)
end

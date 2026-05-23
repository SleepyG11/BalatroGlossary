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
										text = "Info Queue",
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
				Glossary.UI.draggable_scrollable_content(rows, 8, 6 + G.CARD_H, 0.1),
			},
		}
	end

	Glossary.save_history()
	G.FUNCS.overlay_menu({
		definition = create_UIBox_generic_options({
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
	Glossary.load_history()
	Glossary.add_to_history(context)
end

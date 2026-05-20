function Glossary.display_ability_table(input)
	local content = input.description
	local info_queue_render = input.info_queue
	local context = input.context
	local containers = context.containers

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

	if info_queue_render and #context.info_queue > 0 then
		table.insert(rows, {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				{
					n = G.UIT.R,
					config = { align = "cm" },
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = "Info Queue",
								scale = 0.32,
								colour = G.C.UI.TEXT_LIGHT,
							},
						},
					},
				},
				{ n = G.UIT.R, config = { minh = 0.1 } },
				{
					n = G.UIT.R,
					config = { align = "cm", padding = 0.1 },
					nodes = info_queue_render,
				},
			},
		})
	end

	local left_content = {
		n = G.UIT.C,
		config = {
			padding = 0.1,
			align = "cm",
		},
		nodes = {
			input.main,
			Glossary.UI.draggable_scrollable_content(content, 7, 7, 0.1),
		},
	}
	local right_content
	if #rows > 0 then
		right_content = {
			n = G.UIT.C,
			config = { align = "cm" },
			nodes = {
				Glossary.UI.draggable_scrollable_content(rows, 7.4, 10, 0.1),
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

function Glossary.display_deck_stake() end

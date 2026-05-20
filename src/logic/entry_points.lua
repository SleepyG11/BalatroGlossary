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

function Glossary.new_info_queue_context(target_type, target, source_type, source)
	local containers = Glossary.create_containers()
	return {
		target_type = target_type,
		target = target,
		source_type = source_type,
		source = source,
		containers = containers,
		info_queue = {},
		extra = {},
	}
end

function Glossary.show_tag_info(tag)
	Glossary.UI.prepare_overlay_menu()

	local new_tag = Tag(tag.key)
	local tag_ui, tag_sprite = new_tag:generate_UI(1.2)
	local context = Glossary.new_info_queue_context("tag", new_tag, "tag", tag)
	Glossary.flitered_info_queue_context = context
	new_tag:get_uibox_table(tag_sprite)
	Glossary.flitered_info_queue_context = nil
	local popup = G.UIDEF.card_h_popup(tag_sprite)

	tag_sprite.hover = Sprite.hover

	local main_render = {
		n = G.UIT.R,
		config = { r = 0.25, padding = 0.1, colour = { 0, 0, 0, 0.1 }, align = "cm" },
		nodes = {
			tag_ui,
		},
	}

	local content = popup.nodes[1].nodes
	popup.nodes[1].nodes = {}
	local info_queue_render = popup.nodes[1].config.ref_table
	popup.nodes[1].config.ref_table = nil
	UIBox({
		definition = popup,
		config = {},
	}):remove()

	Glossary.display_ability_table({
		context = context,
		main = main_render,
		description = content,
		info_queue = info_queue_render,
	})
end
function Glossary.show_card_info(card)
	local back = Glossary.get_card_back_center(card)
	if back then
		return Glossary.show_back_info(back, "card", card)
	end
	Glossary.UI.prepare_overlay_menu()

	local main_card_area = CardArea(0, 0, G.CARD_W, G.CARD_H, {
		type = "title_2",
		highlight_limit = 0,
		collection = true,
	})

	local source_t = card.T
	local new_card = copy_card(card, nil, 1, nil, nil)
	new_card.T.w = source_t.w
	new_card.T.h = source_t.h
	main_card_area:emplace(new_card)

	local context = Glossary.new_info_queue_context("card", new_card, "card", card)
	local old_hover = Node.hover
	Node.hover = function() end
	Glossary.flitered_info_queue_context = context
	new_card:hover()
	Glossary.flitered_info_queue_context = nil
	Node.hover = old_hover

	local popup = new_card.config.h_popup
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

	local content = popup.nodes[1].nodes
	popup.nodes[1].nodes = {}
	local info_queue_render = popup.nodes[1].config.ref_table
	popup.nodes[1].config.ref_table = nil
	UIBox({
		definition = popup,
		config = {},
	}):remove()

	Glossary.display_ability_table({
		context = context,
		main = main_render,
		description = content,
		info_queue = info_queue_render,
	})
end
function Glossary.show_back_info(back, source_type, source)
	Glossary.UI.prepare_overlay_menu()

	local main_card_area = CardArea(0, 0, G.CARD_W, G.CARD_H, {
		card_limit = 20,
		type = "deck",
		collection = true,
	})

	local new_back = Back(back)
	local old_back, old_v_back = G.GAME.selected_back, G.GAME.viewed_back
	G.GAME.selected_back, G.GAME.viewed_back = new_back, new_back

	for i = 1, 20 do
		local deck_card = SMODS.create_card({
			key = "c_base",
			front = false,
			area = main_card_area,
		})
		deck_card.glossary_back = new_back
		deck_card.facing = "back"
		deck_card.sprite_facing = "back"
		deck_card.no_ui = true
		main_card_area:emplace(deck_card)
	end

	local context = Glossary.new_info_queue_context("back", new_back.effect.center, source_type, source)

	-- Taken from Galdur by Eremel
	context.AUT = { main = {}, info = {}, type = {}, name = "done", badges = {}, from_detailed_tooltip = true }
	context.info_queue = Glossary.populate_info_queue("Back", back.key)
	Glossary.process_info_queue(context)
	local info_queue_render = {}
	for _, center in pairs(context.info_queue) do
		local desc = generate_card_ui(center, context.AUT, nil, center.set, nil)
		info_queue_render[#info_queue_render + 1] = {
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						colour = lighten(G.C.JOKER_GREY, 0.5),
						r = 0.1,
						padding = 0.05,
						emboss = 0.05,
					},
					nodes = {
						info_tip_from_rows(desc.info[1], desc.info[1].name),
					},
				},
			},
		}
	end

	local old_desc_from_rows = desc_from_rows
	function desc_from_rows(a, b, maxw, ...)
		return old_desc_from_rows(a, b, 6, ...)
	end
	local deck_ui = G.GAME.selected_back:generate_UI(nil, 0.7, 0.5, G.GAME.challenge)
	local deck_name = G.GAME.selected_back:get_name()
	desc_from_rows = old_desc_from_rows

	G.GAME.selected_back, G.GAME.viewed_back = old_back, old_v_back

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

	local description = {
		{
			n = G.UIT.R,
			config = { padding = 0.05, r = 0.12, colour = lighten(G.C.JOKER_GREY, 0.5), emboss = 0.07 },
			nodes = {
				{
					n = G.UIT.R,
					config = {
						align = "cm",
						padding = 0.07,
						r = 0.1,
						colour = adjust_alpha(darken(G.C.BLACK, 0.1), 0.8),
					},
					nodes = {
						name_from_rows({
							{
								n = G.UIT.O,
								config = {
									object = DynaText({
										string = deck_name,
										maxw = 6,
										colours = { G.C.WHITE },
										shadow = true,
										bump = true,
										scale = 0.5,
										pop_in = 0,
										silent = true,
									}),
								},
							},
						}),
						desc_from_rows({ deck_ui.nodes }),
					},
				},
			},
		},
	}

	Glossary.display_ability_table({
		context = context,
		main = main_render,
		description = description,
		info_queue = info_queue_render,
	})
end

function Glossary.show_tag_info(tag, source_type, source)
	Glossary.UI.prepare_overlay_menu()

	local old_check_for_unlock = check_for_unlock
	check_for_unlock = function() end

	local tagConstructor = getmetatable(tag)
	local new_tag = tagConstructor(tag.key, true)
	new_tag.ability = SMODS.shallow_copy(tag.ability)
	new_tag.hide_ability = not Glossary.cc.bypass_discovery and tag.hide_ability or false
	local tag_ui, tag_sprite = new_tag:generate_UI(1.2)
	local context = Glossary.processing.new_context("tag", new_tag, source_type, source)
	Glossary.processing.request(context)
	new_tag:get_uibox_table(tag_sprite)
	Glossary.processing.clear_request()
	local popup = G.UIDEF.card_h_popup(tag_sprite)

	check_for_unlock = old_check_for_unlock

	tag_sprite.hover = Sprite.hover
	tag_ui.glossary_ignore = true
	tag_sprite.glossary_ignore = true

	local main_render = {
		n = G.UIT.R,
		config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, align = "cm", padding = 0.1 },
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

	Glossary.show_info_ui({
		context = context,
		main = main_render,
		description = content,
		info_queue = info_queue_render,
	})
end
function Glossary.show_card_info(card, source_type, source)
	local back = Glossary.get_card_back_center(card)
	if back then
		return Glossary.show_back_info(back, source_type, source)
	end
	Glossary.UI.prepare_overlay_menu()

	local main_card_area = CardArea(0, 0, G.CARD_W, G.CARD_H, {
		type = "title_2",
		highlight_limit = 0,
		collection = true,
	})

	local old_check_for_unlock = check_for_unlock
	check_for_unlock = function() end

	local new_card = Card(card.T.x, card.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, G.P_CENTERS.c_base, {
		bypass_discovery_center = card.bypass_discovery_center or Glossary.cc.bypass_discovery,
		bypass_discovery_ui = card.bypass_discovery_ui or Glossary.cc.bypass_discovery,
		bypass_lock = card.bypass_lock or Glossary.cc.bypass_lock,
	})
	copy_card(card, new_card, 1, nil, nil)
	main_card_area:emplace(new_card)
	new_card.glossary_ignore = true
	if new_card.ability.set == "Joker" then
		new_card.sticker = get_joker_win_sticker(new_card.config.center)
	end

	local context = Glossary.processing.new_context("card", new_card, source_type, source)
	local old_hover = Node.hover
	Node.hover = function() end
	Glossary.processing.request(context)
	new_card:hover()
	Glossary.processing.clear_request()
	Node.hover = old_hover

	check_for_unlock = old_check_for_unlock

	local popup = new_card.config.h_popup
	new_card.no_ui = true

	local main_render = {
		n = G.UIT.R,
		config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, align = "cm" },
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

	Glossary.show_info_ui({
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

	local old_check_for_unlock = check_for_unlock
	check_for_unlock = function() end

	local old_unlocked = back.unlocked
	if Glossary.cc.bypass_lock then
		back.unlocked = true
	end

	local new_back = Back(back)
	local old_back, old_v_back = G.GAME.selected_back, G.GAME.viewed_back
	G.GAME.selected_back, G.GAME.viewed_back = new_back, new_back
	local back_center = new_back.effect.center

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
		deck_card.glossary_ignore = true
	end

	local context = Glossary.processing.new_context("back", back_center, source_type, source)

	-- Taken from Galdur by Eremel
	context.AUT = { main = {}, info = {}, type = {}, name = "done", badges = {}, from_detailed_tooltip = true }
	context.info_queue = Glossary.populate_info_queue("back", back_center)
	Glossary.processing.request(context, true)
	Glossary.processing.process_before_context(context)
	Glossary.processing.process_individual_context(context)
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
	Glossary.processing.process_after_context(context)
	Glossary.processing.clear_request()

	local old_desc_from_rows = desc_from_rows
	function desc_from_rows(a, b, maxw, ...)
		return old_desc_from_rows(a, b, 6, ...)
	end
	local deck_ui = G.GAME.selected_back:generate_UI(nil, 0.7, 0.5, G.GAME.challenge)
	local deck_name = G.GAME.selected_back:get_name()
	desc_from_rows = old_desc_from_rows

	back.unlocked = old_unlocked

	G.GAME.selected_back, G.GAME.viewed_back = old_back, old_v_back

	check_for_unlock = old_check_for_unlock

	local main_render = {
		n = G.UIT.R,
		config = { r = 0.25, colour = { 0, 0, 0, 0.1 }, align = "cm" },
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

	Glossary.show_info_ui({
		context = context,
		main = main_render,
		description = description,
		info_queue = info_queue_render,
	})
end

Glossary.entry_points = {
	mod_config = function(target, source_type, source)
		return Glossary.show_mod_config(target, source_type, source)
	end,
	tag = function(target, source_type, source)
		return Glossary.show_tag_info(target, source_type, source)
	end,
	back = function(target, source_type, source)
		return Glossary.show_back_info(target, source_type, source)
	end,
	card = function(target, source_type, source)
		return Glossary.show_card_info(target, source_type, source)
	end,
}

function Glossary.show_info(target_type, target, source_type, source)
	return Glossary.entry_points[target_type] and Glossary.entry_points[target_type](target, source_type, source)
end

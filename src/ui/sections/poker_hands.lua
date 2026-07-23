local old_is_visible = SMODS.is_poker_hand_visible
function SMODS.is_poker_hand_visible(...)
	if Glossary.ARGS.bypass_poker_hand_visible then
		return true
	end
	return old_is_visible(...)
end

function Glossary.UI.simple_poker_hand(handname, simple, in_collection)
	Glossary.ARGS.bypass_poker_hand_visible = true
	local vanilla_ui = create_UIBox_current_hand_row(handname, simple, in_collection)
	Glossary.ARGS.bypass_poker_hand_visible = nil
	if simple then
		return vanilla_ui
	else
		local left_part = table.remove(vanilla_ui.nodes, 1)
		left_part.nodes[2].config.minw = 3.65
		left_part.nodes[2].config.maxw = 3.65
		local new_nodes = vanilla_ui.nodes

		local right_side = {}
		table.insert(right_side, table.remove(vanilla_ui.nodes, #vanilla_ui.nodes - 1))
		table.insert(right_side, table.remove(vanilla_ui.nodes, #vanilla_ui.nodes))

		left_part.nodes[1] = {
			n = G.UIT.C,
			config = { minw = 2.2, maxw = 2.2, align = "cl" },
			nodes = {
				left_part.nodes[1],
			},
		}

		vanilla_ui.nodes = {
			{
				n = G.UIT.R,
				config = { padding = 0.025 },
				nodes = {
					left_part,
				},
			},
			{
				n = G.UIT.R,
				config = {
					func = "glossary_attach_uibox",
					ref_table = {
						definition = {
							n = G.UIT.ROOT,
							config = { colour = G.C.CLEAR, padding = 0.025 },
							nodes = right_side,
						},
						config = {
							align = "cri",
							can_collide = false,
						},
					},
				},
				nodes = new_nodes,
			},
		}

		local _planet
		for k, v in pairs(G.P_CENTER_POOLS.Planet) do
			if v.config.hand_type == handname then
				_planet = v.key
			end
		end

		if _planet then
			local planet_area = CardArea(0, 0, 0.9, 0.9, { highlight_limit = 0, type = "title_2", collection = true })
			local card = Glossary.safe_card_from_center(_planet, planet_area)
			card:hard_set_T(0, 0, G.CARD_W / 2.25, G.CARD_H / 2.25)
			planet_area:emplace(card)
			return {
				n = G.UIT.R,
				config = { colour = { 0, 0, 0, 0.1 }, r = 0.25, align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						nodes = {
							vanilla_ui,
						},
					},
					{
						n = G.UIT.O,
						config = {
							object = planet_area,
						},
					},
				},
			}
		end

		return vanilla_ui
	end
end

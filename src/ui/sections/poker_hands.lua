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
		return vanilla_ui
	end
end

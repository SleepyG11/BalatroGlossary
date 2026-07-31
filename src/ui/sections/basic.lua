function Glossary.UI.section(name, content)
	return {
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
							text = name,
							scale = 0.32,
							shadow = true,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = { align = "cm", padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
				nodes = {
					content,
				},
			},
		},
	}
end

function Glossary.UI.basic_section(section, data, content)
	local key, set, vars = section.key, section.set, {}
	if section.loc_vars and type(section.loc_vars) == "function" then
		local r = section:loc_vars(data)
		key = r.key or key
		set = r.set or set
		vars = r.vars or vars
	end
	local section_name = localize({ type = "name_text", key = key, set = set, vars = vars })
	return Glossary.UI.section(section_name, content)
end
function Glossary.UI.extendable_section(section, content, extra)
	extra = extra or {}
	return {
		n = G.UIT.R,
		config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, padding = 0.1 },
		nodes = {
			extra.left_content and {
				n = G.UIT.C,
				config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25 },
				nodes = {
					extra.left_content,
				},
			} or nil,
			{
				n = G.UIT.C,
				nodes = {
					{
						n = G.UIT.R,
						config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25, minh = 0.5 },
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = localize({ type = "name_text", key = section.key, set = section.set }),
									scale = 0.32,
									shadow = true,
									colour = G.C.UI.TEXT_LIGHT,
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { minh = 0.1 },
					},
					{
						n = G.UIT.R,
						config = { align = "cm", padding = 0.1, r = 0.25, colour = { 0, 0, 0, 0.1 } },
						nodes = {
							content,
						},
					},
				},
			},
			extra.right_content and {
				n = G.UIT.C,
				config = { align = "cm", colour = { 0, 0, 0, 0.1 }, r = 0.25 },
				nodes = {
					extra.right_content,
				},
			} or nil,
		},
	}
end

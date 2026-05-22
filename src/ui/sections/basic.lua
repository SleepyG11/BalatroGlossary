function Glossary.UI.basic_section(section, header_text, content)
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
							text = header_text or "ERROR",
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

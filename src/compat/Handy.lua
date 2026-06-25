if not (Handy and Handy.API) then
	return
end

Handy.API.DefaultConfig({
	glossary_open = {
		enabled = true,
		keys_1 = { "Right Mouse" },
		keys_2 = {},
	},
})
Handy.API.Dictionary({
	key = "glossary_open",

	keywords = { "glossary" },
	get_module = function(self)
		return Handy.cc.glossary_open
	end,

	checkbox = true,
	keybind = {
		allow_multiple = true,
	},
})
Handy.API.Control({
	key = "glossary_open",
	get_module = function(self)
		return Handy.cc.glossary_open
	end,

	contexts = {
		input = true,
	},

	execute = function(self, ctx, args)
		return Glossary.open(G.CONTROLLER.hovering.target)
	end,
})
Handy.API.Stack({
	key = "glossary_open",
	stack_path = "input.regular_keybinds.menus",
	order = 10,
	control = true,
})

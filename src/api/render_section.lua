Glossary.RenderSections = {}
Glossary.RenderSectionsPool = {}
Glossary.RenderSection = SMODS.GameObject:extend({
	set = "GlossaryRenderSection",
	obj_table = Glossary.RenderSections,
	obj_buffer = {},
	required_keys = {
		"key",
		"order",
	},
	pre_inject_class = function()
		EMPTY(Glossary.RenderSectionsPool)
	end,
	inject = function(self)
		table.insert(Glossary.RenderSectionsPool, self)
	end,
	post_inject_class = function(self)
		table.sort(Glossary.RenderSectionsPool, function(a, b)
			return a.order < b.order
		end)
	end,
	process_loc_text = function() end,

	is_empty = function(self, c)
		return true
	end,

	create = function(self) end,
	destroy = function(self, c) end,
	insert = function(self, c) end,
	render = function(self, c) end,
})

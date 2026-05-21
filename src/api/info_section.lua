Glossary.InfoSections = {}
Glossary.InfoSectionsPool = {}
Glossary.InfoSection = SMODS.GameObject:extend({
	set = "GlossaryInfoSection",
	obj_table = Glossary.InfoSections,
	obj_buffer = {},
	required_keys = {
		"key",
		"order",
	},
	pre_inject_class = function()
		EMPTY(Glossary.InfoSectionsPool)
	end,
	inject = function(self)
		table.insert(Glossary.InfoSectionsPool, self)
	end,
	post_inject_class = function(self)
		table.sort(Glossary.InfoSectionsPool, function(a, b)
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

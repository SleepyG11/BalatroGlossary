Glossary.InfoQueueFilters = {}
Glossary.InfoQueueFiltersPool = {}
Glossary.InfoQueueFilter = SMODS.GameObject:extend({
	set = "GlossaryInfoQueueFilter",
	obj_table = Glossary.InfoQueueFilters,
	obj_buffer = {},
	required_keys = {
		"key",
		"order",
	},
	pre_inject_class = function()
		EMPTY(Glossary.InfoQueueFiltersPool)
	end,
	inject = function(self)
		table.insert(Glossary.InfoQueueFiltersPool, self)
	end,
	post_inject_class = function(self)
		table.sort(Glossary.InfoQueueFiltersPool, function(a, b)
			return a.order < b.order
		end)
	end,
	process_loc_text = function() end,

	func = function(self, context) end,
})

Glossary.InfoQueueProcessors = {}
Glossary.InfoQueueProcessorsPool = {}
Glossary.InfoQueueProcessor = SMODS.GameObject:extend({
	set = "Glossary_InfoQueueProcessor",
	obj_table = Glossary.InfoQueueProcessors,
	obj_buffer = {},
	required_keys = {
		"key",
		"order",
	},
	pre_inject_class = function()
		EMPTY(Glossary.InfoQueueProcessorsPool)
	end,
	inject = function(self)
		table.insert(Glossary.InfoQueueProcessorsPool, self)
	end,
	post_inject_class = function(self)
		table.sort(Glossary.InfoQueueProcessorsPool, function(a, b)
			return a.order < b.order
		end)
	end,
	process_loc_text = function(self) end,

	func = function(self, context) end,
	conditions = { individual = true },
})

function Glossary.get_processors(context_type)
	if not context_type then
		return SMODS.shallow_copy(Glossary.InfoQueueProcessorsPool)
	end
	local result = {}
	for _, processor in ipairs(Glossary.InfoQueueProcessorsPool) do
		if processor.conditions and processor.conditions[context_type] then
			table.insert(result, processor)
		end
	end
	return result
end

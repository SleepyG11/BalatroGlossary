Glossary = {}
Glossary.current_mod = SMODS.current_mod

function Glossary.load_file(path)
	assert(SMODS.load_file(path))()
end
function Glossary.load_files(paths, prefix)
	for _, path in ipairs(paths) do
		Glossary.load_file(prefix .. path)
	end
end

Glossary.load_file("src/index.lua")

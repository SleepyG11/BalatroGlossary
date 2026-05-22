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
function Glossary.load_directory(path, recursive)
	for _, file in ipairs(SMODS.NFS.getDirectoryItems(Glossary.current_mod.path .. path)) do
		local partial_path = path .. "/" .. file
		local info = SMODS.NFS.getInfo(Glossary.current_mod.path .. partial_path)
		if info.type == "directory" then
			if recursive then
				Glossary.load_directory(partial_path, recursive)
			end
		elseif info.type == "file" then
			Glossary.load_file(partial_path)
		end
	end
end

Glossary.load_file("src/index.lua")

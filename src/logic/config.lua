Glossary.config = {}

Glossary.config.current = Glossary.current_mod.config
Glossary.cc = Glossary.config.current

function Glossary.config.save()
	SMODS.save_mod_config(Glossary.current_mod)
end

local L = LibStub("AceLocale-3.0"):NewLocale("Identity2", "ptBR", false)

if L then
    L["migration.created_new_profile"] = function(profile_name) return "Novo Perfil |cFFC6A15B" .. profile_name .. "|r criado pela migração de versão antiga" end
    L["migration.finished"] = function(created_new_profile) local text = "Migração das configurações desta personagem concluída"; if(created_new_profile) then text = text .. ". Um novo perfil foi criado por razão de conflito com o perfil ativo" end return text end
    
    L["channel.GUILD.name"] = "Bate-papo da guilda"
    L["channel.OFFICER.name"] = "Bate-papo de oficiais"
    L["channel.RAID.name"] = "Raide"
    L["channel.PARTY.name"] = "Grupo"
    L["channel.INSTANCE_CHAT.name"] = "Instância"
    L["channel.WHISPER.name"] = "Sussurrar"
    L["channel.SAY.name"] = "Dizer"
    L["channel.YELL.name"] = "Gritar"
    L["channel.BN_WHISPER.name"] = "Sussurro da Battle.net"
    
    L["options.name"] = "Opções Gerais"
    L["options.version.name"] = function(version) return "Identity 2 versão " .. version end
    L["options.enable.name"] = "Ativar"
    L["options.enable.desc"] = "Ativa/Desativa o Identity"
    L["options.fun.name"] = "Diversão"
    L["options.fun.desc"] = "Informa para o Identity se você gosta de diversão em dias especiais"
    L["options.format.name"] = "Formato"
    L["options.format.desc"] = "Define o formato usado para mostrar sua Identidade. Padrão: [%s]\n\nTokens válidos para uso no formato:\n    %s -> Será substituído pela identidade\n\n    %z -> Será substituído pelo nome da zona atual\n\n    %l -> Será substituído pelo nível da personagem\n\n    %g -> Será substituído pelo nome da Guilda da personagem\n\n    %r -> Será substituído pelo nome do Reino da personagem"
    L["options.identity.name"] = "Identidade"
    L["options.identity.desc"] = "Define o texto usado como sua Identidade"
    L["options.default_channels.name"] = "Canais Padrões"
    L["options.custom_channels.name"] = "Canais Customizados"
    L["options.custom_channels.add.name"] = "Adiciona Canal"
    L["options.custom_channels.add.desc"] = "Digite o nome do canal a ser adicionado e pressione Ok"
    L["options.custom_channels.error.empty"] = "Nome do Canal não pode ser em branco"
    L["options.custom_channels.error.already_exists"] = "Um Canal com esse nome já está cadastrado"
    L["options.communities.name"] = "Comunidades"
    L["options.communities.add.name"] = "Adiciona Comunidade"
    L["options.communities.add.desc"] = "Digite o nome da comunidade a ser adicionada e pressione Ok"
    L["options.communities.no_streams"] = "Nenhum canal nesta comunidade no momento ou o personagem não está nesta comunidade"
    L["options.communities.error.empty"] = "Nome da Comunidade não pode ser em branco"
    L["options.communities.error.already_exists"] = "Uma Comunidade com esse nome já está cadastrada"
    L["options.communities.remove.name"] = "Remover Comunidade"
    L["options.community.enable.name"] = "Ativar Comunidade"
    L["options.community.enable.desc"] = function(community) return "Ativa/Desativa " .. community end
    L["options.channels.enable.name"] = "Ativar Canal"
    L["options.channels.enable.desc"] = function(channel) return "Ativa/Desativa " .. channel end
    L["options.channels.identity.name"] = "Identidade no Canal"
    L["options.channels.identity.desc"] = function(channel, main_identity) return "Define o texto para uso em " .. channel .. " no lugar de " .. main_identity end
    L["options.channels.preview_header"] = "Prévia da Identidade"
    L["options.channels.preview.message"] = "Isto é uma prévia da Identidade atual"
    L["options.channels.remove.name"] = "Remover Canal"
    
    L["profiles.name"] = "Perfis"
    
    L["initialization.loaded"] = function(version) return "Versão " .. version .. " carregada." end
    L["initialization.updated"] = function(version) return "Atualizado para versão " .. version end

    L["fun.prank.jenkins"] = " Jenkins"
    L["fun.prank.guldan_start"] = "Gul'"
    L["fun.prank.guldan_end"] = "'Dan"
    L["fun.prank.the_cute"] =  function() return GetRandomArgument(" o Fofo", " a Fofa") end
    L["fun.prank.magnificient"] = "Magnificente "
    L["fun.prank.the_third"] = function(identity) return GetRandomArgument("Senhor ", "Senhora ") .. identity .. " III" end
    L["fun.prank.prince"] = "Aquele anteriormente conhecido como "
    L["fun.prank.master_roshi"] = "Mestre Kame"
    L["fun.prank.whats_the_name_of_the_song"] = "Darude - Sandstorm"
    L["fun.prank.404"] = "#INSIRA_INDENTIDADE_AQUI#"
    L["fun.prank.univere_life_everything_else"] = "42"
    L["fun.prank.rhonin_best_quote"] = function() return GetRandomArgument("Cidadão", "Cidadã") .. " de Dalaran" end
    L["fun.prank.not"] = "Não "
    L["fun.prank.plated"] = function(identity) return identity .. " Banhado à " .. GetRandomArgument("ouro", "prata", "cobre") end
    L["fun.prank.item_quality"] = function(identity) return GetRandomArgument("Artifact(Gold) ", "Heirloom(Cyan) ", "Legendary(Orange) ", "Epic(Purple) ", "Rare(Blue) ", "Uncommon(Green) ", "Common(White) ", "Poor(Grey) ")  .. identity end
    L["fun.prank.size"] = function() return GetRandomArgument("Pequeno ", "Grande ") end
    
    L["fun.hohoho.santa"] = function(identity) return identity .. " Noel" end --usar Papai ou Mamãe sem o Noel fica muito estranho
    L["fun.hohoho.claus"] = function(identity) return identity .. " Noel" end
    L["fun.hohoho.red_nose"] = function(identity) return identity .. ", do Nariz Vermelho" end
end

local L = LibStub("AceLocale-3.0"):NewLocale("Identity2", "enUS", true)

if L then
    L["migration.created_new_profile"] = function(profile_name) return "New profile |cFFC6A15B" .. profile_name .. "|r created by migration of old version" end
    L["migration.finished"] = function(created_new_profile) local text = "Migration of this character's configurations finished"; if(created_new_profile) then text = text .. ". A new profile was created because of conflicts with the active profile" end return text end
    
    L["channel.GUILD.name"] = "Guild"
    L["channel.OFFICER.name"] = "Officer"
    L["channel.RAID.name"] = "Raid"
    L["channel.PARTY.name"] = "Party"
    L["channel.INSTANCE_CHAT.name"] = "Instance"
    L["channel.WHISPER.name"] = "Whisper"
    L["channel.SAY.name"] = "Say"
    L["channel.YELL.name"] = "Yell"
    L["channel.BN_WHISPER.name"] = "Battle.net Whisper"
    
    L["options.name"] = "General Options"
    L["options.version.name"] = function(version) return "Identity 2 version " .. version end
    L["options.enable.name"] = "Enable"
    L["options.enable.desc"] = "Enable/Disable Identity"
    L["options.fun.name"] = "Fun"
    L["options.fun.desc"] = "Inform Identity if you like to have fun on special days"
    L["options.format.name"] = "Format"
    L["options.format.desc"] = "Sets the format used to display your Identity. Default: [%s]\n\nValid tokens for use in the format:\n    %s -> Will be replaced by the identity\n\n    %z -> Will be replaced by the name of the current zone\n\n    %l -> Will be replaced by the character level\n\n    %g -> Will be replaced by the character guild\n\n    %r -> Will be replaced by the realm name\n\n    %f -> Will be replaced by the character faction"
    L["options.identity.name"] = "Identity"
    L["options.identity.desc"] = "Sets the string used as your Identity"
    L["options.default_channels.name"] = "Default Channels"
    L["options.custom_channels.name"] = "Custom Channels"
    L["options.custom_channels.add.name"] = "Add Channel"
    L["options.custom_channels.add.desc"] = "Type the name of the channel to add and press Okay"
    L["options.custom_channels.error.empty"] = "Channel name must not be empty"
    L["options.custom_channels.error.already_exists"] = "A Channel with this name is already registered"
    L["options.communities.name"] = "Communities"
    L["options.communities.error.empty"] = "Community name must not be empty"
    L["options.communities.error.already_exists"] = "A Community with this name is already registered"
    L["options.communities.add.name"] = "Add Community"
    L["options.communities.add.desc"] = "Type the name of the community to add and press Okay"
    L["options.communities.no_streams"] = "No channels on this community at the moment or the character is not in this community"
    L["options.communities.remove.name"] = "Remove Community"
    L["options.community.enable.name"] = "Enable Community"
    L["options.community.enable.desc"] = function(community) return "Enable/Disable " .. community end
    L["options.channels.enable.desc"] = function(channel) return "Enable/Disable " .. channel end
    L["options.channels.enable.name"] = "Enable Channel"
    L["options.channels.identity.name"] = "Channel Identity"
    L["options.channels.identity.desc"] = function(channel, main_identity) return "Sets a string to use in " .. channel .. " instead of " .. main_identity end
    L["options.channels.preview_header"] = "Identity Preview"
    L["options.channels.preview.message"] = "This is a preview of the current Identity"
    L["options.channels.remove.name"] = "Remove Channel"
    
    L["profiles.name"] = "Profiles"
    
    L["initialization.loaded"] = function(version) return "Version " .. version .. " loaded." end
    L["initialization.updated"] = function(version) return "Updated to version " .. version end
    
    L["fun.prank.jenkins"] = " Jenkins"
    L["fun.prank.guldan_start"] = "Gul'"
    L["fun.prank.guldan_end"] = "'Dan"
    L["fun.prank.the_cute"] =  function() return " the Cute" end
    L["fun.prank.magnificient"] = "Magnificient "
    L["fun.prank.the_third"] = function(identity) return GetRandomArgument("Lord ", "Lady ") .. identity .. " the III" end
    L["fun.prank.prince"] = "The one formerly known as "
    L["fun.prank.master_roshi"] = "Master Roshi"
    L["fun.prank.whats_the_name_of_the_song"] = "Darude - Sandstorm"
    L["fun.prank.404"] = "#INSERT_IDENTITY_HERE#"
    L["fun.prank.univere_life_everything_else"] = "42"
    L["fun.prank.rhonin_best_quote"] = function() return "Citizen of Dalaran" end
    L["fun.prank.not"] = "Not "
    L["fun.prank.plated"] = function(identity) return GetRandomArgument("Gold", "Silver", "Cooper") .. " plated " .. identity end
    L["fun.prank.item_quality"] = function(identity) return GetRandomArgument("Artefato(Dourado) ", "Herança(Ciano) ", "Lendário(Laranja) ", "Épico(Roxo) ", "Raro(Azul) ", "Incomum(Verde) ", "Comum(Branco) ", "Inferior(Cinza) ")  .. identity end
    L["fun.prank.size"] = function() return GetRandomArgument("Small ", "Big ") end
    
    L["fun.hohoho.santa"] = function(identity) return "Santa " .. identity end
    L["fun.hohoho.claus"] = function(identity) return identity .. " Claus" end
    L["fun.hohoho.red_nose"] = function(identity) return identity .. ", the Red-Nosed" end
end

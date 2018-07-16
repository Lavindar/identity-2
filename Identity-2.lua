Identity2 = LibStub("AceAddon-3.0"):NewAddon("Identity2", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("Identity2", true)

local defaults = {
    global = {
        version = "4.0.0"
    },
    profile = {
        enabled = true,
        format = "[%s]",
        identity = "",
        fun = true,
    
        channels = {
            ["GUILD"] = {
                enabled = false,
                identity = "",
                type = "GUILD",
                order = 0
            },
            ["OFFICER"] = {
                enabled = false,
                identity = "",
                type = "OFFICER",
                order = 1
            },
            ["RAID"] = {
                enabled = false,
                identity = "",
                type = "RAID",
                order = 2
            },
            ["PARTY"] = {
                enabled = false,
                identity = "",
                type = "PARTY",
                order = 3
            },
            ["INSTANCE_CHAT"] = {
                enabled = false,
                identity = "",
                type = "INSTANCE_CHAT",
                order = 4
            },
            ["WHISPER"] = {
                enabled = false,
                identity = "",
                type = "WHISPER",
                order = 5
            },
            ["SAY"] = {
                enabled = false,
                identity = "",
                type = "SAY",
                order = 6
            },
            ["YELL"] = {
                enabled = false,
                identity = "",
                type = "YELL",
                order = 7
            },
            customs = {},
            communities = {}
        },
    }
}

local options = nil

local classColors = {
    [1] = "C79C6E", --WARRIOR
    [2] = "F58CBA", --PALADIN
    [3] = "ABD473", --HUNTER
    [4] = "FFF569", --ROGUE
    [5] = "FFFFFF", --PRIEST
    [6] = "C41F3B", --DEATHKNIGHT
    [7] = "0070DE", --SHAMAN
    [8] = "69CCF0", --MAGE
    [9] = "9482C9", --WARLOCK
    [10]  = "00FF96", --MONK
    [11]  = "FF7D0A", --DRUID
    [12]  = "A330C9" --DEMONHUNTER
}

function Identity2:Migration()
    if(IdentitySettings.Version) then
        local need_new_profile = false
        
        if(self.db.profile.identity ~= "") then
            if(self.db.profile.enabled ~= IdentitySettings.Enabled) then need_new_profile = true end
            if(self.db.profile.format ~= IdentitySettings.Format) then need_new_profile = true end
            if(self.db.profile.identity ~= IdentitySettings.MainName) then need_new_profile = true end
            if(self.db.profile.fun ~= IdentitySettings.Fun) then need_new_profile = true end
            
            for key, value in pairs(IdentitySettings.Channels) do
                if(key == "Guild") then if(self.db.profile.channels["GUILD"].enabled ~= value) then need_new_profile = true end
                elseif(key == "Officer") then if(self.db.profile.channels["OFFICER"].enabled ~= value) then need_new_profile = true end
                elseif(key == "Tell") then if(self.db.profile.channels["WHISPER"].enabled ~= value) then need_new_profile = true end
                elseif(key == "Instance") then
                    if(self.db.profile.channels["INSTANCE_CHAT"].enabled ~= value) then need_new_profile = true end
                    if(self.db.profile.channels["INSTANCE_CHAT"].identity ~= IdentitySettings.NickName) then need_new_profile = true end
                elseif(key == "Raid") then
                    if(self.db.profile.channels["RAID"].enabled ~= value) then need_new_profile = true end
                    if(self.db.profile.channels["RAID"].identity ~= IdentitySettings.NickName) then need_new_profile = true end
                elseif(key == "Party") then
                    if(self.db.profile.channels["PARTY"].enabled ~= value) then need_new_profile = true end
                    if(self.db.profile.channels["PARTY"].identity ~= IdentitySettings.NickName) then need_new_profile = true end
                else
                    local s, e, number = string.find(key, "C(%d%d)")
                    
                    local id, name, instanceID = GetChannelName(number)
                    
                    if(name) then
                        if(self.db.profile.channels.customs[name].enabled ~= value) then need_new_profile = true end
                    end
                end
            end
        
            if(need_new_profile) then
                local profile_name = IdentitySettings.Version .. " - " .. UnitName("player") .. "-" .. GetRealmName()
                
                Identity2.db:SetProfile(profile_name)
                
                self:Print(L["migration.created_new_profile"](profile_name))
            end
        end
        
        self.db.profile.enabled = IdentitySettings.Enabled
        self.db.profile.format = IdentitySettings.Format
        self.db.profile.identity = IdentitySettings.MainName
        self.db.profile.fun = IdentitySettings.Fun
        
        for key, value in pairs(IdentitySettings.Channels) do
            if(key == "Guild") then self.db.profile.channels["GUILD"].enabled = value
            elseif(key == "Officer") then self.db.profile.channels["OFFICER"].enabled = value
            elseif(key == "Tell") then self.db.profile.channels["WHISPER"].enabled = value
            elseif(key == "Instance") then
                self.db.profile.channels["INSTANCE_CHAT"].enabled = value
                self.db.profile.channels["INSTANCE_CHAT"].identity = IdentitySettings.NickName
            elseif(key == "Raid") then
                self.db.profile.channels["RAID"].enabled = value
                self.db.profile.channels["RAID"].identity = IdentitySettings.NickName
            elseif(key == "Party") then
                self.db.profile.channels["PARTY"].enabled = value
                self.db.profile.channels["PARTY"].identity = IdentitySettings.NickName
            else
                local s, e, number = string.find(key, "C(%d%d)")
                
                local id, name, instanceID = GetChannelName(number)
                
                if(name) then
                    local new_channel = {
                        enabled = value,
                        identity = "",
                        type = "CUSTOM",
                        order = table.getn(self.db.profile.channels.customs) + 1,
                        name = name
                    }
                    
                    self.db.profile.channels.customs[name] = new_channel
                end
            end
        end
        
        IdentitySettings = {}
    
        self:Print(L["migration.finished"](need_new_profile))
    end
end

function Identity2:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("IdentityDB", defaults, true)
    
    if(IdentitySettings) then
        self:Migration()
    end
    
    options = {
        name = L["options.name"],
        handler = self,
        type = "group",
        childGroups = "tab",
        args = {
            version = {
                name = L["options.version.name"](self.db.global.version),
                type = "description",
                order = 0,
                width = "full"
            },
            header = {
                name = "",
                type = "header",
                order = 1
            },
            enable = {
                name = L["options.enable.name"],
                desc = L["options.enable.desc"],
                type = "toggle",
                order = 2,
                set = function(info, value) self.db.profile.enabled = value end,
                get = function(info) return self.db.profile.enabled end
            },
            fun = {
                name = L["options.fun.name"],
                desc = L["options.fun.desc"],
                type = "toggle",
                order = 3,
                set = function(info, value) self.db.profile.fun = value end,
                get = function(info) return self.db.profile.fun end
            },
            format = {
                name = L["options.format.name"],
                desc = L["options.format.desc"],
                type = "input",
                order = 4,
                set = function(info, value) if(value == "") then self.db.profile.format = "[%s]" else self.db.profile.format = value end end,
                get = function(info) return self.db.profile.format end,
                multiline = false
            },
            identity = {
                name = L["options.identity.name"],
                desc = L["options.identity.desc"],
                type = "input",
                order = 5,
                width = "full",
                set = function(info, value) self.db.profile.identity = value end,
                get = function(info) return self.db.profile.identity end,
                multiline = false
            },
            default_channels = {
                name = L["options.default_channels.name"],
                type = "group",
                order = 6,
                args = {}
            },
            custom_channels = {
                name = L["options.custom_channels.name"],
                type = "group",
                order = 7,
                args = {}
            },
            communities = {
                name = L["options.communities.name"],
                type = "group",
                order = 8,
                args = {}
            }
        }
    }
    
    self:LoadDefaultChannels()
    
    self:LoadCustomChannels()
    
    self:LoadCommunities()
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Identity2", options)
    generalOptions = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Identity2", "Identity 2")
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Identity2 Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    profilesOptions = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Identity2 Profiles", L["profiles.name"], "Identity 2")
    
    self:RegisterChatCommand("id", "SlashProcessor")
    self:RegisterChatCommand("identity", "SlashProcessor")
    
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")

    function self:SlashProcessor(input)
        self:RefreshConfig()
    
        InterfaceOptionsFrame_OpenToCategory(generalOptions)
		InterfaceOptionsFrame_OpenToCategory(profilesOptions)
        InterfaceOptionsFrame_OpenToCategory(generalOptions)
    end
    
    self:RegisterEvent("CLUB_ADDED", "eventHandler")
    self:RegisterEvent("CLUB_UPDATED", "eventHandler")
    self:RegisterEvent("CLUB_STREAM_ADDED", "eventHandler")
    self:RegisterEvent("CLUB_STREAM_UPDATED", "eventHandler")
    self:RegisterEvent("CLUB_STREAM_REMOVED", "eventHandler")
    self:RegisterEvent("CLUB_STREAM_SUBSCRIBED", "eventHandler")
    
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    if(self.db.global.version ~= defaults.global.version) then
        self.db.global.version = defaults.global.version
        self:Print(L["initialization.updated"](self.db.global.version))
    else
        self:Print(L["initialization.loaded"](self.db.global.version))
    end
end

function Identity2:eventHandler(event, ...)
    if(event == "CLUB_ADDED" or event == "CLUB_UPDATED" or event == "CLUB_STREAM_ADDED" or event == "CLUB_STREAM_UPDATED" or event == "CLUB_STREAM_REMOVED" or event == "CLUB_STREAM_SUBSCRIBED") then
        self:RefreshConfig()
    end
end

function Identity2:RefreshConfig()
    self:LoadDefaultChannels()
    self:LoadCustomChannels()
    self:LoadCommunities()
    
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Identity2")
end

function Identity2:LoadDefaultChannels()
    options.args.default_channels.args = {}
    
    for key, channel in pairs(self.db.profile.channels) do
        if(key ~= "customs" and key ~= "communities") then
            local channel_fields = {
                name = L["channel." .. channel.type .. ".name"],
                type = "group",
                order = channel.order,
                args = {
                    header = {
                        name = L["channel." .. channel.type .. ".name"],
                        type = "header",
                        order = 0
                    },
                    enable = {
                        name = L["options.channels.enable.name"],
                        desc = L["options.channels.enable.desc"](L["channel." .. channel.type .. ".name"]),
                        type = "toggle",
                        order = 1,
                        set = function(info, value) channel.enabled = value end,
                        get = function(info) return channel.enabled end
                    },
                    identity = {
                        name = L["options.channels.identity.name"],
                        desc = L["options.channels.identity.desc"](L["channel." .. channel.type .. ".name"], self.db.profile.identity),
                        type = "input",
                        order = 2,
                        width = "full",
                        set = function(info, value) channel.identity = value end,
                        get = function(info) return channel.identity end,
                        multiline = false
                    },
                    preview_header = {
                        name = L["options.channels.preview_header"],
                        type = "header",
                        order = 3
                    },
                    preview = {
                        name = function(info) return self:PreviewMessage(channel) end,
                        type = "description",
                        order = 4,
                        fontSize = "medium"
                    }
                }
            }
        
            options.args.default_channels.args[channel.type] = channel_fields
        end
    end
end

function Identity2:addCustomChannel(info, name)
    if(name == "") then
        UIErrorsFrame:AddMessage(L["options.custom_channels.error.empty"], 1.0, 0.0, 0.0, 5.0)
    elseif(self.db.profile.channels.customs[name]) then
        UIErrorsFrame:AddMessage(L["options.custom_channels.error.already_exists"], 1.0, 0.0, 0.0, 5.0)
    else
        local new_channel = {
            enabled = false,
            identity = "",
            type = "CUSTOM",
            order = table.getn(self.db.profile.channels.customs) + 1,
            name = name
        }
        
        self.db.profile.channels.customs[name] = new_channel
        
        self:LoadCustomChannels()
        
        LibStub("AceConfigRegistry-3.0"):NotifyChange("Identity2")
    end
end

function Identity2:removeCustomChannel(channel)
    self.db.profile.channels.customs[channel.name] = nil
    
    self:LoadCustomChannels()
    
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Identity2")
end

function Identity2:LoadCustomChannels()
    options.args.custom_channels.args = {
        add = {
            name = L["options.custom_channels.add.name"],
            desc = L["options.custom_channels.add.desc"],
            type = "input",
            order = -1,
            width = "full",
            set = "addCustomChannel",
            multiline = false,
            validate = function(info, value) if(value == "") then return L["options.custom_channels.error.empty"] elseif(self.db.profile.channels.customs[value]) then return L["options.custom_channels.error.already_exists"] else return true end end
        }
    }
    
    for key, channel in pairs(self.db.profile.channels.customs) do
        local channel_fields = {
            name = channel.name,
            type = "group",
            order = channel.order,
            args = {
                header = {
                    name = channel.name,
                    type = "header",
                    order = 0
                },
                enable = {
                    name = L["options.channels.enable.name"],
                    desc = L["options.channels.enable.desc"](channel.name),
                    type = "toggle",
                    order = 1,
                    set = function(info, value) channel.enabled = value end,
                    get = function(info) return channel.enabled end
                },
                remove = {
                    name = L["options.channels.remove.name"],
                    type = "execute",
                    order = 2,
                    func = function(info) self:removeCustomChannel(channel) end,
                    confirm = true
                },
                identity = {
                    name = L["options.channels.identity.name"],
                    desc = L["options.channels.identity.desc"](channel.name, self.db.profile.identity),
                    type = "input",
                    order = 3,
                    width = "full",
                    set = function(info, value) channel.identity = value end,
                    get = function(info) return channel.identity end,
                    multiline = false
                },
                preview_header = {
                    name = L["options.channels.preview_header"],
                    type = "header",
                    order = 4
                },
                preview = {
                    name = function(info) return self:PreviewMessage(channel) end,
                    type = "description",
                    order = 5,
                    fontSize = "medium"
                }
            }
        }
    
        options.args.custom_channels.args[key] = channel_fields
    end
end

function Identity2:addCommunity(info, clubId)
    local new_community = {
        enabled = false,
        type = "COMMUNITY",
        order = table.getn(self.db.profile.channels.communities) + 1,
        name = C_Club.GetClubInfo(clubId).name,
        clubId = clubId,
        streams = {}
    }
    
    for i, stream in pairs(C_Club.GetStreams(clubId)) do
        new_stream = {
            enabled = false,
            identity = "",
            type = "COMMUNITY_STREAM",
            order = i,
            name = stream.name,
            clubId = clubId,
            streamId = stream.streamId
        }
        
        new_community.streams[stream.streamId] = new_stream
    end
    
    self.db.profile.channels.communities[clubId] = new_community
    
    self:LoadCommunities()
    
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Identity2")
end

function Identity2:removeCommunity(community)
    self.db.profile.channels.communities[community.clubId] = nil
    
    self:LoadCommunities()
    
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Identity2")
end

function Identity2:LoadCommunities()
    local k, v, communities_list =  nil, nil, {}
        
    for k,v in pairs(C_Club.GetSubscribedClubs()) do
        if(self.db.profile.channels.communities[v.clubId]) then
            self.db.profile.channels.communities[v.clubId].name = v.name
            
            local i, s, streams = nil, nil, {}
            
            for i, s in pairs(C_Club.GetStreams(v.clubId)) do
                streams[s.streamId] = s
            
                if(self.db.profile.channels.communities[v.clubId].streams[s.streamId]) then
                    self.db.profile.channels.communities[v.clubId].streams[s.streamId].name = s.name
                else
                    self.db.profile.channels.communities[v.clubId].streams[s.streamId] = {
                        enabled = false,
                        identity = "",
                        type = "COMMUNITY_STREAM",
                        order = i,
                        name = s.name,
                        clubId = v.clubId,
                        streamId = s.streamId
                    }
                end
            end
        else
            communities_list[v.clubId] = v.name
        end
    end

    options.args.communities.args = {
        add = {
            name = L["options.communities.add.name"],
            desc = L["options.communities.add.desc"],
            type = "select",
            order = -1,
            set = "addCommunity",
            values = communities_list
        }
    }
    
    local clubId, community
    
    for clubId, community in pairs(self.db.profile.channels.communities) do
        local community_fields = {
            name = community.name,
            type = "group",
            childGroups = "tab",
            order = community.order,
            args = {
                enable = {
                    name = L["options.community.enable.name"],
                    desc = L["options.community.enable.desc"](community.name),
                    type = "toggle",
                    order = 0,
                    set = function(info, value) community.enabled = value end,
                    get = function(info) return community.enabled end
                },
                remove = {
                    name = L["options.communities.remove.name"],
                    type = "execute",
                    order = 1,
                    func = function(info) self:removeCommunity(community) end,
                    confirm = true
                }
            }
        }
        
        if(table.getn(community.streams) > 0 and C_Club.GetClubInfo(clubId) ~= nil) then
            local i, s, streams = nil, nil, {}
            
            for i, s in pairs(C_Club.GetStreams(clubId)) do
                streams[s.streamId] = s
            end
        
            local streamId, stream
            
            for streamId, stream in pairs(community.streams) do
                if(streams[streamId]) then
                    stream_fields = {
                        name = stream.name,
                        type = "group",
                        order = stream.order,
                        args = {
                            header = {
                                name = stream.name,
                                type = "header",
                                order = 0
                            },
                            enable = {
                                name = L["options.channels.enable.name"],
                                desc = L["options.channels.enable.desc"](stream.name),
                                type = "toggle",
                                order = 1,
                                set = function(info, value) stream.enabled = value end,
                                get = function(info) return stream.enabled end
                            },
                            identity = {
                                name = L["options.channels.identity.name"],
                                desc = L["options.channels.identity.desc"](stream.name, self.db.profile.identity),
                                type = "input",
                                order = 3,
                                width = "full",
                                set = function(info, value) stream.identity = value end,
                                get = function(info) return stream.identity end,
                                multiline = false
                            },
                            preview_header = {
                                name = L["options.channels.preview_header"],
                                type = "header",
                                order = 4
                            },
                            preview = {
                                name = function(info) return self:PreviewMessage(stream) end,
                                type = "description",
                                order = 5,
                                fontSize = "medium"
                            }
                        }
                    }
                    
                    community_fields.args["" .. stream.streamId] = stream_fields
                end
            end
        else
            community_fields.args.no_streams_header = {
                name = "",
                type = "header",
                order = 2
            }
            
            community_fields.args.no_streams_message = {
                name = L["options.communities.no_streams"],
                type = "description",
                order = 3,
                fontSize = "medium"
            }
        end
        
        options.args.communities.args["" .. clubId] = community_fields
    end
end

-----
-- CHAT MESSAGE HANDLING
-----

--Has fun in special days
function Identity2:FunTime(identity, mode)
    local value
    
    if (mode == "PRANK") then
        value = GetRandomArgument(
            identity .. L["fun.prank.jenkins"],
            L["fun.prank.guldan_start"] .. identity,
            identity .. L["fun.prank.guldan_end"],
            identity .. L["fun.prank.the_cute"](),
            L["fun.prank.magnificient"] .. identity,
            L["fun.prank.the_third"](identity),
            L["fun.prank.prince"] .. identity,
            L["fun.prank.master_roshi"],
            L["fun.prank.whats_the_name_of_the_song"],
            L["fun.prank.404"],
            L["fun.prank.univere_life_everything_else"],
            L["fun.prank.rhonin_best_quote"](),
            L["fun.prank.not"] .. identity,
            L["fun.prank.plated"](identity),
            L["fun.prank.item_quality"](identity),
            L["fun.prank.size"] .. identity
        )
    elseif (mode == "HOHOHO") then
        value = GetRandomArgument(
            L["fun.hohoho.santa"](identity),
            L["fun.hohoho.claus"](identity),
            L["fun.hohoho.red_nose"](identity)
        )
    end
    
    return value
end

--Checks if its a day to have fun
function Identity2:IsDayForFun()
    local havingFun = "NO"
    local dtime = date("*t")
    
    --checks if Fun mode is turned on and only replaces identity some % of the time so its not spammy
    if (self.db.profile.fun) then
        if (dtime["day"] == 1 and dtime["month"] == 4  and math.random(100) >= 85) then
            havingFun = "PRANK"
        elseif (dtime["day"] == 25 and dtime["month"] == 12  and math.random(100) == 100) then
            havingFun = "HOHOHO"
        end
    end
    
    return havingFun
end

function Identity2:AlterMessage(msg, channel)
    if(channel) then
        if(channel.enabled) then
            local identity = channel.identity
            
            if(identity == "") then
                identity = self.db.profile.identity
            end
            
            local function LocalReplaceToken(token)
                local value = ""
                
                if (token == "s") then
                    local havingFun = self:IsDayForFun()
            
                    if(havingFun == "NO") then
                        value = identity
                    else
                        value = self:FunTime(identity, havingFun)
                    end
                elseif (token == "l") then
                    value = UnitLevel("player")
                elseif (token == "z") then
                    value = GetZoneText()
                elseif (token == "r") then
                    value = GetRealmName()
                elseif (token == "g") then
                    value = GetGuildInfo("player")
                else
                    return nil
                end

                return value
            end
            
            return string.gsub(self.db.profile.format, "%%(%w+)", LocalReplaceToken) .. " " .. msg
        else
            return msg
        end
    else
        return msg
    end
end

function Identity2:SendChatMessage(msg, system, language, channel, targetPlayer)
    if(self.db.profile.enabled) then
        if(system == "CHANNEL") then
            local id, name, instanceID = GetChannelName(channel)
            
            local s, e, clubId, streamId = string.find(name, "Community:(%d+):(%d+)")
            
            if (clubId and streamId) then
                if(self.db.profile.channels.communities[tonumber(clubId)]) then
                    if(self.db.profile.channels.communities[tonumber(clubId)].enabled) then
                        if(self.db.profile.channels.communities[tonumber(clubId)].streams[tonumber(streamId)]) then
                            msg = self:AlterMessage(msg, self.db.profile.channels.communities[tonumber(clubId)].streams[tonumber(streamId)])
                        end
                    end
                end
            else
                if(self.db.profile.channels.customs[name]) then
                    msg = self:AlterMessage(msg, self.db.profile.channels.customs[name])
                end
            end
        else
            msg = self:AlterMessage(msg, self.db.profile.channels[system])
        end
    end
    
    -- call the original function through the self.hooks table
    self.hooks["SendChatMessage"](msg, system, language, channel, targetPlayer)
end

Identity2:RawHook("SendChatMessage", true)

function Identity2:C_Club_SendMessage(clubId, streamId, message)
    if(self.db.profile.enabled) then
        if(self.db.profile.channels.communities[clubId]) then
            if(self.db.profile.channels.communities[clubId].enabled) then
                if(self.db.profile.channels.communities[clubId].streams[streamId]) then
                    message = self:AlterMessage(message, self.db.profile.channels.communities[clubId].streams[streamId])
                end
            end
        end
    end
    
    -- call the original function through the self.hooks table
    self.hooks[C_Club]["SendMessage"](clubId, streamId, message)
end

Identity2:RawHook(C_Club, "SendMessage", "C_Club_SendMessage", true)

function Identity2:findCustomChannel(name)
    local function GetChannelListAsTable(...)
        local t = {}
        local vs = {...}
        for i, v in pairs(vs) do
            if(i%2 > 0) then
                t[v] = vs[i+1]
            end
        end
        
        return t
    end
    
    local r = "CHANNEL"

    for id, channel in pairs(GetChannelListAsTable(GetChannelList())) do
        if(name == channel) then
            r = r .. id
        end
    end
    
    return r
end

function Identity2:PreviewMessage(channel)
    local identity = channel.identity
    
    if(identity == "") then
        identity = self.db.profile.identity
    end
    
    local function LocalReplaceToken(token)
        local value = ""
        
        if (token == "s") then
            value = identity
        elseif (token == "l") then
            value = UnitLevel("player")
        elseif (token == "z") then
            value = GetZoneText()
        elseif (token == "r") then
            value = GetRealmName()
        elseif (token == "g") then
            value = GetGuildInfo("player")
        else
            return nil
        end

        return value
    end
    
    local name = ""
    
    if(self.db.profile.enabled and channel.enabled) then
        name = string.gsub(self.db.profile.format, "%%(%w+)", LocalReplaceToken) .. " "
    end
    
    local timeString = ""
        
    if(channel.type ~= "COMMUNITY_STREAM") then
        local showTimestamps = GetCVar("showTimestamps")
        
        if (showTimestamps ~= "none") then
            timeString = date(showTimestamps)
        end 
    end
    
    local playerName = UnitName("player")
    
    local chatInfo = nil
    local getFormat = nil
    
    if(channel.type == "CUSTOM") then
        getFormat = CHAT_CHANNEL_GET
    elseif(channel.type == "COMMUNITY_STREAM") then
        local streamType = C_Club.GetStreamInfo(channel.clubId, channel.streamId).streamType
        
        if(streamType == Enum.ClubStreamType.Guild) then
            getFormat = CHAT_GUILD_GET
        elseif(streamType == Enum.ClubStreamType.Officer) then
            getFormat = CHAT_OFFICER_GET
        else
            getFormat = CHAT_CHANNEL_GET
        end
    else
        getFormat = _G["CHAT_".. channel.type .."_GET"]
    end
    
    if(not getFormat) then
        getFormat = CHAT_SAY_GET
        chatInfo = ChatTypeInfo["SAY"]
    else
        if(channel.type == "CUSTOM") then
            chatInfo = ChatTypeInfo[self:findCustomChannel(channel.name)]
        elseif(channel.type == "COMMUNITY_STREAM") then
            local streamType = C_Club.GetStreamInfo(channel.clubId, channel.streamId).streamType
        
            if(streamType == Enum.ClubStreamType.Guild) then
                chatInfo = ChatTypeInfo["GUILD"]
            elseif(streamType == Enum.ClubStreamType.Officer) then
                chatInfo = ChatTypeInfo["OFFICER"]
            else
                chatInfo = ChatTypeInfo[self:findCustomChannel("Community:"..channel.clubId..":"..channel.streamId)]
            end
        else
            chatInfo = ChatTypeInfo[channel.type]
        end
    end
    
    local chatColor = string.format("%02X", chatInfo.r * 255) .. string.format("%02X", chatInfo.g * 255) .. string.format("%02X", chatInfo.b * 255)    
    
    if(chatInfo.colorNameByClass) then
        local classDisplayName, class, classID = UnitClass("player")
        
        local classInfo = C_CreatureInfo.GetClassInfo(classID);
		
        local classColor = ""
        
        if classInfo then
			classColor = RAID_CLASS_COLORS[classInfo.classFile].colorStr;
		else
            classColor = "FF" .. classColors[classID]
        end
        
        playerName = "|c" .. classColor .. playerName .. "|cFF" ..chatColor
    end
    
    playerName = string.gsub(getFormat, "%%s", "[" .. playerName .. "]")
    
    return "|cFF" ..chatColor .. timeString .. playerName .. name .. L["options.channels.preview.message"]
end
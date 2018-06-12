Identity2 = LibStub("AceAddon-3.0"):NewAddon("Identity2", "AceConsole-3.0", "AceHook-3.0")

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
            customs = {}
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
    
    self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
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
            }
        }
    }
    
    self:LoadDefaultChannels()
    
    self:LoadCustomChannels()
    
    self:ConfigTableChange()
    
    self:RegisterChatCommand("id", "SlashProcessor")
    self:RegisterChatCommand("identity", "SlashProcessor")

    function self:SlashProcessor(input)
        InterfaceOptionsFrame_OpenToCategory(generalOptions)
		InterfaceOptionsFrame_OpenToCategory(profilesOptions)
        InterfaceOptionsFrame_OpenToCategory(generalOptions)
    end
    
    if(self.db.global.version ~= defaults.global.version) then
        self.db.global.version = defaults.global.version
        self:Print(L["initialization.updated"](self.db.global.version))
    else
        self:Print(L["initialization.loaded"](self.db.global.version))
    end
end

function Identity2:ConfigTableChange()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Identity2", options)
    generalOptions = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Identity2", "Identity 2")
    
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Identity2 Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    profilesOptions = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Identity2 Profiles", L["profiles.name"], "Identity 2")
end

function Identity2:RefreshConfig()
    self:LoadDefaultChannels()
    self:LoadCustomChannels()
    
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Identity2")
end

function Identity2:LoadDefaultChannels()
    options.args.default_channels.args = {}
    
    for key, channel in pairs(self.db.profile.channels) do
        if(key ~= "customs") then
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
end

function Identity2:SendChatMessage(msg, system, language, channel, targetPlayer)
    if(self.db.profile.enabled) then
        if(system == "CHANNEL") then
            local id, name, instanceID = GetChannelName(channel)
            
            if(self.db.profile.channels.customs[name]) then
                msg = self:AlterMessage(msg, self.db.profile.channels.customs[name])
            end
        else
            msg = self:AlterMessage(msg, self.db.profile.channels[system])
        end
    end
    
    -- call the original function through the self.hooks table
    self.hooks["SendChatMessage"](msg, system, language, channel, targetPlayer)
end

Identity2:RawHook("SendChatMessage", true)

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
        name = string.gsub(self.db.profile.format, "%%(%w+)", LocalReplaceToken)
    end
    
    local showTimestamps = GetCVar("showTimestamps")
    
    local timeString = ""
    
    if (showTimestamps ~= "none") then
        timeString = date(showTimestamps)
    end 
    
    local playerName = UnitName("player")
    
    local chatInfo = nil
    local getFormat = nil
    
    if(channel.type == "CUSTOM") then
        getFormat = _G["CHAT_CHANNEL_GET"]
    else
        getFormat = _G["CHAT_".. channel.type .."_GET"]
    end
    
    if(not getFormat) then
        getFormat = CHAT_SAY_GET
        chatInfo = ChatTypeInfo["SAY"]
    else
        if(channel.type == "CUSTOM") then
            chatInfo = ChatTypeInfo[self:findCustomChannel(channel.name)]
        else
            chatInfo = ChatTypeInfo[channel.type]
        end
    end
    
    local chatColor = string.format("%02X", chatInfo.r * 255) .. string.format("%02X", chatInfo.g * 255) .. string.format("%02X", chatInfo.b * 255)    
    
    if(chatInfo.colorNameByClass) then
        local classDisplayName, class, classID = UnitClass("player")
        
        playerName = "|cFF" .. classColors[classID] .. playerName .. "|cFF" ..chatColor
    end
    
    playerName = string.gsub(getFormat, "%%s", "[" .. playerName .. "]")
    
    return "|cFF" ..chatColor .. timeString .. playerName .. name .. " " .. L["options.channels.preview.message"]
end
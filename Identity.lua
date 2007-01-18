-- Identity Addon
-- Heavily modified by Kjallstrom, Mellonea, Kirin Tor
-- Created by Ferusnox, Heaven and Earth, Cenarion Circle
-- Inspired by Thelma Incognito Addon

-- Sets the current Identity version
local Identity_VERSION = "2.0-20003";

-- Stores the unmodified chat message
local Identity_OrginalSendChatMessage;

-- Called when Identity is loaded at UI loadtime
function Identity_OnLoad()
    -- Prepare to read saved variables
    this:RegisterEvent("VARIABLES_LOADED");

    -- Register slash commands
    SlashCmdList["IDENTITY"] = Identity_Cmd;
    SLASH_IDENTITY1 = "/identity";
    SLASH_IDENTITY2 = "/id";
end

-- Handle the variable load event
function Identity_OnEvent()
    if (event == "VARIABLES_LOADED") then
        -- Check if this is the first time Identity has been loaded
        if (not IdentitySettings) then
	    -- Set the defaults
	    Identity_InitSettings();
        end

        -- Indicate that Identity is done loading
        DEFAULT_CHAT_FRAME:AddMessage("Identity " .. Identity_VERSION .. " loaded.", 0.4, 0.4, 1.0);

        -- Intercept chat events
        --Identity_OrginalSendChatMessage = SendChatMessage;
        --SendChatMessage = Identity_SendChatMessage;
    end
end

-- Create a fresh, default Identity configuration
function Identity_InitSettings()
    IdentitySettings = {};
    IdentitySettings.Enabled = true;
    IdentitySettings.Format = "[%s]";
    IdentitySettings.MainName = "";
    IdentitySettings.NickName = "";
    IdentitySettings.DisplayZone = false;
    IdentitySettings.Channels = {};
    IdentitySettings.Channels.Guild = false;
    IdentitySettings.Channels.Officer = false;
    IdentitySettings.Channels.Raid = false;
    IdentitySettings.Channels.Party = false;
    IdentitySettings.Channels.Tell = false;
    IdentitySettings.Channels.C01 = false;
    IdentitySettings.Channels.C02 = false;
    IdentitySettings.Channels.C03 = false;
    IdentitySettings.Channels.C04 = false;
    IdentitySettings.Channels.C05 = false;
    IdentitySettings.Channels.C06 = false;
    IdentitySettings.Channels.C07 = false;
    IdentitySettings.Channels.C08 = false;
    IdentitySettings.Channels.C09 = false;
    IdentitySettings.Channels.C10 = false;
end

function Identity_SendChatMessage(msg, system, language, channel)

-- DEFAULT_CHAT_FRAME:AddMessage(system..channel, 0.4, 0.4, 1.0);

-- IF THEN ADD NAME

    if (system == "GUILD" or system == "OFFICER" or system == "WHISPER" or system == "RAID" or system == "PARTY" or system == "CHANNEL") then

        if (system == "GUILD" or system == "OFFICER") then
            if (IdentityEnabled == "false" or MainName == "" or UnitName("player") == MainName) then
            Identity_OrginalSendChatMessage(msg,system,language,channel)
            else
            Identity_OrginalSendChatMessage("("..MainName.."): "..msg,system,language,channel)
            end
        end

        if (system == "CHANNEL") then
            if (IdentityEnabled == "false") then
            Identity_OrginalSendChatMessage(msg,system,language,channel)
            else
                if (MainName == "" or UnitName("player") == MainName or ChanEnabled == "false") then
                    if (ZoneEnabled == "false") then
                    Identity_OrginalSendChatMessage(msg,system,language,channel)
                    else
                    local zonetext = GetZoneText();
                    Identity_OrginalSendChatMessage("["..zonetext.."]: "..msg,system,language,channel)
                    end
                else
                    if (ZoneEnabled == "false") then
                    Identity_OrginalSendChatMessage("("..MainName.."): "..msg,system,language,channel)
                    else
                    local zonetext = GetZoneText();
                    Identity_OrginalSendChatMessage("("..MainName..") ["..zonetext.."]: "..msg,system,language,channel)
                    end
                end
            end 
        end
        
        if (system == "WHISPER") then
            if (IdentityEnabled == "false" or MainName == "" or UnitName("player") == MainName or TellEnabled == "false") then
            Identity_OrginalSendChatMessage(msg,system,language,channel)
            else
            Identity_OrginalSendChatMessage("(Main: "..MainName.."): "..msg,system,language,channel)
            end
        end

        if (system == "PARTY") then
            if (IdentityEnabled == "false" or NickName == "") then
            Identity_OrginalSendChatMessage(msg,system,language,channel)
            else
            Identity_OrginalSendChatMessage("("..NickName.."): "..msg,system,language,channel)
            end
        end

        if (system == "RAID") then
            if (IdentityEnabled == "false" or NickName == "") then
            Identity_OrginalSendChatMessage(msg,system,language,channel)
            else
            Identity_OrginalSendChatMessage("("..NickName.."): "..msg,system,language,channel)
            end
        end
    else
    Identity_OrginalSendChatMessage(msg,system,language,channel)
    end
end

-- Handle Identity commands
function Identity_Cmd(msg)
    -- Extract the command and arguments from the message
    local Cmd, Options = Identity_ParseCmd(msg);

    -- Check which command was specified, if any
    if (Cmd == "") then
        Identity_PrintConfig();
    end
end

-- Split a command into two parts: the name of the command, and any
-- command arguments.
function Identity_ParseCmd(msg)
    return "", "";
end

-- Dumps the current Identity configuration
function Identity_PrintConfig()
    -- Print general Identity information
    DEFAULT_CHAT_FRAME:AddMessage("Identity " .. Identity_VERSION .. " configuration:", 0.4, 0.4, 1.0);
    if (IdentitySettings.Enabled) then
        DEFAULT_CHAT_FRAME:AddMessage("  Enabled", 0.4, 1.0, 0.4);
    else
        DEFAULT_CHAT_FRAME:AddMessage("  Disabled", 1.0, 0.4, 0.4);        
    end

    -- Check if the Main Identity is configured
    if (IdentitySettings.MainName ~= "") then
        -- Get an example of the current Identity
        local main = Identity_GenerateMainName();

        -- Get the list of channels enabled for the current Identity
        local mainChannels = Identity_GetMainChannels();

        -- Display the main Identity
        DEFAULT_CHAT_FRAME:AddMessage("  Main name: " .. main, 0.4, 0.4, 1.0);
        if (mainChannels ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("    " .. mainChannels, 0.4, 1.0, 0.4);
        else
            DEFAULT_CHAT_FRAME:AddMessage("    All channels disabled", 1.0, 0.4, 0.4);
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("  No main name", 1.0, 0.4, 0.4);
    end

    -- Check if the Nick Identity is configured
    if (IdentitySettings.NickName ~= "") then
        -- Get an example of the current Identity
        local nick = Identity_GenerateNickName();

        -- Get the list of channels enabled for the current Identity
        local nickChannels = Identity_GetNickChannels();

        -- Display the nick Identity
        DEFAULT_CHAT_FRAME:AddMessage("  Nick name: " .. nick, 0.4, 0.4, 1.0);
        if (nickChannels ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("    " .. nickChannels, 0.4, 1.0, 0.4);
        else
            DEFAULT_CHAT_FRAME:AddMessage("    All channels disabled", 1.0, 0.4, 0.4);
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("  No nickname", 1.0, 0.4, 0.4);
    end
end

-- Formats the main name for prepending to a chat message
function Identity_GenerateMainName()
    local name = IdentitySettings.MainName;

    -- Check if we need to append zone information as well
    if (IdentitySettings.DisplayZone) then
        name = name .. ", " .. GetZoneText();
    end

    return string.format(IdentitySettings.Format, name);
end

-- Formats the nickname for prepending to a chat message
function Identity_GenerateNickName()
    local name = IdentitySettings.NickName;

    -- Check if we need to append zone information as well
    if (IdentitySettings.DisplayZone) then
        name = name .. ", " .. GetZoneText();
    end

    return string.format(IdentitySettings.Format, name);
end

-- Concatenates of list of enabled channels for the main character's name
function Identity_GetMainChannels()
    local channels = "";
    if (IdentitySettings.Channels.Guild) then
        channels = channels .. "Guild ";
    end
    if (IdentitySettings.Channels.Officer) then
        channels = channels .. "Officer ";
    end
    if (IdentitySettings.Channels.Tell) then
        channels = channels .. "Whisper ";
    end
    if (IdentitySettings.Channels.C01) then
        channels = channels .. "1 ";
    end
    if (IdentitySettings.Channels.C02) then
        channels = channels .. "2 ";
    end
    if (IdentitySettings.Channels.C03) then
        channels = channels .. "3 ";
    end
    if (IdentitySettings.Channels.C04) then
        channels = channels .. "4 ";
    end
    if (IdentitySettings.Channels.C05) then
        channels = channels .. "5 ";
    end
    if (IdentitySettings.Channels.C06) then
        channels = channels .. "6 ";
    end
    if (IdentitySettings.Channels.C07) then
        channels = channels .. "7 ";
    end
    if (IdentitySettings.Channels.C08) then
        channels = channels .. "8 ";
    end
    if (IdentitySettings.Channels.C09) then
        channels = channels .. "9 ";
    end
    if (IdentitySettings.Channels.C10) then
        channels = channels .. "10 ";
    end
    return channels;
end

-- Concatenates of list of enabled channels for the character's nickname
function Identity_GetNickChannels()
    local channels = "";
    if (IdentitySettings.Channels.Raid) then
        channels = channels .. "Raid ";
    end
    if (IdentitySettings.Channels.Party) then
        channels = channels .. "Party ";
    end
    return channels;
end

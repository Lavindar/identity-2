-----
-- Identity Addon
-- Heavily modified by Kjallstrom, Mellonea, Kirin Tor
-- Created by Ferusnox, Heaven and Earth, Cenarion Circle
-- Inspired by Thelma Incognito Addon
-----

-----
-- INITIALIZATION
-----

-- Sets the current Identity version
local Identity_VERSION = "2.0-20003";

-- Stores the unmodified chat message
local Identity_OriginalSendChatMessage;

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

        -- Intercept chat events
        Identity_OriginalSendChatMessage = SendChatMessage;
        SendChatMessage = Identity_SendChatMessage;

        -- Indicate that Identity is done loading
        DEFAULT_CHAT_FRAME:AddMessage("Identity " .. Identity_VERSION .. " loaded", 0.4, 0.4, 1.0);
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

-----
-- CHAT MESSAGE HANDLING
-----

function Identity_SendChatMessage(msg, system, language, channel)
    -- Check if Identity is enabled
    if (IdentitySettings.Enabled) then
        -- Check if the main Identity is configured
        if (IdentitySettings.MainName ~= "") then
            -- Get the current Identity
            local main = Identity_GenerateMainName();

            -- Modify the message
            local newmsg = main .. " " .. msg;

            -- Guild channel
            if (IdentitySettings.Channels.Guild and system == "GUILD") then
                Identity_OriginalSendChatMessage(newmsg, system, language, channel);
                return;
            end

            -- Officer channel
            if (IdentitySettings.Channels.Officer and system == "OFFICER") then
                Identity_OriginalSendChatMessage(newmsg, system, language, channel);
                return;
            end

            -- Whispers
            if (IdentitySettings.Channels.Tell and system == "WHISPER") then
                Identity_OriginalSendChatMessage(newmsg, system, language, channel);
                return;
            end

            -- Numbered channels
            if (system == "CHANNEL") then
                local chanID = string.format("C%02d", channel);
                if (IdentitySettings.Channels[chanID]) then
                    Identity_OriginalSendChatMessage(newmsg, system, language, channel);
                    return;
                end
            end
       end

        -- Check if the nickname Identity is configured
        if (IdentitySettings.NickName ~= "") then
            -- Get the current Identity
            local nick = Identity_GenerateNickName();

            -- Modify the message
            local newmsg = nick .. " " .. msg;

            -- Raid channel
            if (IdentitySettings.Channels.Guild and system == "RAID") then
                Identity_OriginalSendChatMessage(newmsg, system, language, channel);
                return;
            end

            -- Party channel
            if (IdentitySettings.Channels.Officer and system == "PARTY") then
                Identity_OriginalSendChatMessage(newmsg, system, language, channel);
                return;
            end
       end
    end

    -- Pass the message through unchanged
    Identity_OriginalSendChatMessage(msg, system, language, channel);
end

-----
-- COMMAND HANDLING
-----

-- Handle Identity commands
function Identity_Cmd(msg)
    -- Extract the command and arguments from the message
    local cmd, options = Identity_ParseCmd(msg);

    -- Check which command was specified, if any
    if (cmd == "" or cmd == "config") then
        Identity_PrintConfig();
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid Identity command '" .. msg .. "'", 1.0, 0.4, 0.4);
    end
end

-- Split a command into two parts: the name of the command, and any
-- command arguments.
function Identity_ParseCmd(msg)
    -- Ignore null messages
    if (msg) then
        -- Split the command and its arguments
        local s, e, cmd = string.find(msg, "(%S+)");
        if (s) then
            -- Command plus any options
            return cmd, string.sub(msg, e + 2);
        else
            -- All whitespace?
            return "";
        end
    end
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

    -- Check if the main Identity is configured
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

    -- Check if the nickname Identity is configured
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
    for i = 1, 10 do
        local chanID = string.format("C%02d", i);
        if (IdentitySettings.Channels[chanID]) then
            channels = channels .. i .. " ";
        end
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

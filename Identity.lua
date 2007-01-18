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
            if (IdentitySettings.Channels.Raid and (system == "RAID" or system == "BATTLEGROUND")) then
                Identity_OriginalSendChatMessage(newmsg, system, language, channel);
                return;
            end

            -- Party channel
            if (IdentitySettings.Channels.Party and system == "PARTY") then
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
    elseif (cmd == "help") then
        Identity_PrintHelp(options);
    elseif (cmd == "on") then
        Identity_Enable(true);
    elseif (cmd == "off") then
        Identity_Enable(false);
    elseif (cmd == "main") then
        IdentitySettings.MainName = Identity_CheckName(IdentitySettings.MainName, options);
    elseif (cmd == "nick") then
        IdentitySettings.NickName = Identity_CheckName(IdentitySettings.NickName, options);
    elseif (cmd == "enable") then
        Identity_EnableChannels(options, true);
    elseif (cmd == "disable") then
        Identity_EnableChannels(options, false);
    elseif (cmd == "zone") then
        Identity_SetZoneDisplay(options);
    elseif (cmd == "format") then
        Identity_SetFormat(options);
    elseif (cmd == "reset") then
        DEFAULT_CHAT_FRAME:AddMessage("Identity configuration cleared", 0.4, 0.4, 1.0);
        Identity_InitSettings();
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
    DEFAULT_CHAT_FRAME:AddMessage("----", 1.0, 1.0, 1.0);
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
        DEFAULT_CHAT_FRAME:AddMessage("  Nickname: " .. nick, 0.4, 0.4, 1.0);
        if (nickChannels ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("    " .. nickChannels, 0.4, 1.0, 0.4);
        else
            DEFAULT_CHAT_FRAME:AddMessage("    All channels disabled", 1.0, 0.4, 0.4);
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("  No nickname", 1.0, 0.4, 0.4);
    end
    DEFAULT_CHAT_FRAME:AddMessage("----", 1.0, 1.0, 1.0);
end

-- Displays the help information
function Identity_PrintHelp(cmdName)
    DEFAULT_CHAT_FRAME:AddMessage("----", 1.0, 1.0, 1.0);
    DEFAULT_CHAT_FRAME:AddMessage("Help!", 0.4, 0.4, 1.0);
    DEFAULT_CHAT_FRAME:AddMessage("----", 1.0, 1.0, 1.0);
end

-- Enables/disables Identity
function Identity_Enable(enable)
    if (enable) then
        DEFAULT_CHAT_FRAME:AddMessage("Identity enabled", 0.4, 1.0, 0.4);
    else
        DEFAULT_CHAT_FRAME:AddMessage("Identity disabled", 1.0, 0.4, 0.4);
    end
    IdentitySettings.Enabled = enable;
end

-- Checks the specified name
function Identity_CheckName(old, new)
    -- Check that a new name specified
    if (not new) then
        -- Keep the existing name
        return old;
    elseif (new == "") then
        -- Clear the name
        DEFAULT_CHAT_FRAME:AddMessage("Cleared name", 0.4, 0.4, 1.0);
        return new;
    else
        -- Update the name
        DEFAULT_CHAT_FRAME:AddMessage("Name changed from '" .. old .. "' to '" .. new .. "'", 0.4, 0.4, 1.0);
        return new;
    end
end

-- Enables/disables a list of channels
function Identity_EnableChannels(channels, enable)
    -- Check that a channel list was specified
    if (not channels or channels == "") then
        DEFAULT_CHAT_FRAME:AddMessage("No Identity channels specified", 1.0, 0.4, 0.4);
        return;
    end;

    -- Iterate over the list of channels
    for channel in string.gmatch(channels, "%w+") do
        Identity_EnableChannel(channel, enable);
    end
end

-- Enables/disables the specified channel
function Identity_EnableChannel(channel, enable)
    -- Update the channel setting and get the channel's canonical name
    local channelName = "";
    if (channel == "g" or channel == "guild") then
        channelName = "Guild";
        IdentitySettings.Channels.Guild = enable;
    elseif (channel == "o" or channel == "officer") then
        channelName = "Officer";
        IdentitySettings.Channels.Officer = enable;
    elseif (channel == "r" or channel == "raid") then
        channelName = "Raid";
        IdentitySettings.Channels.Raid = enable;
    elseif (channel == "p" or channel == "party") then
        channelName = "Party";
        IdentitySettings.Channels.Party = enable;
    elseif (channel == "w" or channel == "whisper" or channel == "t" or channel == "tell") then
        channelName = "Whispers";
        IdentitySettings.Channels.Tell = enable;
    elseif (string.match(channel, "%d+")) then
        channelName = channel;
        local chanID = string.format("C%02d", channel + 0);
        IdentitySettings.Channels[chanID] = enable;
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid Identity channel '" .. channel .. "'", 1.0, 0.4, 0.4);
    end

    -- Print the channel's new state
    if (enable) then
        DEFAULT_CHAT_FRAME:AddMessage("Channel " .. channelName .. " enabled", 0.4, 1.0, 0.4);
    else
        DEFAULT_CHAT_FRAME:AddMessage("Channel " .. channelName .. " disabled", 1.0, 0.4, 0.4);
    end
end

-- Enables/disables zone display
function Identity_SetZoneDisplay(options)
    if (options == "on") then
        DEFAULT_CHAT_FRAME:AddMessage("Zone display enabled", 0.4, 0.4, 1.0);
        IdentitySettings.DisplayZone = true;
    elseif (options == "off") then
        DEFAULT_CHAT_FRAME:AddMessage("Zone display disabled", 0.4, 0.4, 1.0);
        IdentitySettings.DisplayZone = false;
    elseif (options == "") then
        if (IdentitySettings.DisplayZone) then
            DEFAULT_CHAT_FRAME:AddMessage("Zone display disabled", 0.4, 0.4, 1.0);
        else
            DEFAULT_CHAT_FRAME:AddMessage("Zone display enabled", 0.4, 0.4, 1.0);
        end
        IdentitySettings.DisplayZone = not IdentitySettings.DisplayZone;
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid Identity zone argument '" .. options .. "'", 1.0, 0.4, 0.4);
    end
end

-- Sets the format string to be used for name display
function Identity_SetFormat(options)
    -- Check for no argument
    if (not options or options == "") then
        IdentitySettings.Format = "[%s]";
        DEFAULT_CHAT_FRAME:AddMessage("Reset format to '" .. IdentitySettings.Format .. "'", 0.4, 0.4, 1.0);
        return;
    end

    -- Check for the %s replacement token
    if (string.match(options, "%%s")) then
        -- Escape any other percent sign, to avoid contaminating the format string
        options = string.gsub(options, "%%([^s])", "%%%%%1");
        DEFAULT_CHAT_FRAME:AddMessage("Changed format to '" .. options .. "'", 0.4, 0.4, 1.0);
        IdentitySettings.Format = options;
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid Identity format string '" .. options .. "'", 1.0, 0.4, 0.4);
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

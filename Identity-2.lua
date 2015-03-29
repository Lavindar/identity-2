-----
-- Identity Addon
-- Currently maintained by Lavindar, of The Queue, Nesingwary-US
-- Heavily modified by Kjallstrom, Mellonea, Kirin Tor
-- Created by Ferusnox, Heaven and Earth, Cenarion Circle
-- Inspired by Thelma Incognito Addon
-----

-----
-- INITIALIZATION
-----

-- Sets the current Identity version
local Identity_VERSION = "3.0.0";

-- Stores the unmodified chat message
local Identity_OriginalSendChatMessage;

local IdentitySettingsDefault ={
    ["Enabled"] = true,
    ["Format"] = "[%s]",
    ["MainName"] = "",
    ["NickName"] = "",
    ["DisplayZone"] = false,
    ["DisplayMessage"] = "normal",
    ["Debug"] = false,

    ["Channels"] = {
        ["Guild"] = false,
        ["Officer"] = false,
        ["Raid"] = false,
        ["Party"] = false,
        ["Tell"] = false,
        ["C01"] = false,
        ["C02"] = false,
        ["C03"] = false,
        ["C04"] = false,
        ["C05"] = false,
        ["C06"] = false,
        ["C07"] = false,
        ["C08"] = false,
        ["C09"] = false,
        ["C10"] = false
    },

    ["Version"] = Identity_VERSION
}

-- Called when Identity is loaded at UI loadtime
function Identity_OnLoad(frame)
    -- Prepare to read saved variables
    frame:RegisterEvent("VARIABLES_LOADED");

    -- Register slash commands
    SlashCmdList["IDENTITY"] = Identity_Cmd;

    SLASH_IDENTITY1 = "/identity";
    SLASH_IDENTITY2 = "/id";
end

-- Handle the variable load event
function Identity_OnEvent(frame, event)
    if (event == "VARIABLES_LOADED") then
        local updated = false;
        local news = "";

        -- Check if this is the first time Identity has been loaded, if not the first time, check if it was updated;
        if (not IdentitySettings) then
            -- Set the defaults
            Identity_InitSettings();
        else
            -- Check if it is an updated version
            if (IdentitySettings.Version ~= Identity_VERSION) then
                -- Check for new configurations
                IdentitySettings = Identity_CheckSettings(IdentitySettingsDefault, IdentitySettings);

                updated = true;

                news = "Identity Tip: Check the new format command. Type: /id help format";
            end
        end

        -- Intercept chat events
        Identity_OriginalSendChatMessage = SendChatMessage;
        SendChatMessage = Identity_SendChatMessage;

        -- Indicate that Identity is done loading, if configured to do so
        if (updated and (IdentitySettings.DisplayMessage == "update" or IdentitySettings.DisplayMessage == "normal")) then
            DEFAULT_CHAT_FRAME:AddMessage("Identity updated to version " .. Identity_VERSION, 0.4, 0.4, 1.0);
            if (news ~= "") then
                DEFAULT_CHAT_FRAME:AddMessage(news, 0.4, 0.8, 1.0);
            end
        elseif (IdentitySettings.DisplayMessage == "normal") then
            DEFAULT_CHAT_FRAME:AddMessage("Identity " .. Identity_VERSION .. " loaded", 0.4, 0.4, 1.0);
        end
    end
end

-- Create a fresh, default Identity configuration
function Identity_InitSettings()
    IdentitySettings = IdentitySettingsDefault;
end

-- Iterate over the values of the default setting, copy their value from the existing setting if it exists if not use the default value
-- as seen in: http://wow.gamepedia.com/index.php?title=Talk:Creating_defaults&oldid=2142802
function Identity_CheckSettings(newDB, oldDB)
    local k, v;

    for k, v in pairs(newDB) do
        if (type(v) == "table") then
            if (oldDB and oldDB[k] ~= nil) then
                newDB[k] = Identity_CheckSettings(v, oldDB[k]);
            end
        elseif (oldDB and oldDB[k] ~= nil and k ~= "Version") then
            newDB[k] = oldDB[k];
        end
    end
    
    return newDB;
end

-----
-- DEBUG FUNCTIONS
-----

-- Debug
function Identity_Debug(msg)
    if (IdentitySettings.Debug) then
        DEFAULT_CHAT_FRAME:AddMessage("Identity Debug: " .. msg, 0.8, 0.8, 0.8)
    end
end

-----
-- CHAT MESSAGE HANDLING
-----

-- Formats the main name for prepending to a chat message
function Identity_GenerateMainName()
    local name = IdentitySettings.MainName;

    -- Check if we need to append zone information as well
    if (IdentitySettings.DisplayZone) then
        name = name .. ", " .. GetZoneText();
    end

    return name;
end

-- Formats the nickname for prepending to a chat message
function Identity_GenerateNickName()
    local name = IdentitySettings.NickName;

    -- Check if we need to append zone information as well
    if (IdentitySettings.DisplayZone) then
        name = name .. ", " .. GetZoneText();
    end

    return name;
end

function Identity_SendChatMessage(msg, system, language, channel)
    -- Check if Identity is enabled
    if (IdentitySettings.Enabled) then
        local identity = "";
        
        -- Replaces the tokens for they values
        local function Identity_ReplaceToken(token)
            if (IdentitySettings.Debug) then Identity_Debug("entered Identity_ReplaceToken"); end
            if (IdentitySettings.Debug) then Identity_Debug("token: " .. token); end

            local value = "";

            if (token == "s") then
                value = identity;
            elseif (token == "l") then
                value = UnitLevel("player");
            elseif (token == "z") then
                value = GetZoneText();
            elseif (token == "r") then
                value = GetRealmName();
            elseif (token == "g") then
                value = GetGuildInfo("player");
            else
                if (IdentitySettings.Debug) then Identity_Debug("value: " .. "nil"); end

                return nil;
            end

            if (IdentitySettings.Debug) then Identity_Debug("value: " .. value); end

            return value;
        end
        
        if (IdentitySettings.Debug) then Identity_Debug("entered Identity_SendChatMessage"); end

        if (IdentitySettings.Debug) then Identity_Debug("system " .. system); end

        if (system == "RAID" or system == "BATTLEGROUND" or system == "PARTY") then
            -- Check if the nickname Identity is configured
            if (IdentitySettings.NickName ~= "") then
                identity = Identity_GenerateNickName();

                -- Get the current Identity
                local nick = string.gsub(IdentitySettings.Format, "%%(%w+)", Identity_ReplaceToken);

                if (IdentitySettings.Debug) then Identity_Debug("nick: " .. nick); end

                -- Modify the message
                local newmsg = nick .. " " .. msg;

                if (IdentitySettings.Debug) then Identity_Debug("newmsg: " .. newmsg); end

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
        else
            -- Check if the main Identity is configured
            if (IdentitySettings.MainName ~= "") then
                identity = Identity_GenerateMainName();
                
                -- Get the current Identity
                local main = string.gsub(IdentitySettings.Format, "%%(%w+)", Identity_ReplaceToken);

                if (IdentitySettings.Debug) then Identity_Debug("main: " .. main); end

                -- Modify the message
                local newmsg = main .. " " .. msg;

                if (IdentitySettings.Debug) then Identity_Debug("newmsg: " .. newmsg); end

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
    if (IdentitySettings.Debug) then Identity_Debug("entered Identity_Cmd"); end

    -- Extract the command and arguments from the message
    local cmd, options = Identity_ParseCmd(msg);

    if (IdentitySettings.Debug) then Identity_Debug("Identity_Cmd command: " .. cmd); end
    if (IdentitySettings.Debug) then
        if (options) then
            Identity_Debug("Identity_Cmd options: " .. options);
        else
            Identity_Debug("Identity_Cmd options: nil");
        end
    end

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
    elseif (cmd == "message") then
        Identity_SetMessageDisplay(options);
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
    if (IdentitySettings.Debug) then Identity_Debug("entered Identity_ParseCmd"); end

    -- Ignore null messages
    if (msg) then
        if (IdentitySettings.Debug) then Identity_Debug("msg: " .. msg); end
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

    --Print the message setting current value
    DEFAULT_CHAT_FRAME:AddMessage("  Identity loaded message: ", 0.4, 0.4, 1.0);
    if (IdentitySettings.DisplayMessage == "normal") then
        DEFAULT_CHAT_FRAME:AddMessage("  Enabled", 0.4, 1.0, 0.4);
    elseif (IdentitySettings.DisplayMessage == "update") then
        DEFAULT_CHAT_FRAME:AddMessage("  Only on new version", 0.4, 0.4, 1.0);
    elseif (IdentitySettings.DisplayMessage == "silent") then
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

    if (IdentitySettings.Debug) then
        DEFAULT_CHAT_FRAME:AddMessage("Debug enabled", 0.4, 0.4, 1.0);
    end

    DEFAULT_CHAT_FRAME:AddMessage("----", 1.0, 1.0, 1.0);
end

-- Displays the help information
function Identity_PrintHelp(cmdName)
    DEFAULT_CHAT_FRAME:AddMessage("----", 1.0, 1.0, 1.0);
    DEFAULT_CHAT_FRAME:AddMessage("Identity " .. Identity_VERSION .. " help:", 0.4, 0.4, 1.0);
    DEFAULT_CHAT_FRAME:AddMessage("See Readme.txt for more detailed information", 0.4, 0.4, 1.0);
    DEFAULT_CHAT_FRAME:AddMessage(" ", 0.4, 0.4, 1.0);

    if (cmdName == "") then
        DEFAULT_CHAT_FRAME:AddMessage("/id - Displays the current configuration", 0.4, 0.4, 1.0);
    end

    if (cmdName == "" or cmdName == "config") then
        DEFAULT_CHAT_FRAME:AddMessage("/id config - Displays the current configuration", 0.4, 0.4, 1.0);
    end

    if (cmdName == "" or cmdName == "help") then
        DEFAULT_CHAT_FRAME:AddMessage("/id help - Displays the complete help text", 0.4, 0.4, 1.0);
        DEFAULT_CHAT_FRAME:AddMessage("/id help <command> - Displays the detailed help text for the command", 0.4, 0.4, 1.0);
    end

    if (cmdName == "" or cmdName == "on" or cmdName == "off") then
        DEFAULT_CHAT_FRAME:AddMessage("/id on - Enables Identity", 0.4, 0.4, 1.0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Turns Identity on, using the currently stored settings. Configured", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("labels will be sent. Identity is turned on by default.", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage(" ", 0.4, 0.4, 1.0);
        end

        DEFAULT_CHAT_FRAME:AddMessage("/id off - Disables Identity", 0.4, 0.4, 1.0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Turns Identity off, but all settings are preserved. No labels will be", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("sent. Identity is turned on by default.", 0.4, 0.4, 1.0);
        end
    end

    if (cmdName == "" or cmdName == "main") then
        DEFAULT_CHAT_FRAME:AddMessage("/id main <name> - Sets the name of your main", 0.4, 0.4, 1.0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Sets the main character's Identity. This is the name used for all", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("enabled channels except Raid and Party. If no main name is specified,", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("the name is cleared.", 0.4, 0.4, 1.0);
        end
    end

    if (cmdName == "" or cmdName == "nick") then
        DEFAULT_CHAT_FRAME:AddMessage("/id nick <name> - Sets your group short name", 0.4, 0.4, 1.0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Sets the nickname Identity. This is the name used in Raid,", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("Battleground, and Party, if enabled. If no nickname is specified, the", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("name is cleared.", 0.4, 0.4, 1.0);
        end
    end

    if (cmdName == "" or cmdName == "enable" or cmdName == "disable") then
        DEFAULT_CHAT_FRAME:AddMessage("/id enable <channels> - These channels will print your Identity", 0.4, 0.4, 1.0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Enables Identity for the specified space-separated channels.", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("  Valid channel identifiers:", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("    guild, g", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("    officer, o", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("    raid, r", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("    party, p", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("    whisper, w, tell, t", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("    1-10", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage(" ", 0.4, 0.4, 1.0);
        end

        DEFAULT_CHAT_FRAME:AddMessage("/id disable <channels> - These channels will not print your Identity", 0.4, 0.4, 1.0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Disables Identity for the specified space-separated channels.", 0.4, 0.4, 1.0);
        end
    end

    if (cmdName == "" or cmdName == "message") then
        DEFAULT_CHAT_FRAME:AddMessage("/id message normal|update|silent - Toggles the exibition of the loaded message", 0.4, 0.4, 1,0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Sets how Identity loaded message displays. If no option is specified", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("it change to silent if normal or update, and to normal if silent.", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("The default value is normal.", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("  normal: Identity loaded message display every time the addon is loaded", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("  update: Identity only shows the message when a new version is loaded", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("  silent: Identity never shows the loaded message", 0.4, 0.4, 1.0);
        end
    end

    if (cmdName == "" or cmdName == "format") then
        DEFAULT_CHAT_FRAME:AddMessage("/id format <string> - Sets the string used to display your Identity.", 0.4, 0.4, 1.0);

        if (cmdName ~= "") then
            DEFAULT_CHAT_FRAME:AddMessage("Sets the string used to display your Identity. The default is [%s].", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("The default can be restored by specifying no format string.", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("Valid tokens for use in the format: ", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("   %s -> Will be replaced by the appropriate identity", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("   %z -> Will be replaced by the name of the current zone", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("   %l -> Will be replaced by the character level", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("   %g -> Will be replaced by the character guild", 0.4, 0.4, 1.0);
            DEFAULT_CHAT_FRAME:AddMessage("   %r -> Will be replaced by the realm name.", 0.4, 0.4, 1.0);
        end
    end

    if (cmdName == "zone") then
        DEFAULT_CHAT_FRAME:AddMessage("/id zone on|off - Toggles your location in your Identity", 0.4, 0.4, 1.0);
        DEFAULT_CHAT_FRAME:AddMessage("Sets whether zone information should be added to your Identity.", 0.4, 0.4, 1.0);
        DEFAULT_CHAT_FRAME:AddMessage("Attention: the zone command is obsolete use %z in the format instead.", 1.0, 0.4, 0.4);
    end

    if (cmdName == "" or cmdName == "reset") then
        DEFAULT_CHAT_FRAME:AddMessage("/id reset - Clears your Identity settings", 0.4, 0.4, 1.0);
    end

    DEFAULT_CHAT_FRAME:AddMessage(" ", 0.4, 0.4, 1.0);
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
    if (IdentitySettings.Debug) then Identity_Debug("entered Identity_CheckName"); end
    if (IdentitySettings.Debug) then Identity_Debug("old name: " .. old); end
    if (IdentitySettings.Debug) then Identity_Debug("new name: " .. new); end

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
    if (IdentitySettings.Debug) then Identity_Debug("entered Identity_EnableChannel"); end
    if (IdentitySettings.Debug) then Identity_Debug("channel: " .. channel); end
    if (IdentitySettings.Debug) then Identity_Debug("enable: " .. enable); end

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

    DEFAULT_CHAT_FRAME:AddMessage("Attention: the zone command is obsolete use %z in the format instead.", 1.0, 0.4, 0.4);
end

-- Enables/disables message display
function Identity_SetMessageDisplay(options)
    if (options == "normal") then
        DEFAULT_CHAT_FRAME:AddMessage("Loaded message display enabled", 0.4, 0.4, 1.0);
    elseif (options == "silent") then
        DEFAULT_CHAT_FRAME:AddMessage("Loaded message display disabled", 0.4, 0.4, 1.0);
    elseif (options == "update") then
        DEFAULT_CHAT_FRAME:AddMessage("Loaded message display enabled only on version change", 0.4, 0.4, 1.0);
    elseif (options == "") then
        if (IdentitySettings.DisplayMessage == "silent") then
            DEFAULT_CHAT_FRAME:AddMessage("Loaded message display enabled", 0.4, 0.4, 1.0);
            IdentitySettings.DisplayMessage = "normal";
        else
            DEFAULT_CHAT_FRAME:AddMessage("Loaded message display disabled", 0.4, 0.4, 1.0);
            IdentitySettings.DisplayMessage = "silent";
        end

        return;
    else
        DEFAULT_CHAT_FRAME:AddMessage("Invalid Identity message argument '" .. options .. "'", 1.0, 0.4, 0.4);
        return;
    end

    IdentitySettings.DisplayMessage = options;
end

-- Sets the format string to be used for name display
function Identity_SetFormat(options)
    -- Check for no argument
    if (not options or options == "") then
        IdentitySettings.Format = "[%s]";
        DEFAULT_CHAT_FRAME:AddMessage("Reset format to '" .. IdentitySettings.Format .. "'", 0.4, 0.4, 1.0);
        return;
    end

    DEFAULT_CHAT_FRAME:AddMessage("Changed format to '" .. options .. "'", 0.4, 0.4, 1.0);

    IdentitySettings.Format = options;
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

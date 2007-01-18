-- Identity Addon
-- Created by Ferusnox, Heaven and Earth, Cenarion Circle
-- Inspired by Thelma Incognito Addon

local Identity_VERSION = "11200-1";
local Identity_OrginalSendChatMessage;

-- LETS BEGIN

function Identity_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");

-- ADDON COMMANDS

	SlashCmdList["IDENTITY"] = Identity_Cmd;
	SLASH_IDENTITY1 = "/Identity";
	SLASH_IDENTITY2 = "/ID";

	SlashCmdList["IDMAIN"] = IDMain_Cmd;
	SLASH_IDMAIN1 = "/IDMain";

	SlashCmdList["IDNICK"] = IDNick_Cmd;
	SLASH_IDNICK1 = "/IDNick";

	SlashCmdList["IDRESET"] = IDReset_Cmd;
	SLASH_IDRESET1 = "/IDReset";
	SLASH_IDRESET2 = "/IDClear";

	SlashCmdList["IDTELL"] = IDTell_Cmd;
	SLASH_IDTELL1 = "/IDTell";
	SLASH_IDTELL2 = "/IDWhisper";
	
	SlashCmdList["IDCHAN"] = IDChan_Cmd;
	SLASH_IDCHAN1 = "/IDChannel";
	SLASH_IDCHAN2 = "/IDChan";

	SlashCmdList["IDZONE"] = IDZone_Cmd;
	SLASH_IDZONE1 = "/IDZone";
end

-- CREATE VARIABLES ON FIRST LOAD

function Identity_OnEvent()
	if (event == "VARIABLES_LOADED") then
		if (IdentityEnabled == nil) then
		IdentityEnabled = "true";
		end

		if (MainName == nil) then
		MainName = "";
		end

		if (NickName == nil) then
		NickName = "";
		end

		if (TellEnabled == nil) then
		TellEnabled = "false";
		end
		
		if (ChanEnabled == nil) then
		ChanEnabled = "false";
        end

		if (ZoneEnabled == nil) then
		ZoneEnabled = "false";
		end
	Identity_Init();
	end
end

-- INDICATE THAT ADDON IS LOADED
function Identity_Init()
	DEFAULT_CHAT_FRAME:AddMessage("Identity "..Identity_VERSION.." loaded." ,0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/Identity help" ,0.4, 0.4, 1.0);

-- HOOK TO CHAT EVENTS
	Identity_OrginalSendChatMessage = SendChatMessage;
	SendChatMessage = Identity_SendChatMessage;
end

function Identity_SendChatMessage(msg,system,language,channel)

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


-- COMMAND FUNCTIONS

function Identity_Cmd(msg)

	if(string.len(msg) == 0 or msg == "help") then
	DEFAULT_CHAT_FRAME:AddMessage("Identity ver "..Identity_VERSION.." - Main Name: "..MainName.." - Enabled: "..IdentityEnabled, 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("=== Identity Help ===", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/Identity or /ID - ID Help", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/Identity on / off - turns all ID features on or off", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/IDReset - resets ID Names", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/IDMain <Main name> - sets your mains name", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/IDNick <Nickname> sets your nick name for party & raids", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/IDTell on / off - turns ID on & off in tell/whisper chats", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/IDChan or /IDChannel on / off uses MainName in Channels 1 - 10", 0.4, 0.4, 1.0);
	DEFAULT_CHAT_FRAME:AddMessage("/IDZone on / off prints your Zone in Channels 1 - 10", 0.4, 0.4, 1.0);
	return
	end

	if (msg == "off") then
	IdentityEnabled = "false"
	DEFAULT_CHAT_FRAME:AddMessage("Identity Disabled", 0.4, 0.4, 1.0);
	return
	end

	if (msg == "on") then
	IdentityEnabled = "true"DEFAULT_CHAT_FRAME:AddMessage("Identity Enabled", 0.4, 0.4, 1.0);
	return
	end
end

function IDMain_Cmd(msg)
	MainName = msg;
	DEFAULT_CHAT_FRAME:AddMessage("ID Main Name set to: "..MainName, 0.4, 0.4, 1.0);
return
end

function IDNick_Cmd(msg)
	NickName = msg;
	DEFAULT_CHAT_FRAME:AddMessage("ID Nickname set to: "..NickName, 0.4, 0.4, 1.0);
return
end

function IDChan_Cmd(msg)
	if (msg == "on" ) then
	ChanEnabled = "true"
	DEFAULT_CHAT_FRAME:AddMessage("ID Main Name in Channels Enabled", 0.4, 0.4, 1.0);
	return
	end

	if (msg == "off" ) then
	ChanEnabled = "false"
	DEFAULT_CHAT_FRAME:AddMessage("ID Main Name in Channels Disabled", 0.4, 0.4, 1.0);
	return
	end
end

function IDZone_Cmd(msg)
	if (msg == "on" ) then
	ZoneEnabled = "true"
	DEFAULT_CHAT_FRAME:AddMessage("ID Zone Print Enabled", 0.4, 0.4, 1.0);
	return
	end

	if (msg == "off" ) then
	ZoneEnabled = "false"
	DEFAULT_CHAT_FRAME:AddMessage("ID Zone Print Disabled", 0.4, 0.4, 1.0);
	return
	end
end

function IDTell_Cmd(msg)
	if (msg == "on" ) then
	TellEnabled = "true"
	DEFAULT_CHAT_FRAME:AddMessage("ID Tell Enabled", 0.4, 0.4, 1.0);
	return
	end

	if (msg == "off" ) then
	TellEnabled = "false"
	DEFAULT_CHAT_FRAME:AddMessage("ID Tell Disabled", 0.4, 0.4, 1.0);
	return
	end
end

function IDReset_Cmd()
	IdentityEnabled = "true";
	MainName = "";
	NickName = "";
	TellEnabled = "false";
	ChanEnabled = "false";
	ZoneEnabled = "false";
	DEFAULT_CHAT_FRAME:AddMessage("Identity reset for this toon.  Identity enabled.", 0.4, 0.4, 1.0);
return
end
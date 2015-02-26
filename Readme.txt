Identity-2 by Lavindar(alacre@outlook.com)
http://wow.curse.com/downloads/wow-addons/details/identity-2.aspx
Guild: of The Queue 
Server: Nesingwary-US

----
Current version: 2.3-60100
----

This addon allows you to specify your main character's name, an identity format
string, and which channels will have your identity tag prepended. It also allows
you to specify a nickname for use in Raid and Party channels.

All options are configured on a per-character basis.

----

Slash Commands:

/id <command> [<options>]
/identity <command> [<options>]

help [<command>]
Displays the help text of the specified command. If no command is
specified, it display the help text of all commands

config
Prints the current Identity configuration. Default subcommand.

on
Turns Identity on, using the currently stored settings. Configured
labels will be sent. Identity is turned on by default.

off
Turns Identity off, but all settings are preserved. No labels will be
sent. Identity is turned on by default.

main [<name>]
Sets the main character's Identity. This is the name used for all
enabled channels except Raid and Party. If no main name is specified,
the name is cleared.

nick [<name>]
Sets the nickname Identity. This is the name used in Raid,
Battleground, and Party, if enabled. If no nickname is specified, the
name is cleared.

enable <channel> [...]
Enables Identity for the specified space-separated channels.
  Valid channel identifiers:
    guild, g
    officer, o
    raid, r
    party, p
    whisper, w, tell, t
    1-10

disable <channel> [...]
Disables Identity for the specified space-separated channels.

zone on|off
Sets whether zone information should be added to your Identity.

message normal|update|silent
Sets how Identity loaded message displays. If no option is specified
it change to silent if normal or update, and to normal if silent.
The default value is normal.
  normal: Identity loaded message display every time the addon is loaded
  update: Identity only shows the message when a new version is loaded
  silent: Identity never shows the loaded message

format [<format>]
Sets the string used to display your Identity. The default is [%s],
where %s is replaced by the current name information. The default can
be restored by specifying no format string. All format strings must
contain %s, which will be replaced by your Identity. Recommended for
advanced users only.

reset
Clears your character's Identity settings.

----

Known Issues

- Trying to use more than one %s in the format string, or trying to use
% characters on their own, might cause problems, depending on how many
are in the format string.
- Location and Name can't be set separately
- Slash commands are hard to use

----

Former author Kjallstrom (ultranurd@gmail.com)
Guild: Mellonea
Server: Kirin Tor

----

Original IDENTITY by Ferusnox
Guild: Heaven and Earth
Server: Cenarion Circle
"Just call me Nox"

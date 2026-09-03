# Installer

The installer requires [InnoSetup](https://jrsoftware.org/isdl.php) 6.7.1 or above.

The current installer is deliberately a user installer: it uses `PrivilegesRequired=lowest`
and installs for the current user. It is intended to work without UAC. There is no system/all-
users option in this installer; managed system deployments should use a separate administrative
deployment mechanism. Event Log source registration is optional and is not part of the normal
installation flow. During an NVM v1 migration, machine-level environment, PATH, uninstall, or
Event Log state is reported but not modified without administrator permission.

NVM for Windows manages Windows Node.js installations only. WSL is a separate Linux
environment; install and use nvm-sh inside WSL.

# Installer

The installer requires [InnoSetup](https://jrsoftware.org/isdl.php) 6.7.1 or above.

The default installation is user-local and uses `PrivilegesRequired=lowest`; it is intended
to work for a standard Windows user without UAC. Event Log source registration is optional
and is not part of the normal installation flow. During an NVM v1 migration, machine-level
environment, PATH, uninstall, or Event Log state is reported but not modified without
administrator permission.

NVM for Windows manages Windows Node.js installations only. WSL is a separate Linux
environment; install and use nvm-sh inside WSL.

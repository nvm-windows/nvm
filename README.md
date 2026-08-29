<a href="https://trendshift.io/repositories/4201" target="_blank"><img src="https://trendshift.io/api/badge/repositories/4201" alt="nvm-windows | Trendshift" style="width: 250px; height: 55px;" width="250" height="55"/></a>

> [!IMPORTANT]
> ### NVM for Windows Version 2 Release Candidate is now available!<br />
> NVM for Windows has been fully rewritten for modern workflows. Try the v2 release candidate and help us validate it before the final release. There are significant changes from v1, as listed below and in the [docs](https://docs.nvm-windows.com).

# <sub><img src="https://github.com/nvm-windows.png?s=50" width="32" align="bottom" /></sub> NVM for Windows

The <a href="https://docs.microsoft.com/en-us/windows/nodejs/setup-on-windows">Microsoft</a>/<a href="https://docs.npmjs.com/cli/v9/configuring-npm/install#windows-node-version-managers">npm</a>/<a href="https://cloud.google.com/nodejs/docs/setup#installing_nvm">Google</a> recommended Node.js version manager for millions of Windows developers.

<details>
<summary><b>NVM for Windows is not the same thing as nvm!</b> (expand for details)</summary>

_The original [nvm](https://github.com/nvm-sh/nvm) is a completely separate project for Mac/Linux only._ This project uses an entirely different philosophy and is not just a clone of nvm.
</details>

[![Download Latest Now](https://img.shields.io/badge/-Try%20v2%20RC-%2322A6F2)](https://github.com/nvm-windows/nvm/releases) [![Latest](https://img.shields.io/github/v/tag/nvm-windows/nvm?label=Latest%20Stable&style=social&x=1)](https://github.com/nvm-windows/nvm/releases) ![Downloads](https://img.shields.io/github/downloads/nvm-windows/nvm/total?label=Downloads&style=social) [![Twitter URL](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Ftwitter.com%2Fintent%2Ftweet%3Fhashtags%3Dnodejs%26original_referer%3Dhttp%253A%252F%252F127.0.0.1%253A91%252F%26text%3DNVM%2520for%2520Windows%2520v2%2520is%2520available%21%26tw_p%3Dtweetbutton%26url%3Dhttps%253A%252F%252Fnvm-windows.com)](https://twitter.com/intent/tweet?hashtags=nodejs&original_referer=http%3A%2F%2F127.0.0.1%3A91%2F&text=NVM%20for%20Windows%20v2%20is%20available.&tw_p=tweetbutton&url=https%3A%2F%2Fnvm-windows.com)

## Resources

- [Website](https://nvm-windows.com)
- [Documentation](https://docs.nvm-windows.com)
- [Announcements](https://github.com/orgs/nvm-windows/discussions/categories/announcements)

## Features

|Feature|Description|
|:-|:-|
|Compatibility<br/><br/><br/>|&bull; No mandatory administrator privileges.<br/>&bull; Shim mode - no symlinks, fast (written in Zig).<br/>&bull; Link mode - Zero-latency, junctions with symlink fallback.|
|Automation<br/><br/><br/>|&bull; Per-directory version switching (pinning).<br/>&bull; Auto-install missing versions.<br/>&bull; Auto-install default global modules.|
|Speed<br/><br/><br/><br/>|&bull; Parallel (multiple) simultaneous installations.<br/>&bull; Smaller download sources (7z).<br/>&bull; Native extraction.<br/>&bull; Caching.|
|Native&nbsp;Integrations<br/><br/><br/><br/>|&bull; Windows Apps<br/>&bull; Logging (Windows Event Viewer)<br/>&bull; Windows Registry<br/>&bull; Desktop Notification Center|
|Customization<br/><br/><br/>|&bull; User-defined aliases.<br/>&bull; User-defined default global modules.<br/>&bull; Configure local (air-gapped) downloads.|

### Certified Builds

Commercial **[Certified Builds](https://docs.nvm-windows.com/guide/builds/)** are coming in September 2026 for controlled environments. <a href="https://list.author.sh/subscription/form" target="_blank">Get notified</a>

|Feature|Description|
|:-|:-|
|Code-Signing<br/><br/>|&bull; Installers<br />&bull; Executables|
|Installers<br/><br/>|&bull; MSI/MST<br />&bull; Microsoft Intune|
|Advanced Logging ⭐<br/><br/><br/><br/>|&bull; Fully auditable<br />&bull; Structured<br />&bull; Dedicated Event Source<br />&bull; Native SIEM integration|
|Policy Enforcement ⭐<br/><br/><br/><br/><br/>|&bull; Active Directory/Entra integration<br/>&bull; Restrict Node.js versions/ranges (e.g. no EOL versions, LTS only, etc.)<br/>&bull; Control nvm-windows, Node/npm/npx settings<br/>&bull; Advanced proxy (IWA, WPAD/PAC) support<br />&bull; Private Node.js download mirror|
|Trust Artifacts ⭐<br/><br/><br/>|&bull; SBOM<br />&bull; SLSA Provenance<br />&bull; VEX Reports|

⭐ = Add-on package

## :pray: Thanks

Thanks to everyone who has submitted issues on and off Github, made suggestions, and generally helped make this a better project. Special thanks to

- [@vkbansal](https://github.com/vkbansal), who provided significant early feedback throughout the early releases.
- [@rainabba](https://github.com/rainabba) and [@sullivanpt](https://github.com/sullivanpt) for getting Node v4 support integrated.
- [@s-h-a-d-o-w](https://github.com/s-h-a-d-o-w) who resolved the longstanding space escaping issue in path names ([#355](https://github.com/nvm-windows/nvm/pull/355)).
- [ajyong](https://github.com/ajyong) who sponsored the code signing certificate in late 2021.

<br/>

![Contributors](https://contrib.rocks/image?repo=nvm-windows/nvm&max=100)

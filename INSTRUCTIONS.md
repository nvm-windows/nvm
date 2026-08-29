# Build Script Instructions

Run from the repository root:

```powershell
.\build\main.ps1
```

`.\build.ps1` forwards to the same script.

Default behavior:

- Builds for the current machine architecture when not specified.
- Builds components in sequence: cli, shims, sync.exe, Inno Setup.
- Unsigned. No SBOM / SLSA / ADMX / worker DLL compile.
- Sync worker DLLs are **not** built here (certified CDN).

Builds write executables to `.\bin` and the installer to `.\.dist`.

## Parameters

### -Architecture

Allowed: `amd64`, `arm64`. Omit to auto-detect.

```powershell
.\build\main.ps1 -Architecture amd64
```

### -Component

`All` (default), `Cli`, `Shims`, or `Sync`. Installer runs only for `All`.

### -SkipInstaller

Build binaries only (skip Inno Setup).

### -BinRoot

Override output directory (default `.\bin`).

## Exit Codes

- 0: success
- non-zero: first failed step (script stops)

## Output

Successful full build:

- `bin\nvm.exe`
- `bin\.shim\node.exe`
- `bin\utils\proxy.exe`, `reshim.exe`, `sync.exe`
- `.dist\nvm-<version>-<arch>-setup.exe`

## Troubleshooting

- Installer fails: confirm `cli/src/manifest.json` has `version`, `appUserModelId`, `appId`, and Inno Setup 6.7.1+ (`ISCC.exe`) is installed.
- Sync build fails on `enhanced/`: community script rewrites `sync/src/go.mod` for the stub `common/mirrorauth` during the build and restores it after. Do not commit a dirty `sync/src/go.mod`.
- CI: see [build/README.md](build/README.md).

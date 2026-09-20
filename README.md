# Garter Client

Portable client-side Minecraft modpack, managed with [packwiz](https://packwiz.infra.link/).
Performance, visual and quality-of-life mods. Safe on vanilla servers.

Carried forward across Minecraft versions rather than rebuilt each time.
`git log` is the record of what changed, when, and why.

## Current state

| | |
|---|---|
| Minecraft | 26.3 |
| Loader | Fabric 0.19.5 |
| Entries | 57 (mods, resource packs, shaders) |
| Current tag | `v1.2.0-mc26.3` |
| Java required | 25 or newer |

## Toolchain

| Tool | Version | Install |
|---|---|---|
| Go | 1.27+ | `winget install GoLang.Go` |
| git | 2.55+ | `winget install Git.Git` |
| packwiz | `v0.0.0-20260906154125-ef87d964f8cb` | `go install github.com/packwiz/packwiz@latest` |
| Prism Launcher | 11.x | `winget install PrismLauncher.PrismLauncher` |

packwiz has no tagged releases. Building from source pins a commit and verifies
module checksums, rather than pulling an unsigned CI artifact.

After `go install`, add `%USERPROFILE%\go\bin` to PATH. The Go MSI does not.

## Layout

    pack.toml         pack name, MC version, loader version
    index.toml        manifest, one hashed entry per file
    mods/             one .pw.toml per mod
    resourcepacks/    one .pw.toml per resource pack
    shaderpacks/      one .pw.toml per shaderpack
    scripts/          automation
    PENDING.md        quarantined entries and cross-entry constraints
    out/              exports and logs, gitignored

No jars or zips are committed. Every entry is metadata with a SHA-512 of the
exact file it resolves to.

## Setting up a new machine

1. Install the toolchain above. Reopen your shell after each install.
2. `git clone https://github.com/justin-garter/garter-client.git`
3. `cd garter-client`
4. `packwiz modrinth export -o "out\GarterClient.mrpack"`
5. Prism: Add Instance, Import, select that .mrpack
6. Edit, Settings, Memory. 16 GB system: 4096/6144. 32 GB+: 4096/8192.
7. Launch once to generate config, then sync settings from another machine or
   set them by hand.

Resource pack order and shaderpack selection are NOT in the pack. They live in
the instance. See `scripts\sync-instance-config.ps1`.

## Bumping to a new Minecraft version

    .\scripts\bump-version.ps1 -McVersion 26.4

Branches, migrates, updates every entry, and prints three lists: what ported,
what has no build yet, and what in PENDING.md is worth re-testing. It removes
nothing.

Then, by hand:

1. `packwiz remove <slug>` for anything with no build. Record it in PENDING.md.
2. Re-add anything from PENDING.md that now has a build.
3. Bump the version in pack.toml.
4. `packwiz refresh` and `packwiz modrinth export -o "out\GarterClient-<ver>.mrpack"`
5. Import into Prism as a NEW instance. Keep the old one until the new one works.
6. `.\scripts\sync-instance-config.ps1 -FromInstance <old> -ToInstance <new>`
7. Launch. Check the log (see below).
8. Merge to main, tag `vX.Y.Z-mcNN.N`, push.

Keep the previous version’s instance until the new one is verified.

## Adding or removing an entry

    packwiz modrinth add <slug> -y
    packwiz remove <slug>
    packwiz refresh

Commit with a message that says WHY, not just what. Six months from now the
reason is the only part that matters.

## After any change, read the log

The worst failures here do not crash. They render vanilla and look fine.

    $log = "$env:APPDATA\PrismLauncher\instances\<instance>\minecraft\logs\latest.log"
    Select-String -Path $log -Pattern "Failed to create shader|ShaderCompileException|Incompatible|Multiple overrides"

No output is the pass condition.

Two real examples from this pack:

- Chloride and Cubes Without Borders both overrode Sodium's `fullscreen_mode`.
  Hard crash at startup, one line of log named both mods.
- Distant Horizons silently disabled the shaderpack on 26.3. The game launched,
  loaded, and rendered. Only the log said anything.

## Constraints

`PENDING.md` has a Constraints section for couplings that pack.toml cannot
express. Currently: Distant Horizons on 26.3 only works with Complementary
Reimagined + Euphoria Patches. Every other shaderpack fails to compile its DH
programs and Iris falls back to vanilla without crashing.

Check that section before removing anything that looks redundant.

## Version history

| Tag | Minecraft | Notes |
|---|---|---|
| `v1.0.0-mc26.2` | 26.2 | Baseline, 73 entries |
| `v1.1.0-mc26.3` | 26.3 | Port. 40 updated, 15 quarantined. Shaders silently broken. |
| `v1.1.1-mc26.3` | 26.3 | DH removed, shaders working |
| `v1.2.0-mc26.3` | 26.3 | DH restored with shaderpack constraint documented |

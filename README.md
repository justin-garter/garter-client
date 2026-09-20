# SchmoeClient

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
| Current tag | `v1.2.1-mc26.3` |
| Java required | 25 or newer |

## Just want to play it

1. Install [Prism Launcher](https://prismlauncher.org/)
2. Download the latest `.mrpack` from [Releases](https://github.com/justin-garter/mc-client-modpack/releases)
3. Prism: Add Instance, Import, select that file
4. Settings, Memory: 4096 min, 6144 max (8192 if you have 32 GB)
5. Launch

Resource pack order and shaderpack selection ship with the pack. Nothing to
configure after import.

Do not change the shaderpack. See Constraints below.

## Layout

    pack.toml         pack name, MC version, loader version
    index.toml        manifest, one hashed entry per file
    mods/             one .pw.toml per mod
    resourcepacks/    one .pw.toml per resource pack
    shaderpacks/      one .pw.toml per shaderpack
    options.txt       shipped: resource pack order
    config/           shipped: iris.properties pins the shaderpack
    .packwizignore    keeps repo files out of players game folders
    scripts/          automation
    client-defaults/  source of truth for the shipped settings
    PENDING.md        quarantined entries and cross-entry constraints
    out/              exports and logs, gitignored

No jars or zips are committed. Every entry is metadata with a SHA-512 of the
exact file it resolves to.

`options.txt` and `config/` are indexed as plain files, so packwiz puts them in
the `.mrpack` under `overrides/` and Prism copies them into the game folder on
import. Anything listed in `.packwizignore` is excluded from that.

## Working on the pack

Needed only if you are editing the pack, not to play it.

| Tool | Version | Install |
|---|---|---|
| Go | 1.27+ | `winget install GoLang.Go` |
| git | 2.55+ | `winget install Git.Git` |
| packwiz | `v0.0.0-20260906154125-ef87d964f8cb` | `go install github.com/packwiz/packwiz@latest` |
| Prism Launcher | 11.x | `winget install PrismLauncher.PrismLauncher` |

packwiz has no tagged releases. Building from source pins a commit and verifies
module checksums, rather than pulling an unsigned CI artifact.

After `go install`, add `%USERPROFILE%\go\bin` to PATH. The Go MSI does not.

## Bumping to a new Minecraft version

    .\scripts\bump-version.ps1 -McVersion 26.4

Branches, migrates, updates every entry, and prints three lists: what ported,
what has no build yet, and what in PENDING.md is worth re-testing. It removes
nothing.

Then, by hand:

1. `packwiz remove <slug>` for anything with no build. Record it in PENDING.md.
2. Re-add anything from PENDING.md that now has a build.
3. Bump the version in pack.toml.
4. `packwiz refresh` and `packwiz modrinth export -o "out\SchmoeClient-<ver>.mrpack"`
5. Import into Prism as a NEW instance. Keep the old one until the new one works.
6. Launch. Check the log (see below).
7. Merge to main, tag `vX.Y.Z-mcNN.N`, push.
8. `gh release create <tag> "out\<file>.mrpack" --title "..." --notes "..."`

Keep the previous version instance until the new one is verified.

## Adding or removing an entry

    packwiz modrinth add <slug> -y
    packwiz remove <slug>
    packwiz refresh

Commit with a message that says WHY, not just what. Six months from now the
reason is the only part that matters.

## Scripts

| Script | Use |
|---|---|
| `bump-version.ps1` | migrate to a new Minecraft version and report |
| `sync-instance-config.ps1` | copy options and configs between two local instances |
| `apply-client-defaults.ps1` | push the shipped defaults into an existing instance without reimporting |

`apply-client-defaults.ps1` is rarely needed now that the defaults ship in the
pack. It exists for fixing an instance in place.

Write files that Minecraft parses with LF, not CRLF. A stray carriage return on
the `resourcePacks` line makes Minecraft discard it and silently reset to
defaults. Use `[System.IO.File]::WriteAllText`, not `Set-Content`.

## After any change, read the log

The worst failures here do not crash. They render vanilla and look fine.

    $log = "$env:APPDATA\PrismLauncher\instances\<instance>\minecraft\logs\latest.log"
    Select-String -Path $log -Pattern "Failed to create shader|ShaderCompileException|Incompatible|Multiple overrides"

No output is the pass condition.

Three real examples from this pack:

- Chloride and Cubes Without Borders both overrode Sodium `fullscreen_mode`.
  Hard crash at startup, one line of log named both mods.
- Distant Horizons silently disabled the shaderpack on 26.3. The game launched,
  loaded and rendered. Only the log said anything.
- A config script wrote CRLF into options.txt. Minecraft dropped the resource
  pack order without a word.

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
| `v1.2.1-mc26.3` | 26.3 | Client defaults ship in the pack, repo files excluded |
| `v1.2.2-mc26.3` | 26.3 | Ships the incompatible-pack acknowledgement so New Glowing Ores loads |
| `v1.3.0-mc26.3` | 26.3 | Pack renamed to SchmoeClient, repo renamed to mc-client-modpack |
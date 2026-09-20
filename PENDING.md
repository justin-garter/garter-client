# Pending re-add

Entries removed when migrating to a Minecraft version because no compatible
build existed yet. Re-add with `packwiz modrinth add <slug>` once they port.

`scripts\bump-version.ps1` prints these as re-test commands on every migration.

## Removed at 26.3 (2026-09-20)

| slug | project |
|---|---|
| zoomify | Zoomify |
| litematica | Litematica |
| malilib | MaLiLib (Litematica dependency) |
| inventory-profiles-next | Inventory Profiles Next |
| libipn | libIPN (IPN dependency) |
| betterf3 | BetterF3 |
| cubes-without-borders | Cubes Without Borders (borderless fullscreen) |
| krypton | Krypton |
| language-reload | Language Reload |
| cherished-worlds | Cherished Worlds |
| visuality | Visuality |
| spawn-animations | Spawn Animations |
| better-leaves | Motschens Better Leaves |
| bsl-shaders | BSL Shaders |
| solas-shader | Solas Shader |

## Never ported, dropped earlier

| slug | reason |
|---|---|
| modernfix | NeoForge only past 26.1.2, no Fabric build |
| modelfix | Model Gap Fix, never ported past 1.21.10 |
| borderless-mining | Abandoned 2023, superseded by cubes-without-borders |
| photon-shader | No 26.2 or 26.3 build |
| chloride | Duplicate Sodium fullscreen_mode override, crashes with cubes-without-borders |

# Constraints

Couplings between entries that are not expressed in pack.toml. Breaking one of
these does not crash the game, it silently degrades it. Re-verify after any
version bump.

## 26.3: Distant Horizons requires Complementary Reimagined + Euphoria Patches

With Distant Horizons installed on 26.3, Iris builds DH LOD shader programs from
the active shaderpack. Only one combination compiles.

| shaderpack | result |
|---|---|
| ComplementaryReimagined + EuphoriaPatches | compiles |
| ComplementaryReimagined (plain) | dh_water.fsh fails |
| ComplementaryUnbound + EuphoriaPatches | dh_terrain.fsh fails |
| ComplementaryUnbound (plain) | dh_terrain.fsh fails |
| Bliss | dh_terrain.fsh fails |

Error: `dh_terrain.fsh: 0(51) : error C0000: syntax error, unexpected = expecting ::`

Failure mode is silent. Iris logs `Failed to create shader rendering pipeline,
disabling shaders!`, prints one chat message at world load, then renders vanilla.
The game does not crash and looks normal at a glance.

To verify after any change:

    $log = "$env:APPDATA\PrismLauncher\instances\<instance>\minecraft\logs\latest.log"
    Select-String -Path $log -Pattern "Failed to create shader|ShaderCompileException"

No output means shaders are compiling.

Known unexplained: the first launch of a freshly imported instance failed with the
working combination and succeeded after config was synced from the previous version.
Every successful load also logs `Unexpected; somehow the Opaque + Translucent pass
ran with shaders on` from DH. Watch for artifacts at the LOD boundary.

## Requires a discrete GPU

Distant Horizons' shader programs only compile on the NVIDIA cards tested.
On a laptop running the integrated AMD GPU, every shaderpack fails with
`dh_terrain.fsh` / `dh_water.fsh` syntax errors at line 51 and Iris falls back
to vanilla rendering.

Windows forces the integrated GPU when a laptop is on battery. If shaders stop
working on a laptop, check the log for the render device before anything else:

    Select-String -Path "<instance>\minecraft\logs\latest.log" -Pattern "OpenGL Renderer"

Fix: plug in, and set Prism's javaw.exe to High performance under
Settings, System, Display, Graphics.

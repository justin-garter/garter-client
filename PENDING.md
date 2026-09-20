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

## Distant Horizons and shaders: NVIDIA driver dependent

Iris builds the DH shader programs from the active shaderpack. On some NVIDIA
drivers this fails and Iris silently disables the shaderpack.

| GPU | Driver | DH + shaders |
|---|---|---|
| RTX 5070 desktop | 610.88 | works |
| RTX 3060 laptop | 616.56 | fails |
| RTX 3060 laptop | 616.92, before reboot | fails |
| RTX 3060 laptop | 616.92, after reboot | works |

616.56 is the broken one. 616.92 fixes it, but the machine must be rebooted.
Before the reboot the log already reports the new version while the old driver
is still resident, so the version string alone does not prove the update took.

Failure looks like: dh_terrain.fsh or dh_water.fsh, `0(51) : error C0000: syntax
error, unexpected '=' expecting "::"`, sometimes with `undefined variable
irisInt_Fog`. Iris logs "Failed to create shader rendering pipeline, disabling
shaders!", prints one chat message at world load, then renders vanilla.

    Select-String -Path "<instance>\minecraft\logs\latest.log" -Pattern "Failed to create shader"

If a machine fails, update the NVIDIA driver and reboot before touching the pack.

Separately: on a laptop, Windows uses the integrated GPU on battery, which breaks
DH shaders for a different reason. Check "OpenGL Renderer" in the log first.
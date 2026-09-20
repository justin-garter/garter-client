# Pending re-add

Entries removed when migrating to a Minecraft version because no compatible
build existed yet. Re-add with `packwiz modrinth add <slug>` once they port.

Check them after any `packwiz migrate` by re-running this list.

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
| better-leaves | Motschen's Better Leaves |
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

## Removed for compatibility, not availability

| slug | reason |
|---|---|
| distanthorizons | 26.3: Iris'' DH compat shader `dh_terrain.fsh` fails to compile (`error C0000: syntax error, unexpected ''=''` at line 51). Iris falls back to vanilla rendering and silently disables the shaderpack. Also leaves world gen threads blocked on exit, triggering the client shutdown watchdog. Confirmed by removing the jar: shaders compile fine without it. Re-test after Iris or DH ship 26.3 fixes. |

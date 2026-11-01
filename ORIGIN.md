# Extraction provenance

Upstream: https://github.com/hyperswine/qos

Application revision: `7b5f9c122ada1fe429a865a0a48fdd59d2aa1e2f`.

Application inputs:

- `programs/dungeon.fpr`
- `programs/mods/dungeonrules.fpr`
- `tests/dungeon.fpr`

Local changes:

- Package the application in its own repository and retain its original behavior.
- Add Sol build/launch/test orchestration and isolated, ignored data directories.
- Resolve app-local imports within this repository and standard modules through installed toolchain homes.
- Build and run with the QOS Portable SDK's `qos build` / `qos run` (`qos.toml` v2, `kind = "app"`). The app-side platform files and the matching FP-RISC runtime are the SDK's private build inputs; no copy is vendored. (Earlier revisions vendored them under `support/` and packaged with a Sol ELF/QAR2 writer.)

Generated artifacts and test captures are not upstream source; reports identify the checks actually run.

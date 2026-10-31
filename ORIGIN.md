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
- Use QOS app-side ABI support pinned to installed SDK revision `f4d8ec22a90f6a11f62d15c340f3360a1ca4dbc3`.
- Read runtime C/header/context-switch files from the installed FP-RISC formula; do not copy a compiler checkout.
- Replace the former Make/Python packaging path with a checked Sol ELF/QAR2 implementation.

Generated artifacts and test captures are not upstream source; reports identify the checks actually run.

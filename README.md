# Dungeon

The original turn-based Dungeon crawler in a standalone 3D QOS Portable window, with its pure game rules extracted alongside the renderer.

## Install and run

Tested with Homebrew FP-RISC 0.12.0 and QOS Portable 0.2.0 on macOS ARM64.

```sh
brew install hyperswine/tap/fprisc hyperswine/tap/qos-portable
git clone https://github.com/hyperswine/dungeon.git
cd dungeon
sol project.sol build
sol project.sol run
```

Arrow keys or WASD move and face. Space interacts; 1–4 use inventory slots. R restarts, H shows help, P captures a frame and Q quits. The original built-in level, enemies, boulders, switches, doors/keys, portals and goal tree are retained.

## Test

![Game captured by the Sol test harness](evidence/game.png)

```sh
sol project.sol test
```

The extracted upstream pure-rule suite covers movement, treasure, equipment, switches, keys/doors, potion duration, combat, enemy behavior, portals, death and composite win conditions. The Sol harness rejects any FAIL output and also launches the real 3D game, captures title/play/movement frames and verifies clean shutdown.

Builds can take several minutes for the larger applications. Build/test commands have explicit deadlines and return a failure when a child process fails. Generated binaries, caches, data, keys and raw logs are excluded from Git.

## Build tools

All project orchestration and test scripts are **Sol**. There are no Makefiles, Python or Node scripts.

The game is compiled with the installed `fpr`, linked by LLVM Clang/lld, and run by the installed native `qosp-gl`. The Sol ELF64/QAR2 packager constructs the runtime export table, validates AArch64 relocation types, checks a second link displaced by 256 MiB, hashes the image/relocations, and writes the archive. It invokes no `qos.py`, Python, Make, objcopy or readelf. Only the small pinned QOS app-side C ABI bridge is vendored; compiler/runtime/standard-library files come from the installed packages.

The Homebrew `qos-portable` formula itself still declares Python for its SDK CLI, but this project does not execute that CLI. Native compilation still requires Clang/lld and the platform toolchain. Standard filesystem utilities and a shell are used for directory/FIFO creation and descriptor plumbing; macOS `sips` exports test PNGs.

## Source and license

Extracted from [hyperswine/qos](https://github.com/hyperswine/qos/tree/7b5f9c122ada1fe429a865a0a48fdd59d2aa1e2f) at `7b5f9c122ada1fe429a865a0a48fdd59d2aa1e2f`. See [ORIGIN.md](ORIGIN.md) for the source map and local changes, and [LICENSE](LICENSE) for the upstream MIT license. No existing application data, private credentials, deployed host configuration or original source checkout is required.

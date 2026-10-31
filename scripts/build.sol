C = use "common".
E = use "elf".
J = use "sol/lib/json".
P = use "sol/lib/proc".
string key value = C.need (J.text (C.need (J.get key value))).
build : unsafe Unit -> Unit .
build u =
  _ = C.setup Unit;
  sdk = C.qosHome Unit;
  home = C.fprHome Unit;
  llvm = C.package "llvm";
  lld = C.package "lld";
  prior = case Env.get "PATH" of Ok (EnvText text) -> text | other -> "/usr/bin:/bin";
  _ = C.need (Env.set "PATH" "{llvm}/bin:{lld}/bin:{prior}");
  _ = C.need (Env.set "FPR_HOME" "{sdk}/modules");
  _ = C.need (Env.set "FPR_PATH" "{sdk}/compiler:{sdk}/modules/programs");
  _ = C.need (Env.set "FPR_FOREIGN" "{sdk}/modules/core/foreign.fpr");
  meta = C.need (J.parse (readPath "{sdk}/sdk.json"));
  _ = C.check "requires the native macOS ARM64 QOS SDK" (string "architecture" meta == "aarch64" and string "os" meta == "darwin");
  _ = C.need (P.output (Proc.runNow (P.withTimeout 900000 (P.spec ["fpr","compile","--target=qa64","--prelude={sdk}/compiler/core/prelude.fpr","src/dungeon.fpr","build/app.s"]))));
  rev = Str.trim (readNow "build/app.s.abirev");
  _ = C.check "SDK/compiler ABI mismatch" (string "abi" meta == "22.{rev}");
  units = List.filter (fn s -> s != "") (Str.split 10 (readNow "build/app.s.units"));
  rt = "{home}/runtime";
  sources = ["support/qos/appside/entry.c","support/qos/appside/hal.c","support/qos/appside/support.c",
    "{rt}/runtime.c","{rt}/i32.c","{rt}/actors.c","{rt}/bits.c","{rt}/vec.c","{rt}/sstr.c","{rt}/mod.c","{rt}/buddy.c",
    "support/loader/qaimg.c","support/qos/portable/sha256.c","{home}/machine/unix/ctx_a64.S"];
  flags = ["{llvm}/bin/clang","--target=aarch64-none-elf","-fuse-ld=lld","-O2",
    "-ffreestanding","-nostdlib","-fno-stack-protector","-fno-asynchronous-unwind-tables",
    "-fno-pic","-ffixed-x18","-ffixed-x27","-ffixed-x28","-DFPR_POSIX","-DFPR_QOSAPP",
    "-DQOS_ARENA_BASE=0x10000000000ul","-DFPR_NHARTS=8","-DFPR_SLAB_SZ=262144","-DFPR_STACK_SZ=1048560",
    "-I{rt}","-Isupport/qos/appside","-Wl,-T,support/qos/appside/link-qosapp-a64.ld",
    "-Wl,--emit-relocs","-Wl,--defsym=_heap_start=_proc_image_end","-Wl,--defsym=_heap_end=_proc_image_end",
    "build/app.s"] + units + sources;
  _ = C.command (flags + ["-Wl,--defsym=QOS_SLOT_BASE=0","-Wl,--unresolved-symbols=ignore-all","-o","build/first.elf"]);
  _ = E.exports "build/first.elf" "build/exports.s";
  _ = C.command (flags + ["build/exports.s","-Wl,--defsym=QOS_SLOT_BASE=0","-o","build/app.elf"]);
  _ = C.command (flags + ["build/exports.s","-Wl,--defsym=QOS_SLOT_BASE=0x10000000","-o","build/moved.elf"]);
  _ = E.archive "dungeon" (string "abi" meta) "build/app.elf" "build/moved.elf" "build/dungeon.qa";
  # Restore the installed language home before launching Sol test scripts.
  _ = C.need (Env.set "FPR_HOME" home);
  _ = C.need (Env.set "FPR_PATH" home);
  _ = C.need (Env.unset "FPR_FOREIGN");
  Unit.

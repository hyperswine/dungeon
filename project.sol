#!/usr/bin/env sol
unsafe program.
C = use "scripts/common".
B = use "scripts/build".
> case args Unit of
    ["build"] -> B.build Unit
  | ["run"] ->
      _ = B.build Unit;
      sdk = C.qosHome Unit;
      root = C.need (IO.cwd Unit);
      _ = C.need (Env.set "FPR_DISK" "{root}/data/dungeon.disk");
      _ = C.need (Env.set "FPR_DISK_MB" "32");
      _ = C.need (Env.set "FPR_PORT" "0");
      _ = C.live ["{sdk}/runtime/qosp-gl","--yes","build/dungeon.qa"];
      Unit
  | ["test"] -> _ = B.build Unit; print (C.command ["sol","tests/check.sol"])
  | other -> print "Usage: sol project.sol build | run | test".

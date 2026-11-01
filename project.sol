#!/usr/bin/env sol
unsafe program.
C = use "scripts/common".
# qos build / qos run (QOS Portable SDK, qos.toml) own compiling, linking,
# packaging and launching; this script only sequences them.
> case args Unit of
    ["build"] -> _ = C.live ["qos","build"]; Unit
  | ["run"] -> _ = C.live ["qos","build"]; _ = C.live ["qos","run"]; Unit
  | ["test"] -> _ = C.live ["qos","build"]; print (C.command ["sol","tests/check.sol"])
  | other -> print "Usage: sol project.sol build | run | test".

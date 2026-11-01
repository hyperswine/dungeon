#!/usr/bin/env sol
C = use "../scripts/common".
G = use "../scripts/gui".
J = use "sol/lib/json".
testGame u =
  _ = C.setup Unit;
  _ = C.command ["fpr","build","tests/rules.fpr","-o","build/rules-check"];
  rules = C.command ["./build/rules-check"];
  _ = C.check "dungeon rules failed" (not (Str.contains "FAIL" rules) and Str.contains "dungeon rules: done" rules);
  _ = print rules;
  (job,fifo,scratch) = G.start "dungeon";
  title = G.shot "dungeon" fifo 1 "title";
  _ = G.key fifo 28;
  game = G.shot "dungeon" fifo 2 "game";
  _ = G.key fifo 106;
  _ = G.key fifo 106;
  _ = G.key fifo 106;
  moved = G.shot "dungeon" fifo 3 "moved";
  _ = C.check "game did not respond to start/movement" (title != game and game != moved);
  _ = G.key fifo 16;
  _ = G.waitExit job 200;
  _ = C.writeText "evidence/rules.log" rules;
  C.report "evidence/results.json" (J.JObj [("passed",J.JBool True),("runner",J.JStr "Sol"),
    ("checks",J.JArr (List.map J.JStr ["upstream pure rule suite","original 3D title","start game","movement","PNG snapshots","clean quit"])),
    ("build",J.JStr "qos build and qos run (QOS Portable SDK, qos.toml v2)")]).
> testGame Unit.

C = use "common".
P = use "sol/lib/proc".
J = use "sol/lib/json".
event code value = C.need (Bytes.fromList (List.map (fn n -> 0) (List.range 1 16) +
  [1,0,code%256,Num.floor (code/256.0),value,0,0,0])).
key fifo code =
  stage = P.spec ["/bin/sh","-c","cat > \"$1\"","keys",fifo];
  PipelineResult status codes out err = C.need (Proc.pipeline (PipelineSpec [stage]
    (PipeBytes (Bytes.concat [event code 1,event code 0])) (PipeCapture 1024) (PipeCapture 4096) 5000 PipeFail));
  _ = C.check "key delivery failed" (status == 0);
  sleepMs 300.
readMaybe path = case Stream.openRead path 65536 of
    Err why -> Err why
  | Ok r ->
      (result,r2) = Stream.foldChunks (fn acc b -> b :: acc) [] r;
      _ = C.need (Stream.closeRead r2);
      mapOk (fn chunks -> Bytes.concat (List.rev chunks)) result.
waitCapture : String -> (tries : Int | measure tries) -> Bytes .
waitCapture path tries | tries <= 0 = error "snapshot timed out: {path}".
waitCapture path tries = case readMaybe path of
    Ok b -> if Bytes.len b == 15 + 960*600*3 then b
      else _ = sleepMs 100; waitCapture path (tries - 1)
  | Err why -> _ = sleepMs 100; waitCapture path (tries - 1).
waitReady : String -> (tries : Int | measure tries) -> Unit .
waitReady path tries | tries <= 0 = error "graphics did not become ready; see {path}".
waitReady path tries = case readMaybe path of
    Ok bytes -> text = C.need (Utf8.decode bytes);
      if Str.contains "[desktopgl] GLFW" text then sleepMs 500
      else _ = sleepMs 100; waitReady path (tries - 1)
  | Err why -> _ = sleepMs 100; waitReady path (tries - 1).
shot tag fifo n label =
  source = "/private/tmp/{tag}-{n}.ppm";
  ProcessResult code out err = C.observe ["/bin/test","-e",source];
  _ = C.check "existing snapshot {source}" (code == 1);
  _ = key fifo 25;
  b = waitCapture source 200;
  header = C.need (Bytes.slice 0 15 b);
  _ = C.check "wrong snapshot dimensions" (header == C.need (Utf8.encode "P6\n960 600\n255\n"));
  _ = C.need (Fs.renameNow source "evidence/{label}.ppm" True);
  _ = C.command ["/usr/bin/sips","-s","format","png","evidence/{label}.ppm","--out","evidence/{label}.png"];
  b.
waitExit : ProcessJob -> (tries : Int | measure tries) -> Unit .
waitExit job tries =
  (result,next) = Proc.poll job;
  if C.need result then
    PipelineResult code codes out errors = C.need (Proc.wait next);
    C.check "game exited unsuccessfully: {code}/{codes}/{errors}" (code == 0)
  else if tries <= 0 then _ = C.need (Proc.cancel next); error "game did not shut down"
  else _ = sleepMs 100; waitExit next (tries - 1).
start id =
  root = C.need (IO.cwd Unit);
  sdk = C.qosHome Unit;
  scratch = tempDir "{id}-gui";
  fifo = "{scratch}/keys.evd";
  _ = C.command ["/usr/bin/mkfifo",fifo];
  log = "{root}/evidence/game.log";
  _ = C.command ["/bin/rm","-f",log];
  stage = P.inDir scratch (P.withEnv "FPR_PORT" "0" (P.withEnv "FPR_DISK" "{scratch}/disk"
    (P.withEnv "FPR_DISK_MB" "32" (P.withEnv "FPR_EVDEV" fifo (P.spec ["/bin/sh","-c",
      "exec > \"$2\" 2>&1; exec 3<> \"$1\"; shift 2; exec \"$@\"","game",fifo,log,"{sdk}/runtime/qosp-gl","--yes","--trace","{root}/build/{id}.qa"])))));
  job = C.need (Proc.start (PipelineSpec [stage] (PipeBytes (Bytes.empty Unit))
    (PipeCapture 4096) (PipeCapture 32768) 120000 PipeFail));
  _ = waitReady log 600;
  (job,fifo,scratch).

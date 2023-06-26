import colors, config, parsetoml, std/[os, strformat, strutils]

proc nemesisClearBuildFiles* {.inline.} =
 var counter: int = 0
 for kind, path in walkDir(getConfig()["build"]["files_path"].getStr()):
  if dirExists(path):
   if path.endsWith("-nembuild"):
    removeDir(path)
    inc counter

 if counter > 0:
  echo fmt"{GREEN}info{RESET}: cleared {counter} build files!"
 else:
  echo fmt"{GREEN}info{RESET}: there's nothing to clear!"
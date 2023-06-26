import std/[osproc, strformat, strutils], zippy/ziparchives, uuids, curly, config, colors, parsetoml

proc downloadSource*(url: string): string =
 let
  pool = newCurlPool(
   getConfig().getTable()["download"].getTable()["workers"].getInt()
  )
  isTar = url.endsWith(".tar.xz") or url.endsWith(".tar.gz") or url.endsWith(".tar")
  isZip = url.endsWith(".zip")
  storePath = getConfig().getTable()["build"].getTable()
  filesPath = storePath["files_path"].getStr()

 if isTar:
  echo fmt"{RED}fatal{RESET}: nemesis-pkg cannot handle tarballs yet!"
  quit 1

 if not isZip:
  let
   path = fmt"{filesPath}/{genUUID()}-nembuild"

  discard execCmdEx("git clone " & url & " " & path)
  return path
 else:
  var path = fmt"{filesPath}/{genUUID()}-nembuild.zip"
  let file = open(path, fmWrite)
  defer: file.close()

  let data = pool.get(url).body
  file.write(
   data
  )

  var realpath = path
  realpath.removeSuffix(".zip")

  echo fmt"{GREEN}info{RESET}: extracting source tarball to {realpath}"
  extractAll(path, realpath)
  return realpath
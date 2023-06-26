{.experimental.}

import config, history, curly, databases, 
       parsetoml, colors, 
       std/[tables, strformat, strutils, threadpool]

proc synchronize(name, url: string, curlpool: CurlPool) =
 echo fmt"{GREEN}{name}{RESET}: {url}"
 writeHistory(fmt"GET {url}")

 let response = curlpool.get(url)

 case response.code:
  of 404:
   echo fmt"{RED}error{RESET}: {name} returned 404!"
   writeHistory(fmt"GET {url} failed, endpoint returned 404!")
  of 200:
   writeHistory(fmt"GET {url} was successful, read data")
   echo fmt"{GREEN}info{RESET}: successfully fetched data"
  else:
   writeHistory(fmt"GET {url} sent unhandled code, read data?")
   echo fmt"{LIGHTGREEN}warn{RESET}: {name} returned {response.code}, reading data anyway"


 if response.body.len < 1:
  echo fmt"{RED}error{RESET}: {name} returned empty response!"
  writeHistory(fmt"GET {url} failed, endpoint returned empty response!")

 var pkgs: seq[Package] = @[]

 for pkginfo in response.body.splitLines():
  let
   data = pkginfo.split(' ')

  if data[0] != "":
   let
    name = data[0]
    version = data[1]

   pkgs.add(Package(name: name, version: version, files: @[]))
 
 let database = Database(name: name, packages: pkgs)
 database.save()
 writeHistory(fmt"Saved package databases for repository '{name}'")
 echo fmt"{GREEN}{name}{RESET}: saved package database!"

proc parrSynchronize(name, url: string, pool: CurlPool) {.inline.} =
 when defined(nemesisPkgNoParallel):
  synchronize(name, url, pool)
 else:
  parallel:
   spawn synchronize(name, url, pool)

proc nemesisSync*() {.inline.} =
 writeHistory("sync package databases")
 let repos = getConfig()["repos"]
     .getTable()

 let pool = newCurlPool(8)
 
 echo fmt"{GREEN}info{RESET}: synchronizing package databases"

 for reponame, repourl in repos:
  parrSynchronize(reponame, repourl.getStr(), pool)
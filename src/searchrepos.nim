import databases, colors, std/[strformat]

proc findPkg*(name: string): tuple[repo: string, pkg: Package] {.inline.} =
 for repo in @["release", "security"]:
  let db = createDatabase(repo)
  for package in db.packages:
   if package.name == name:
    return (repo: repo, pkg: package)


 echo fmt"{RED}error{RESET}: no package '{name}' found!"
 quit 1

proc nemesisSearchPackage*(name: string) =
 let (repo, pkg) = findPkg(name)

 echo fmt"{GREEN}{pkg.name}{RESET}"
 echo fmt"version: {GREEN}{pkg.version}{RESET}"
 echo fmt"repository: {GREEN}{repo}{RESET}"
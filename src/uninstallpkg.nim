import databases, colors, history, std/[os, strformat]

#[
 Uninstall a singular package.
]#
proc nemesisUninstallPkg*(pkg: string) =
 var installedDb = createDatabase("nemesis-installed")
 if not installedDb.isInstalled(pkg):
  writeHistory(fmt"attempt to uninstall non-existent package '{pkg}'")
  echo fmt"{RED}error{RESET}: cannot uninstall '{pkg}': package not found!"
  quit 1

 var idxToDelete = -1
 for idx, package in installedDb.packages:
  if package.name == pkg:
   idxToDelete = idx
   writeHistory(fmt"uninstalling package {pkg}")
   for file in package.files:
    writeHistory(fmt"removing file '{file}'")
    echo fmt"{GREEN}info{RESET}: removing '{file}'"
    removeFile(file)
   
   writeHistory(fmt"removed package {pkg} successfully")
   echo fmt"{GREEN}info{RESET}: removed package {package.name}@{package.version} successfully!"

 installedDB.packages.delete(idxToDelete)
 installedDB.save()

#[
 Uninstall a sequence of packages.
]#
proc nemesisUninstallPkgs*(pkgs: seq[string]) =
 for pkg in pkgs:
  nemesisUninstallPkg(pkg)
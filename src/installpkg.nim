import history, databases, pkginfo, syncrepos, download, parsetoml, colors, 
       std/[strformat, os, osproc]

proc nemesisInstallPkg*(db: Database, pkg: string, isRetry: bool = false) =
 try:
  let packageVersion = db.getVersion(pkg) # The local package version

  echo fmt"{GREEN}info{RESET}: installing {pkg}@{packageVersion}"

  # Contact repos for the build file, and open the nemesis-installed
  # database
  let buildFile = getBuildInfo(db.name, pkg).getTable()
  var installedDb = createDatabase("nemesis-installed")

  # If this package is already installed, then don't
  # proceed.
  if installedDb.isInstalled(pkg):
   if buildFile["core"]["version"].getStr() == packageVersion:
    echo fmt"{GREEN}info{RESET}: {pkg}@{packageVersion} is already up-to-date. Ignoring."
    return

  # Download the source zip or git repo and process it.
  # then, set the $NEMESIS_PKG_BUILD_DIR variable to
  # the path that downloadSource returns, this will be used
  # by the build script to cd into the build directory.
  writeHistory("downloading source code")
  let path = downloadSource(buildFile["core"]["source"].getStr())
  putEnv("NEMESIS_PKG_BUILD_DIR", path)

  # Execute the build command!
  let res = execCmd(buildFile["build"]["command"].getStr())
  if res != 0:
   # Seems like the compilation failed.
   echo fmt"{RED}error{RESET}: compilation of package failed! If this is an official NemesisOS package, report it to the devs!"
   writeHistory(fmt"failed to install package {pkg}@{packageVersion}; error is thrown in stdout")
  elif res == 0:
   # Compilation was successful. Add file to installed DB
   # alongside the files generated so that they are tracked.
   var files: seq[string] = @[]
   for fileTNode in buildFile["build"]["files"].getElems():
     files.add(fileTNode.getStr())

   # Perform a save
   installedDb.set(pkg, packageVersion, files)
   installedDb.save()

   
   echo fmt"{GREEN}success{RESET}: {pkg}@{packageVersion} successfully installed! Updating package databases..."
   writeHistory(fmt"installed package {pkg}@{packageVersion}")
 except KeyError:
  # Woops, package not found. If this is a retry, as indicated
  # by isRetry, then synchronize databases and try again,
  # if not then quit, showing an error.
  if not isRetry:
   nemesisSync()
   nemesisInstallPkg(db, pkg, true)
  else:
   echo fmt"{RED}error{RESET}: unable to find package: {pkg}"
   quit 1

proc nemesisInstallPkgs*(pkgs: seq[string]) {.inline.} =
 # Try to find the release database, if not found then
 # synchronize the database from the repos and retry.
 var database: Database
 try:
  database = createDatabase("release")
 except IOError:
  nemesisSync()
  nemesisInstallPkgs(pkgs)

 for pkg in pkgs:
  nemesisInstallPkg(database, pkg)
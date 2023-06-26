import std/[strformat, strutils, os, osproc], 
    utils, syncrepos, history, colors, 
    uninstallpkg, repolist, installlist, 
    installpkg, buildfilesmgr, searchrepos

#[
  Shows the help menu. Self explanatory.  
]#
proc showHelp =
  echo "usage: nemesis-pkg [options] [arguments]"
  echo "install <pkg>\tinstall a package"
  echo "uninstall <pkg>\tremove a package"
  echo "search <pkg>\tsearch for a package"
  echo "sync\t\tsynchronize package databases"
  echo "repo-ls\t\tlist all packages in all repositories"
  echo "installed-ls\tlist all installed packages"
  echo "update\t\tupdate all packages from current database"
  echo "upgrade\t\tsync databases and perform an update"

#[
  Get the action, for eg.
  nemesis-pkg install
              ^^^^^^^
                |
              action
]#
proc getAction: string =
  if paramCount() > 0:
    paramStr(1)
  else:
    showHelp()
    quit 1

#[
  Get the package argument, only triggered when an
  action such as install or uninstall is to be executed.
]#
proc getPackageArg: string =
  if paramCount() > 1:
    paramStr(2)
  else:
    showHelp()
    quit 1

#[
  Triggered when CTRL+C is pressed.
  Shows a nice error message rather than an ugly 
  traceback, or worse, just a confusing error in release mode.
]#
proc userTermination* {.noconv.} =
  echo fmt"{RED}error{RESET}: process manually terminated by user."
  quit 1

#[
  Open the history file in the user's preferred text
  editor.
]#
proc nemesisShowHistory* =
  echo fmt"{GREEN}info{RESET}: opening history in your text editor."
  discard execCmd("sudo $EDITOR /root/.nemesis-pkg_history")

#[
  Entry point for the program.
]#  
proc main =
  setControlCHook(userTermination)
  let action = getAction()

  if action.requiresRoot() and not isAdmin():
    echo fmt"{RED}error{RESET}: this action requires superuser privileges (under the root user on most systems)."
    quit 1

  if action.toLowerAscii() == "install":
    nemesisInstallPkgs(@[getPackageArg()])
  elif action.toLowerAscii() == "uninstall":
    nemesisUninstallPkgs(@[getPackageArg()])
  elif action.toLowerAscii() == "sync":
    nemesisSync()
  elif action.toLowerAscii() == "clear-build-files":
    nemesisClearBuildFiles()
  elif action.toLowerAscii() == "repo-ls":
    nemesisRepositoryList()
  elif action.toLowerAscii() == "installed-ls":
    nemesisInstalledList()
  elif action.toLowerAscii() == "show-history":
    nemesisShowHistory()
  elif action.toLowerAscii() == "search":
    nemesisSearchPackage(getPackageArg())
  elif action.toLowerAscii() == "popipo":
    echo fmt"{GREEN}🎵wE aRe vEgEtArIa-A-A-A-A-A-A-A-n🎵{RESET}"
  else:
    showHelp()

when isMainModule: main()
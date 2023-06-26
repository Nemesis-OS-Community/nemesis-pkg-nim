import std/strformat

const ROOT_REQUIRED_ACTIONS = @[
 "install",
 "uninstall",
 "sync"
]

proc requiresRoot*(action: string): bool {.inline.} =
 action in ROOT_REQUIRED_ACTIONS

proc getRawURLForPackage*(pkg: string, repo: string): string {.inline.} =
 fmt"https://raw.githubusercontent.com/Nemesis-OS/packages-{repo}/main/{pkg}/build"
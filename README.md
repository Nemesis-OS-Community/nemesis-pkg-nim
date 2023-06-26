# nemesis-pkg-nim: an alternative package manager to the default nemesis-pkg
Originally, a poll was conducted in the Discord server, which resulted in the Python
package manager winning by 1 vote, hence this will stand as an alternative to nemesis-pkg for now.

# Comparison of features
Both package managers are good in their own right, but currently, this package manager is more feature rich.
| Feature                 | nemesis-pkg-nim | nemesis-pkg |
| ----------------------- | --------------- | ----------- |
| Install                 | yes             | no          |
| Uninstall               | yes             | no          |
| Sync repos              | yes             | yes         |
| List online packages    | yes             | WIP          |
| List installed packages | yes             | no          |
| History                 | yes             | yes         |
| Configuration           | TOML file       | Python file |
| Git and ZIP support     | yes, via zippy  | no          |
| Parallel downloads/sync | partial/WIP     | no          |

# Pros
nemesis-pkg:
- easy to modify (it's just 2 Python scripts)

nemesis-pkg-nim:
- leaps faster
- configurable via TOML, which is nice to work with
- parallelized for the most part
- directly calls into libcurl via [curly](https://github.com/guzba/curly) for as less overhead as possible

# Cons
nemesis-pkg:
- nothing yet added that makes it a package manager, mostly quality of life things

nemesis-pkg-nim:
- you have to recompile the entire binary to make a single change in the internals, though most stuff is configurable via TOML which doesn't require recompilation, but still, a minus.

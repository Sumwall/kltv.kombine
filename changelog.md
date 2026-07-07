## [1.5.20260707]

- [Bugfix] Async command queue: an immediate process-spawn failure is now retried up to three times with a short backoff before giving up, and the final failed result is recorded so it counts against the batch instead of vanishing silently
- [Bugfix] A queued command that produced no result now fails the whole batch (error + exit code -1) instead of being logged only at verbose level and treated as success
- [Misc] Launch-failure diagnostics now name the command, and the "could not launch" message prints at normal level
- [Misc] Lighter, faster CI: a new `mkb smoke` action runs only the fast engine-core examples (no clang, sdl2, msys2 or network). Pull-request checks and the release test gate now run `smoke` on a single platform instead of the full suite on several

## [1.5.20260706]

- [Feature] `#load` and child script resolution is now deterministic: including file directory, script directory, current directory, backward trace and tool directory, in that order. The recursive forward search (walk of every subfolder, first match wins) no longer runs by default — with repos that embed other repos sharing the same relative layout it could silently bind a foreign copy of a helper, and the state cache then persisted the wrong bind
- [Feature] New `-kforward` switch re-enables the forward search as a deprecated bridge; every forward hit prints a warning naming the source and the resolved file. Without the switch, a reference that only the forward search could satisfy fails the compile naming the file it would have picked and how to fix it
- [Feature] Every `#load` prints its resolved absolute path on real compiles (one line per include), so a wrong binding is visible instead of silent
- [Misc] Added the `08.loadresolution` example: two repos sharing the same helper layout, one embedded inside the other's dependency folder, asserting each script binds its own repo's helpers

## [1.4.20260611]

- [Feature] `mkb -h` and `mkb --help` now act as aliases for the `khelp` action
- [Feature] Help output shows the engine banner and version; local and debug builds report the version as "development"
- [Bugfix] Build scripts that only produce warnings (for example nullable annotations) no longer abort compilation — only real errors stop the build
- [Updated] The reference assembly (`mkb.dll`) now ships next to the executable inside the release packages; the standalone `kombine.ref.zip` download has been retired
- [Updated] CI now runs the test suite on pushes to `main`

## [1.4.20260520]

- [Feature] Added Mach-O 64-bit object file format support to bin2obj extension
- [Feature] Architecture-aware C/C++ compiler flags (disable -msse3 on ARM64)
- [Feature] Platform-aware source filtering in examples (SDL2, MSYS2)
- [Feature] macOS ARM64 (Apple Silicon) full support and testing
- [Bugfix] Fixed Directory.Build.props case sensitivity for Linux CI
- [Bugfix] Fixed MSYS2 test to skip gracefully on non-Windows platforms
- [Bugfix] Added LLVM/lld installation for macOS clang extension support
- [Bugfix] Fixed Roslyn 5.0.0 crashes on .NET 10.0 (concurrent build, nullable options)
- [Updated] .NET target framework from 8.0 to 10.0 (latest stable)
- [Updated] CI workflow to .NET 10.0.x and focused on 3 core platforms (win-x64, linux-x64, osx-arm64)
- [Updated] Documentation with macOS ARM64 setup instructions

## [1.4.24072788]
- [Feature] Added methods in Http API to support uploads and credentials
- [Feature] Improved build system to automatically publish a release
- [Feature] Added a github.csx extension to manage github interaction
- [Bugfix] Kombine state now also keeps track of loaded dependencies to trigger rebuild if required
- [Feature] Added a bin2cpp extension to convert binary files to C++ source code
- [Feature] Added a bin2obj extension to convert binary files to object files
- [Feature] Added a modder extension to apply mods to other projects
- [Feature] Improved examples
- [Feature] Added static function to generate build numbers
- [Bugfix] Fixed HTTP file upload was multipart and was causing issues.

## [1.3.24494684]
- [Fixed] Documentation
- [Fixed] Upgraded dependencies. Now uncompressing operations do not fail.
- [Feature] File copy now accepts a file mask

## [1.2.24435852]

- [Feature] Added version function
- [Feature] Added internal Yaml parser
- [Feature] Improved and clang extensions
- [Security] Updated dependencies
- [Feature] Added a clang.doc extension
- [Misc] Improved examples (like msys2 packages)

## [1.1.24259864]

- [Bugfix] Fixed a potential deadlock when a set of parallel async tasks wants to be cancelled (for example on clang build failed)
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
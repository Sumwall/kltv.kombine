[Back to the readme](../readme.md)

# Building Kombine

This documented is intended for people which wants to build Kombine by themselves, to modify it or to add new features.
First, Kombine is not being built with Kombine. Even if its totally possible we had no intentions to use C# as a production language, hence we decided to not spent time creating the corresponding Kombine extensions to deal with [the CSC](https://learn.microsoft.com/en-us/answers/questions/1138661/how-can-i-use-csc-exe--net-framework-executable).

In case of CSC is not a easy task since you need to append all the different references to be consideer into the assembly building. Another option is just call "dotnet build" but just to execute that a Kombine script is not required. If you add a CSC extension to build directly C# without mess with the constrainst of Dotnet we encourage you to share it (so all the rest can tweak the build process).

Anyway Kombine is used in the Kombine building process partially, see [generating the packages](#generating-the-packages)

## Requisites and recomended environment

In order to build Kombine then you need Dotnet SDK 10.0 or later.
You can get your copy from [here at Microsoft](https://dotnet.microsoft.com/en-us/download/dotnet/10.0).

Anything else is required since Kombine is only pure C# managed code.

Once you have cloned this repository and you have Dotnet 10 installed, build Kombine is easy as:
```dotnet build``` or ```dotnet build -r yourplatform here```
We provided a *"directory.build.props"* file so everything from build is stored into an "out" folder with the following structure:

```
out/bin
out/bin/linux-x64/debug
out/bin/linux-x64/release
out/bin/osx-64/debug
out/bin/osx-64/release
out/bin/win-64/debug
out/bin/win-64/release
```

By default it will build the debug configuration, you can pass -c Release to build the release one to the Dotnet command line. By default it will build with the OS you're using but you can pass the -r your-runtime to specify which target OS you want to generate.

Also you can use the provided Kombine script to build the project, just execute ```kombine build``` which is just a wrapper on top of dotnet build.

Usage of Visual Studio (a solution is provided) is encouraged if you want to modify the code, but you can use any other IDE or just a text editor and command line.

## macOS Setup (Apple Silicon & Intel)

If you're building on macOS and want to use C/C++ build extensions (clang, bin2obj), install the LLVM toolchain:

```bash
brew install llvm lld
```

Then add LLVM to your PATH:

```bash
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
```

You can make this permanent by adding it to your shell profile (`.zshrc` or `.bash_profile`).

**Platform Notes:**

- The `lld` linker is required for C/C++ linking via the clang extension
- The `bin2obj` extension generates Mach-O object files on macOS and COFF on Windows/Linux — automatic format detection works transparently
- For best compatibility, use the native clang toolchain when available (`brew install llvm`)

## Generating the packages

For this case we use Kombine. There is one Kombine script in the root of the repository which supports actions:

- `build` — Just a wrapper on top of `dotnet build`
- `publish` — Builds in release for the three target OS (Windows, Linux and Mac OSX) the two flavors (unpacked and single file). It generates the different packages (.tar.gz / zip).
- `test` — Executes all the provided examples as a test

All the packages are dropped into `out/pkg/`.

### Version numbering

The version build number is generated automatically during the `publish` action. It is extracted from the Git tag and injected into `src/version.cs` before compilation. The tag format is `v<MAJOR>.<MINOR>.<BUILDNUMBER>` (e.g., `v1.4.20260520`), where BUILDNUMBER is typically YYYYMMDD.

### Creating a release

Releases are triggered automatically via GitHub Actions when you push a Git tag matching the pattern `v*`. Do NOT push tags manually to run the build locally — use the `kombine publish` and `kombine release` actions instead (requires `GITHUB_TOKEN` in `kltv_token` environment variable).

To create a release:

```bash
git tag v1.4.20260520
git push origin v1.4.20260520
```

GitHub Actions will then:
1. Run the smoke test suite on Linux
2. Cross-compile for all three platforms (Windows, Linux, macOS)
3. Package the 6 artifacts (debug + release for each platform); the single-file release packages bundle the `mkb.dll` reference assembly next to the executable
4. Create a GitHub release with all artifacts attached

The workflow is defined in `.github/workflows/main-release.yml`.

## Source code structure

Source structure is very intuitive.

```
src/api contains what is exposed to the scripts (types and methods)
src/cache the tiny code to manage built assemblies cache
src/core the tool configuration and command line / script state
src/exec the tool executor and script executor
util/ has some extension methods and other things are not being used but lying there just in case.
```

Any extension is welcome.

[Back to the readme](../readme.md)
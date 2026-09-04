# Kombine Build System

<table>
  <tr>
    <td><a href="https://github.com/kollective-networks/kltv.kombine/actions/workflows/pr-tests.yml"><img src="https://github.com/kollective-networks/kltv.kombine/actions/workflows/pr-tests.yml/badge.svg" alt="Kombine tests"/></a></td>
    <td><a href="https://github.com/kollective-networks/kltv.kombine/releases/latest"><img src="https://img.shields.io/github/v/release/kollective-networks/kltv.kombine?sort=date" alt="Kombine Release"/></a></td>
  </tr>
</table>

Kombine is a small, cross-platform build system whose build scripts are written in plain C#. You get a real programming language instead of a custom DSL, and a single self-contained executable that needs nothing else installed to run.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Feature state](doc/features.md)
- [Download and Installation](#download-and-installation)
- [Usage](#usage)
  - [Exit codes](#exit-codes)
- [Script structure and execution](#script-structure-and-execution)
  - [Enable intellisense in your editor](#enable-intellisense-in-your-editor)
  - [Debugging your scripts](#debugging-your-scripts)
- [Executing child scripts and sharing values between your scripts](#executing-child-scripts-and-sharing-values-between-your-scripts)
  - [Using Import/Export](#using-importexport)
  - [Using Shared API](#using-shared-api)
  - [Using Registry API](#using-registry-api)
- [The most simple example, execute a tool and fetch the results](#the-most-simple-example-execute-a-tool-and-fetch-the-results)
- [Extending Kombine](#extending-kombine)
- [Examples](#examples)
- [Requirements to create Kombine](doc/reasons.md)
- [Building the Kombine tool](doc/building.md)
- [Creating a Release](#creating-a-release)
- [API reference](doc/api.md)
- [TODO List](doc/todo.md)
- [License](#license)

## Overview

There are plenty of build systems out there, but none of them fit the exact set of requirements we had. The honest truth is that we wanted a few bits from each of them. If you want some background reading, this [thread on build systems](https://www.reddit.com/r/cpp/comments/i7825h/build_system_whats_your_favorite/) is a fun one.

For the full list of requirements and the reasons we built our own, see [the reasons document](doc/reasons.md).

Kombine is a plain, simple build system built on the [Roslyn compiler](https://github.com/dotnet/roslyn) and written in C#, so the language you write your build scripts in is C# too. The syntax is easy, mostly self-explanatory, and the same script runs on every supported platform.

The tool ships as a single, self-contained file, so you do **not** need .NET installed to run it. Kombine loads and runs your build scripts with nothing else required. Don't know C#? Don't worry: we kept the common cases simple enough that you don't need to be a C# expert to write a script. Head to [Usage](#usage) to get started.

## Features

- Works on Windows, Linux and macOS.
- Gives you an easy way to pass parameters into your build scripts and read them back.
- Launches any external tool, with support for queuing commands and running them in parallel.
- Hands you the full tool result (stdout, stderr and the exit code) so you can do whatever you want with it.
- Being C#, you have all the usual string handling, regular expressions and text parsing at your disposal.
- Provides cross-platform helpers for folders (create, delete, copy).
- Provides cross-platform helpers for files (exists, create, write, delete).
- Ships two built-in types, `KValue` and `KList`, for single values and lists, with a simpler syntax for building up tool arguments.
- Exposes consistent information about the host environment, so you don't need platform-specific code just to check, for example, whether you are running as root.
- Includes an HTTP download helper, so you don't have to install or shell out to a separate tool per platform.
- Has rich console output (including colored warnings and errors), indentation and a built-in progress bar.
- Can share variables with child processes and child scripts.
- Can share objects (for example an open file) with child scripts.
- Can register build values in a shared registry that the rest of your scripts can read.
- Has file globbing, so you don't have to list every single file in your build.
- Can run child scripts in-process, without spawning another process.

## Download and Installation

All releases and downloads live on the [releases page](https://github.com/kollective-networks/kltv.kombine/releases).

### Single-file executables (recommended)

These are self-contained and ready to use. Extract the archive and put the executable on your `PATH`:

- [Windows](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.win.x64.zip)
- [Linux](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.lnx.x64.tar.gz)
- [macOS (Apple Silicon)](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.osx.arm64.tar.gz)

That's it. No other dependencies, no other languages, you're done. That's exactly the way we [wanted it](doc/reasons.md).

These packages also include `mkb.dll` (the reference assembly) next to the executable. You only need it to enable editor intellisense while writing scripts; it is never used when the tool runs. To turn intellisense on, copy that `mkb.dll` next to your script — see [Enable intellisense in your editor](#enable-intellisense-in-your-editor).

### Debug / unpacked versions (optional)

If you need to debug your build scripts with a .NET debugger, grab the unpacked builds instead. They work around a debugger limitation with single-file executables (see [Debugging your scripts](#debugging-your-scripts)):

- [Windows](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.debug.win.x64.zip)
- [Linux](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.debug.lnx.x64.tar.gz)
- [macOS (Apple Silicon)](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.debug.osx.arm64.tar.gz)

## Usage

The basic shape of a command is:

```text
mkb [parameters] [action] [action parameters]
```

The tool is case sensitive. ("mkb" stands for **M**ake **K**ombine **B**uild.) This is what you get if you just run `mkb` on its own:

```text
Kombine Build Engine 1.4.20260611
Copyrigth(C) Kollective Networks 2026. All rights reserved.

mkb [parameters] [action] [action parameters]

    [parameters] They are optional and can be any of the following:

    -ksdbg
       Script will include debug information so script debugging will be possible.
    -ksrb or -ksrebuild
       Script will be rebuilded even if it is cached.
    -ko:silent or -ko:s
       Script output will be silent.
    -ko:normal or -ko:n
       Script output will be normal.
    -ko:verbose or -ko:v
       Script output will be verbose.
    -ko:debug or -ko:d
       Script output will be debug.
    -kfile:filename
       Indicates which script file we should execute (default kombine.csx)

    [action] Action to be executed. If not specified the default action is "khelp"
             The action is used to specify which function in the script should be called after evaluation but
             there are some reserved actions for the tool itself which cannot be used for the scripts:

     kversion: Shows tool version and exit.
     khelp: Show this help and exit. Also available as "-h" or "--help" when used alone.
     kconfig: Manages the tool configuration.
     kcache: Manages the tool cache.

    [action parameters]
             They are optional and belongs to the specified action. In case of scripts,they are passed to the
             executed function as parameters. For example: mkb kcache help
```

The **parameters** configure the tool itself: whether the script is built with debug information (needed if you want to attach a debugger), how much output you see, and which script file to run (the default is `kombine.csx` in the current folder).

The **output level** mostly helps you understand what a script is doing without attaching a debugger. In verbose or debug mode the tool prints extra lines about what it is processing. For example, if you use a `Glob` and want to see what it matched, run with verbose output and the matches will show up in the log. The levels are:

- **Normal** prints only the messages your script emits.
- **Verbose** prints your messages plus information from the API functions you call.
- **Debug** prints everything verbose does, plus internal debug information from the tool.

Note that the debug level is meant for debugging Kombine itself, not your script. You are free to pass your own arguments to your script and set the output level to whatever suits you.

The **action** is the function in your script that gets called. See [Script structure and execution](#script-structure-and-execution) for how that works. A few action names are reserved for the tool itself (the built-ins like `kconfig` and `kcache`). The leading "k" is there to keep them out of your way, so an action named `config`, for example, is still free for you to use. If you don't specify an action, the default is `khelp`.

The **action parameters** are passed straight through to the action you call. Everything after the action name is treated as an action parameter.

### Exit codes

Kombine follows standard Unix exit code conventions:

- `0` — Success.
- `1` — Generic failure (script aborts, internal errors, unimplemented built-ins).
- `130` — User cancellation (Ctrl+C).
- Other values — Explicit return values from action functions are preserved (for example, `return 7` exits with code `7`).

Compatibility notes:

- The built-in `kconfig` exits with `1` while it is unimplemented.
- The built-in `kcache` exits with `1` for missing or unknown subcommands, and `0` on success.
- Actions that don't return an `int` are treated as failures (exit code `1`).
- Always test for failure with `!= 0`, not `== -1`.

## Script structure and execution

A script has two parts: the **global** code and the **actions**. Here is a small example:

```csharp
KValue mymessage = "hello world!";

int build(string[] args){
    Msg.Print("I'm building: "+mymessage);
    return 0;
}
int clean(string[] args){
    Msg.Print("I'm cleaning: "+mymessage);
    return 0;
}
```

The first part is the **global code**. It always runs, no matter which action you call. You can put anything there: define values and lists, or call functions. For example, if your global code contains `Http.DownloadFile("youruri", "pathtosave");`, that file gets downloaded on every run of the script.

The second part is the set of **actions** (the functions). If you run the script with `mkb build`, the global code runs first and then the `build` function runs. An action receives the action parameters as a string array, and its return value becomes the script's exit code.

Simple, right? We borrowed the simplicity of `make` while making it cross-platform out of the box. Inside an action you can do whatever you like (create instances, call other functions, anything) because it is just C#.

"But surely this is slow?" It is, for the **first** run of a script. Invoking Roslyn to compile a piece of C# (possibly with other includes) is not instant. That said, it's not the end of the world: "not fast" means a couple of seconds, not half your afternoon.

To avoid paying that cost every time, Kombine keeps a transparent build cache. The first time a script runs, or whenever you change it, it gets compiled and stored in the cache (in your home folder, under the per-application area, for example `C:\Users\<username>\AppData\Roaming\kombine` on Windows). On later runs the script runs like a normal application, with no compilation, so it's fast.

When you do want to force a rebuild, you have two options:

- Run `mkb kcache clear` to delete the entire build cache, so every script recompiles on its next run.
- Run `mkb -ksrb <action> <args>` to ignore the cache for the current script and rebuild just that one.

The cache is designed to garbage-collect itself, dropping files that are no longer needed on any Kombine run. That part is not implemented yet.

We also tried to keep the built-in types as simple as possible. For example, to build a list:

```csharp
KList   src = "my item1";
        src += "my item2";
```

or:

```csharp
KList   src = new() { "item1", "item2" };
```

And to remove an item:

```csharp
KList   src = new() { "item1", "item2" };
        src -= "item2";
```

This is handy when you are assembling command-line arguments and need to add or remove them. `KValue` and `KList` also have convenient conversions and helper methods (for example, `KList.Flatten` turns the list into a single `KValue`, which is great for passing a full argument list to a tool).

Don't forget to check the [API reference](doc/api.md) and the [Examples](#examples) to learn what else is available.

### Enable intellisense in your editor

Kombine scripts are plain C#. When `mkb` runs a script it already knows every Kombine type (`Msg`, `Folders`, `KValue`, `Tool`, and so on) because those types live inside `mkb` itself. Your editor does not: it only sees the script text. So a script builds and runs fine on its own, but your editor can't offer autocomplete or type checking for the Kombine API unless you hand it a description of that API.

That description is the **reference assembly**, a file named `mkb.dll`. It holds the public API surface (the types and their signatures) with no executable code inside, just enough for your editor's C# engine (OmniSharp or the C# Dev Kit in VS Code, Rider, Visual Studio) to understand what you can call.

To switch intellisense on, add this to the top of your script:

```csharp
#r "mkb.dll"
using Kltv.Kombine.Api;
using Kltv.Kombine.Types;
using static Kltv.Kombine.Api.Statics;
using static Kltv.Kombine.Api.Tool;
```

- `#r "mkb.dll"` tells your editor where to find the API description.
- The `using` lines bring the common Kombine namespaces into scope so the names resolve.

The `mkb.dll` you need ships next to the executable inside the single-file packages. Copy it next to your script, or point `#r` at wherever you keep it. Your editor resolves the path relative to the script file, so a relative path such as `#r "../build/mkb.dll"` is fine.

![Intellisense](doc/assets/intellisense.png "Intellisense")

**This is editor-only.** When `mkb` runs your script it ignores the `#r` line completely: it resolves the API from the running tool in memory, whether or not `mkb.dll` exists on disk. You can delete the `#r` line entirely and the script still builds and runs; you just lose autocomplete while editing. In other words, the path you put in `#r` never affects your build, it only tells your editor where the API description lives.

Beyond that there are no rules. The rest is up to you. Check the [API reference](doc/api.md) for the full list of built-in functionality.

### Debugging your scripts

You can debug your scripts, for example with VS Code and the .NET debugger. Point your `launch.json` at the tool, pass it your script and the right parameters, set a breakpoint in your script, and you're set. Just remember to pass the `-ksdbg` flag so the script is built with debug information.

Here is an example `launch.json` for VS Code:

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "C#: Debug script",
            "type": "coreclr",
            "request": "launch",
            "windows": {
                "program": "mkb.exe"
            },
            "linux":{
                "program": "mkb.out"
            },
            "osx": {
                "program": "mkb.out"
            },
            "args": [ "-ksdbg","-ko:d", "youractionhere","yourparameters" ],
            "cwd": "folder for your script",
            "console": "integratedTerminal",
        }
    ]
}
```

One caveat: in some cases the .NET debugger [fails to launch and attach](https://github.com/dotnet/runtime/issues/42927) to a single-file .NET binary. If you hit that and you want to debug your scripts, use a self-contained build that is **not** single-file instead. This .NET issue has been reported across [several frameworks](https://github.com/dotnet/runtime/issues/84428) and was [supposedly fixed for .NET 8](https://github.com/dotnet/runtime/pull/84965), but in practice it still happens.

The self-contained, non-single-file builds are here:

- [Windows](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.debug.win.x64.zip)
- [Linux](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.debug.lnx.x64.tar.gz)
- [macOS (Apple Silicon)](https://github.com/kollective-networks/kltv.kombine/releases/latest/download/kombine.debug.osx.arm64.tar.gz)

## Executing child scripts and sharing values between your scripts

Kombine has a function called `Kombine` with this signature:

```csharp
int Kombine(string script, string action, string[]? args = null, bool exitonerror = true, bool changedir = true, bool search = true)
```

You use it to invoke another Kombine script. The `script` argument is the filename and may include an absolute or relative path. You also pass the action to run and, optionally, arguments for it. The `changedir` parameter controls whether the current working directory is switched to the child script's folder. With `exitonerror` you can have the parent abort automatically if the child returns a non-zero code.

The `search` parameter controls whether Kombine automatically searches for the child script. The lookup order is the same one used when you include another script (see [Extending Kombine](#extending-kombine)):

1. The current working directory.
2. The current script's directory.
3. Forward paths.
4. Backward paths.
5. The Kombine tool directory.

The function returns the child script's exit code. Simple enough. See [Exit codes](#exit-codes) for what the return value means.

Sometimes you also need to share information between a parent and its child scripts (global definitions, paths, whatever). There are several ways to do that.

### Using Import/Export

The first method uses the `KValue` methods `Import` and `Export`. `Export` takes the variable's content and stores it in the internal environment table under the name you give it:

```csharp
KValue myvar = "value";
myvar.Export("VAR");
```

The content of `myvar` ("value") is then available to:

- Child scripts, if they use the `Import` method.
- Child processes launched by `Exec` or `Tool`, if they read the environment variable `VAR`.

This lets you set up environment variables for all the child processes you launch.

`Import` does the opposite, with a small twist:

```csharp
KValue myvar = KValue.Import("VAR","othervalue");
```

Here `myvar` is filled with the value of the environment variable `VAR`, or with `"othervalue"` as a default if that variable doesn't exist. This is especially useful when you want scripts that can run standalone but still accept overrides from a parent script.

### Using Shared API

Sometimes sharing a plain value isn't enough and you want to share something more complex. Consider a real case: the `compile_commands.json` file used for clang intellisense. Ideally your parent (master) script decides where that file lives, then runs the different parts of the build, each adding or modifying entries in that one file.

For that you have `Share.Set` and `Share.Get` to store and retrieve objects. Following the example above, you can write a class that manages the file and pass the instance to the rest of the scripts. The example extension `clang.csx` does exactly this to share the compile commands with all of its descendant scripts.

`Share.Set` takes a name and an object; `Share.Get` takes the name and returns the object. Here is how `clang.csx` uses it to manage that file, though you can apply the same pattern to anything:

```csharp
if (Share.Get("compile_commands") != null) {
    compdb = Share.Get("compile_commands") as JsonFile;
    return true;
} else {
    // Create it if it doesn't exist
    compdb = new JsonFile(file);
    if (compdb.Doc == null) {
        // It's a new one, just create the array.
        compdb.Doc = new JsonArray();
        if (compdb.Save() == true){
            Share.Set("compile_commands",compdb);
            return true;
        }
        Msg.PrintWarning("Failed to create a new compile commands file: "+file,Msg.LogLevels.Verbose);
        return false;
    }
    Share.Set("compile_commands",compdb);
    return true;
}
```

Remember, just like Import/Export, the Shared API flows down to child scripts only, not to parents or siblings.

One more note: a complex object is often defined as a class or struct inside your script, and that definition only exists in your script's scope. So you share the object, but not its type definition. To use it in a child script, include the same definition there and cast the retrieved object with `static T? Cast<T>(object? myobj)`. The example extension `clang.csx` uses this to share default clang options between script instances:

```csharp
object? obj = Share.Get("ClangOptions");
if (obj != null) {
    ClangOptions? opt = Cast<ClangOptions>(obj);
```

### Using Registry API

Sometimes you need to propagate information differently. So far we've shared things with child scripts and the tool environment, but consider this real case:

You have a project with 20 libraries that build independently. Five of them consume another five as inputs, so you need their include directories, library folders, and so on. Now two of those libraries change paths because you reorganized the tree, so you have to walk through all your scripts fixing the output paths. Common, right?

The registry helps with exactly that. It is a global dictionary shared by all scripts: when a library is built it can **register** the paths it produces and make them available to everything else that needs them. So if you change your outputs, only the affected library's script needs touching; everything else just reads from the registry.

For example, in the build step of your library you can write:

```csharp
Share.Register("mylibrary","includes",RealPath("includes/"));
```

And in another script that depends on the library you read the value back:

```csharp
KValue regvalue = Share.Registry("mylibrary","includes");
```

You can also use it to register dependencies that are resolved per platform in the early stages of a build. This lets you organize the build so you don't have to touch dozens of scripts every time a dependency changes, just update the registry entry and you're done.

## The most simple example, execute a tool and fetch the results

There is a handy shortcut to run anything:

```csharp
int Result = Exec("/path/toMyTool/mytool.exe","arg1 arg2",true);
```

You can pass a `KValue` or `KList` as well. One of the `Exec` overloads is:

```csharp
int Exec(string command, string? args = null, bool showoutput = false)
```

So you can write:

```csharp
KValue toolname = "mytool.exe";
if (Host.IsMacOS())
    toolname = "mytool.out";
KList args = new() { "arg1","arg2" };
int Result = Exec(toolname,args);
```

That only gives you back the exit code, which is fine for simple commands but not very powerful. When you need more, use the `Tool` class:

```csharp
Tool mytool = new Tool("mytool");
ToolResult res = mytool.CommandSync("mytool.exe","-j -k -l");
```

![ToolResult](doc/assets/toolresult.png)

`ToolResult` gives you everything you need, including stderr and stdout. Here we ran the command synchronously (it blocks until the tool finishes), but the `Tool` class can also queue commands and launch them later, with a cap on how many run concurrently, plus other options. Each launched tool receives a copy of the current environment variables, so anything you add is passed along.

Check the [API reference](doc/api.md) for more on console output, shell execution, and more.

## Extending Kombine

Kombine has a [built-in API](doc/api.md) for the common cases, but you'll often want to extend it in a reusable way. A typical case is wrapping a tool's invocation, maybe to simplify building its command line, or to add some default arguments.

Being C#, you can of course write a class to encapsulate any functionality. That's nice on its own, but to keep your code organized and reusable across projects we extended the `#load` directive to do something better.

In C# there is a `#load "whatever"` directive that includes another script into the current one. `#load` and `#r` directives must appear before any regular statements (comments don't count). So at the top of your script you can write `#load "mytool.csx"`.

In regular C# scripting, `#load` only accepts a relative or absolute path, which forces you to keep your scripts' relationships pinned to the filesystem. Kombine's `#load` works a bit differently:

- If the path is absolute, it is used as-is. Nothing else.
- If the path is a URL, the file is fetched from that URL, stored in the cache, and used.
- If the path is relative, Kombine searches several folders in this order:
  - The current working directory.
  - The script's directory.
  - Forward paths (from the current script's folder, going forward).
  - Backward paths (from the current script's folder up to the drive root).
  - The tool directory (where the executable lives).

This way you can keep a folder of scripts in your tree and load them from anywhere with `#load "myscriptfolder/myscript.csx"`, no matter where you are; Kombine will walk the tree and find your folder. You can also keep your own repository of scripts and pull them in over HTTP. Nice, right?

## Examples

The `examples` folder has several examples that show how all of this works. There is a `kombine.csx` in that folder that can run every example at once.

The examples and what each one demonstrates:

- **simple**: The bare minimum, just prints a few strings.
- **base**: Initial functions, version checks, and so on.
- **types**: Operations with `KValue` and `KList`.
- **child**: Running child scripts, Import/Export, and other sharing.
- **folders**: Working with files, folders, and compression.
- **clang**: Building with clang using the provided extension (static library, dynamic library, and binary).
- **sdl2**: Building SDL2, cloning it from GitHub with git.
- **network**: Fetching files from HTTP sources.
- **msys2**: Fetching packages from MSYS2 repositories.

Because Kombine is all about reuse, some ready-made extension scripts live in the `extensions` folder:

- **clang.csx**: A class wrapping clang operations (Compile, Link, Librarian).
- **git.csx**: A class wrapping git operations (clone, checkout, fetch).
- **clang.doc.csx**: A class wrapping clang-doc, with conversion to Markdown files.

They aren't exhaustive, but they're complete enough to clone and build real projects. If you write an extension class you think others could use, please share it. Everything is welcome.

## Creating a Release

Releases are triggered by pushing a Git tag that matches the pattern `v*` (for example, `v1.4.20260520`). GitHub Actions then builds for every platform and publishes a release with all the artifacts:

```bash
git tag v1.4.20260520
git push origin v1.4.20260520
```

The CI workflow runs the tests, cross-compiles for Windows, Linux and macOS, packages both the debug and release builds, and publishes them to GitHub Releases. See [doc/building.md](doc/building.md) for the detailed instructions.

## License

MIT License

Copyright (c) 2022 Kollective Networks

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

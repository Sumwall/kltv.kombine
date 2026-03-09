[CmdletBinding()]
param(
  [string]$WorkflowPath = ".github/workflows/main-release.yml",
  [string]$PlatformMap = "windows-latest=-self-hosted",
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Resolve-ActExecutable {
  $actCommand = Get-Command act -ErrorAction SilentlyContinue
  if ($null -ne $actCommand) {
    return $actCommand.Source
  }

  $winget = Get-Command winget -ErrorAction SilentlyContinue
  if ($null -eq $winget) {
    throw "act is not installed and winget is unavailable. Install act manually from https://github.com/nektos/act/releases."
  }

  Write-Host "act not found. Installing via winget..."
  & winget install --id nektos.act -e --source winget --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install act via winget (exit code $LASTEXITCODE)."
  }

  $actCommand = Get-Command act -ErrorAction SilentlyContinue
  if ($null -ne $actCommand) {
    return $actCommand.Source
  }

  $fallback = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter act.exe -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty FullName
  if ($fallback) {
    return $fallback
  }

  throw "act install completed but executable is still not discoverable. Open a new shell or add act to PATH."
}

$actExecutable = Resolve-ActExecutable

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..")

Push-Location $repoRoot
try {
  if (!(Test-Path $WorkflowPath)) {
    throw "Workflow file not found: $WorkflowPath"
  }

  $baseArgs = @(
    "workflow_dispatch",
    "-W", $WorkflowPath,
    "-P", $PlatformMap,
    "--env", "LOCAL_RELEASE_TEST=true"
  )

  if ($DryRun) {
    Write-Host "Running dry-run..."
    & $actExecutable @baseArgs "-n"
    if ($LASTEXITCODE -ne 0) {
      throw "Dry-run failed with exit code $LASTEXITCODE"
    }
    Write-Host "Workflow dry-run completed successfully."
    return
  }

  Write-Host "Running full local test execution..."
  & $actExecutable @baseArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Workflow execution failed with exit code $LASTEXITCODE"
  }

  Write-Host "Workflow local test completed successfully."
}
finally {
  Pop-Location
}

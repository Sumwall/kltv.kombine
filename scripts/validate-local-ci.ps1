[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$SkipWorkflowRun
)

$ErrorActionPreference = "Stop"

function Resolve-ActionlintExecutable {
  $actionlintCommand = Get-Command actionlint -ErrorAction SilentlyContinue
  if ($null -ne $actionlintCommand) {
    return $actionlintCommand.Source
  }

  $winget = Get-Command winget -ErrorAction SilentlyContinue
  if ($null -eq $winget) {
    throw "actionlint is not installed and winget is unavailable. Install actionlint manually from https://github.com/rhysd/actionlint/releases."
  }

  Write-Host "actionlint not found. Installing via winget..."
  & winget install --id rhysd.actionlint -e --source winget --accept-package-agreements --accept-source-agreements
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install actionlint via winget (exit code $LASTEXITCODE)."
  }

  $actionlintCommand = Get-Command actionlint -ErrorAction SilentlyContinue
  if ($null -ne $actionlintCommand) {
    return $actionlintCommand.Source
  }

  $fallback = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter actionlint.exe -ErrorAction SilentlyContinue |
    Select-Object -First 1 -ExpandProperty FullName
  if ($fallback) {
    return $fallback
  }

  throw "actionlint install completed but executable is still not discoverable. Open a new shell or add actionlint to PATH."
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptRoot "..")
$actionlintExecutable = Resolve-ActionlintExecutable

Push-Location $repoRoot
try {
  $workflows = @(
    ".github/workflows/pr-tests.yml",
    ".github/workflows/main-release.yml"
  )

  foreach ($workflow in $workflows) {
    if (!(Test-Path $workflow)) {
      throw "Workflow file not found: $workflow"
    }
  }

  Write-Host "Running actionlint..."
  & $actionlintExecutable @workflows
  if ($LASTEXITCODE -ne 0) {
    throw "actionlint failed with exit code $LASTEXITCODE"
  }
  Write-Host "Workflow lint passed."

  if ($SkipWorkflowRun) {
    Write-Host "Skipping workflow execution test (--SkipWorkflowRun)."
    return
  }

  $releaseTestScript = Join-Path $scriptRoot "test-release-workflow.ps1"
  if (!(Test-Path $releaseTestScript)) {
    throw "Release workflow test script not found: $releaseTestScript"
  }

  $releaseArgs = @()
  if ($DryRun) {
    $releaseArgs += "-DryRun"
  }

  if ($DryRun) {
    Write-Host "Running release workflow dry-run validation..."
  } else {
    Write-Host "Running end-to-end local release workflow test..."
  }
  & pwsh -NoLogo -NoProfile -File $releaseTestScript @releaseArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Local release workflow test failed with exit code $LASTEXITCODE"
  }

  Write-Host "Local CI validation completed successfully."
}
finally {
  Pop-Location
}

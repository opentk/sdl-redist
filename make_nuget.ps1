param([String]$projectDir, [int]$verBuild)

$ErrorActionPreference = "Stop"
[int]$SDL_MAJOR_VERSION=2
[int]$SDL_MINOR_VERSION=26
[int]$SDL_PATCH_VERSION=5
[String]$SDL_VERSION="$($SDL_MAJOR_VERSION).$($SDL_MINOR_VERSION).$($SDL_PATCH_VERSION)"

[String]$SDL_SO_POSTFIX="0.$($SDL_MINOR_VERSION * 100).$($SDL_PATCH_VERSION)"

$buildVersionResult = $verBuild.ToString()
$currentBranch=(git branch --show-current)
Write-Output "Current Branch: $currentBranch"

if($currentBranch -eq "develop") {
    $buildVersionResult = "0-pre" + (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
}


./download_dependencies.ps1 $SDL_VERSION

$header = Get-Content([System.IO.Path]::Combine($projectDir, ".\tmp\src\build\include\SDL_version.h")) | Out-String

if ($header -match '(?m)^#define\s+SDL_MAJOR_VERSION\s+(\d+)\s*$') { $verMajor = $Matches[1] }
else { throw "Failed to parse major version number from header." }
if ($header -match '(?m)^#define\s+SDL_MINOR_VERSION\s+(\d+)\s*$') { $verMinor = $Matches[1] }
else { throw "Failed to parse minor version number from header." }
if ($header -match '(?m)^#define\s+SDL_PATCHLEVEL\s+(\d+)\s*$') { $verPatch = $Matches[1] }
else { throw "Failed to parse patch version number from header." }

$version = "$verMajor.$verMinor.$verPatch.$buildVersionResult"

Write-Output $version

$nuspec = [System.IO.Path]::Combine($projectDir, ".\sdl-redist.csproj")

dotnet pack $nuspec -c Release -p:VERSION="$version" -p:SDL_VERSION="$SDL_VERSION" -p:SDL_SO_POSTFIX="$SDL_SO_POSTFIX" -o ./artifacts
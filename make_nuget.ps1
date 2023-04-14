param([String]$projectDir, [int]$verBuild)

$ErrorActionPreference = "Stop"
[String]$SDL_VERSION="2.26.5"

# The built .so file will end in .so.3.3 for a version like 3.3.7, to get the correct file we need to pass "3.3" to the .csproj
# [String]$GLFW_SHORT_VERSION = $GLFW_VERSION.Substring(0, $GLFW_VERSION.LastIndexOf("."))

$buildVersionResult = $verBuild.ToString()
$currentBranch=(git branch --show-current)
Write-Output "Current Branch: $currentBranch"

if($currentBranch -eq "develop") {
    $buildVersionResult = "0-pre" + (Get-Date).ToUniversalTime().ToString("yyyyMMddHHmmss")
}


./download_dependencies.ps1 $SDL_VERSION

return
# FIXME!
$header = Get-Content([System.IO.Path]::Combine($projectDir, ".\tmp\src\include\SDL\sdl.h")) | Out-String

if ($header -match '(?m)^#define\s+GLFW_VERSION_MAJOR\s+(\d+)\s*$') { $verMajor = $Matches[1] }
else { throw "Failed to parse major version number from header." }
if ($header -match '(?m)^#define\s+GLFW_VERSION_MINOR\s+(\d+)\s*$') { $verMinor = $Matches[1] }
else { throw "Failed to parse minor version number from header." }
if ($header -match '(?m)^#define\s+GLFW_VERSION_REVISION\s+(\d+)\s*$') { $verPatch = $Matches[1] }
else { throw "Failed to parse patch version number from header." }

$version = "$verMajor.$verMinor.$verPatch.$buildVersionResult"

$nuspec = [System.IO.Path]::Combine($projectDir, ".\sdl-redist.csproj")

dotnet pack $nuspec -c Release -p:VERSION="$version" -p:GLFW_VERSION="$GLFW_VERSION" -p:GLFW_SHORT_VERSION="$GLFW_SHORT_VERSION" -o ./artifacts
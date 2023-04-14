Param([parameter(Mandatory=$true,Position=0)][String]$SDL_VERSION)

# FIXME: Get out the major version so we can do SDL2 and SDL3

New-Item -ItemType Directory -Force -Path tmp

try{
    Invoke-WebRequest -Uri https://opentk.net/assets/opentk.png -OutFile tmp/opentk.png -Resume
} catch [System.NullReferenceException] {
}

try{
    Invoke-WebRequest -Uri https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL2-$SDL_VERSION-win32-x86.zip -OutFile tmp/win32-x86.zip -Resume
} catch [System.NullReferenceException] {
}
try{
    Invoke-WebRequest -Uri https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL2-$SDL_VERSION-win32-x64.zip -OutFile tmp/win32-x64.zip -Resume
} catch [System.NullReferenceException] {
}

try{

    Invoke-WebRequest -Uri https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL2-$SDL_VERSION.dmg -OutFile tmp/macos.dmg -Resume
} catch [System.NullReferenceException] {
}

try{
    Invoke-WebRequest -Uri https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL2-$SDL_VERSION.zip -OutFile tmp/source.zip -Resume
} catch [System.NullReferenceException] {
}

Expand-Archive -Path tmp/win32-x86.zip -DestinationPath tmp/win32-x86/ -Force
Expand-Archive -Path tmp/win32-x64.zip -DestinationPath tmp/win32-x64/ -Force
Expand-Archive -Path tmp/source.zip -DestinationPath tmp/ -Force
if (Test-Path tmp/src) {
    Remove-Item -Recurse -Path tmp/src
}
Rename-Item -Path tmp/SDL2-$SDL_VERSION -NewName src

mkdir tmp/src/build
Push-Location tmp/src/

cmake -S . -B build
if ($LastExitCode -ne 0) {
    throw '"cmake -S . -B build" failed: ' + $LastExitCode
}

cmake --build build
if ($LastExitCode -ne 0) {
    throw '"cmake --build build" failed: ' + $LastExitCode
}

Pop-Location
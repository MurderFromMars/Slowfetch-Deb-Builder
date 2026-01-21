# Slowfetch Debian Builder

The Slowfetch Debian Builder is a dedicated script for producing a Debian package of Slowfetch, the fast and beautiful system information tool created by tuibird. This project exists specifically to make installing Slowfetch on Debian and Ubuntu systems straightforward and consistent.

Slowfetch repository: https://github.com/tuibird/Slowfetch  
tuibird’s GitHub profile: https://github.com/tuibird

## One‑Line Installer

Run the builder directly from your terminal:

```
bash <(curl -s https://raw.githubusercontent.com/MurderFromMars/Slowfetch-Deb-Builder/main/SlowfetchBuild.sh)
```
This command downloads the script, builds Slowfetch from source, generates a Debian package, and places the finished file in your Downloads directory.

## Purpose

This script is designed exclusively for building and packaging Slowfetch. It is not intended as a general Rust packaging tool. Its goal is to automate the process of producing a clean `.deb` installer for Slowfetch on Debian‑based systems.

## What the Script Does

• Checks for required system dependencies  
• Installs missing packages automatically  
• Ensures Rust and cargo‑deb are available  
• Clones the official Slowfetch repository  
• Extracts metadata from Cargo.toml  
• Injects Debian metadata if it is missing  
• Builds Slowfetch in release mode  
• Generates a `.deb` package using cargo‑deb  
• Saves the final package to the user’s Downloads directory  
• Cleans up temporary files after completion  

## Requirements

The script supports Debian and Ubuntu systems. It requires:

• A Debian or Ubuntu environment  
• Sudo access  
• An active internet connection  

The script installs the following if missing:

• curl  
• git  
• build-essential  
• pkg-config  
• libssl-dev  
• jq  
• Rust toolchain  
• cargo-deb  

## Debian Metadata

If Slowfetch does not include a Debian metadata block, the script inserts one using the following structure:

[package.metadata.deb]
name = "slowfetch"
maintainer = "MurderFromMars <murderfrommars@example.com>"
license = "<license>"
homepage = "<homepage>"
depends = "${shlibs:Depends}, ${misc:Depends}"
section = "utils"
priority = "optional"
extended-description = "<description>"
assets = [
  ["target/release/slowfetch", "usr/bin/", "755"],
]

## Manual Usage

If you prefer to clone this repository and run the script manually:

git clone https://github.com/MurderFromMars/Slowfetch-Deb-Builder
cd Slowfetch-Deb-Builder
chmod +x SlowfetchBuild.sh
./SlowfetchBuild.sh

## Output

After a successful build, the script reports the location of the generated `.deb` file in the user’s Downloads directory.

## Acknowledgment

Slowfetch is created and maintained by tuibird. This builder is an independent companion script intended to simplify packaging Slowfetch for Debian‑based systems.

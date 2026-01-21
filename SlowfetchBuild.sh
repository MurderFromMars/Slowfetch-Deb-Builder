#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/tuibird/Slowfetch.git"
PKG_NAME="slowfetch"
MAINTAINER_NAME="MurderFromMars"
MAINTAINER_EMAIL="murderfrommars@example.com"

# Colors
GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RESET="\e[0m"

log() {
  echo -e "${BLUE}==>${RESET} $1"
}

success() {
  echo -e "${GREEN}✔${RESET} $1"
}

warn() {
  echo -e "${YELLOW}!${RESET} $1"
}

WORKDIR="$(mktemp -d)"
log "Working in temporary directory: $WORKDIR"
trap 'rm -rf "$WORKDIR"' EXIT

# -----------------------------
# Dependency checks
# -----------------------------
log "Checking system dependencies..."

need_update=false
MISSING_DEPS=()

check_dep() {
  if ! dpkg -s "$1" >/dev/null 2>&1; then
    warn "Missing: $1"
    need_update=true
    MISSING_DEPS+=("$1")
  fi
}

check_dep curl
check_dep git
check_dep build-essential
check_dep pkg-config
check_dep libssl-dev
check_dep jq

if [ "$need_update" = true ]; then
  log "Installing missing dependencies..."
  sudo apt update
  sudo apt install -y "${MISSING_DEPS[@]}"
else
  success "All apt dependencies already installed"
fi

# -----------------------------
# Rust + cargo-deb
# -----------------------------
log "Checking Rust toolchain..."

if ! command -v cargo >/dev/null 2>&1; then
  warn "Rust not found — installing..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  success "Rust already installed"
fi

if ! command -v cargo-deb >/dev/null 2>&1; then
  warn "cargo-deb missing — installing..."
  cargo install cargo-deb --locked
else
  success "cargo-deb already installed"
fi

# -----------------------------
# Clone repo
# -----------------------------
log "Cloning repository..."
cd "$WORKDIR"
git clone --depth 1 "$REPO_URL" "$PKG_NAME"
cd "$PKG_NAME"

# -----------------------------
# Metadata extraction
# -----------------------------
log "Extracting Cargo metadata..."

extract_field() {
  local field="$1"
  local value
  value=$(grep -E "^$field" Cargo.toml | head -n1 | cut -d'"' -f2 || true)
  echo "${value:-UNKNOWN}"
}

NAME=$(extract_field name)
VERSION=$(extract_field version)
DESCRIPTION=$(extract_field description)
LICENSE=$(extract_field license)
HOMEPAGE=$(extract_field homepage)

AUTHORS=$(grep -E '^authors' Cargo.toml | sed -E 's/authors =

\[(.*)\]

/\1/' | tr -d '"' || true)
AUTHORS="${AUTHORS:-UNKNOWN}"

success "Metadata loaded"

# -----------------------------
# Add Debian metadata if missing
# -----------------------------
if ! grep -q '^

\[package.metadata.deb\]

' Cargo.toml; then
  log "Injecting Debian metadata..."

  cat >> Cargo.toml <<EOF

[package.metadata.deb]
name = "$PKG_NAME"
maintainer = "$MAINTAINER_NAME <$MAINTAINER_EMAIL>"
license = "$LICENSE"
homepage = "$HOMEPAGE"
depends = "\${shlibs:Depends}, \${misc:Depends}"
section = "utils"
priority = "optional"
extended-description = "$DESCRIPTION"
assets = [
  ["target/release/$PKG_NAME", "usr/bin/", "755"],
]
EOF

  success "Debian metadata added"
else
  success "Debian metadata already present"
fi

# -----------------------------
# Build
# -----------------------------
log "Building release binary..."
cargo build --release

log "Building Debian package..."
cargo deb

# -----------------------------
# Move .deb to Downloads
# -----------------------------
DEB_FILE="$(ls target/debian/*.deb | head -n 1)"
mkdir -p "$HOME/Downloads"
cp "$DEB_FILE" "$HOME/Downloads/"

echo
success "Debian package built successfully"
success "Saved to: $HOME/Downloads/$(basename "$DEB_FILE")"
echo

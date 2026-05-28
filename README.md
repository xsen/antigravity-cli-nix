# Antigravity CLI Nix Flake

[![Update Antigravity CLI](https://github.com/xsen/antigravity-cli-nix/actions/workflows/update.yml/badge.svg)](https://github.com/xsen/antigravity-cli-nix/actions/workflows/update.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![NixOS](https://img.shields.io/badge/NixOS-Standard-blue.svg)](https://nixos.org)

A modern, auto-updating Nix flake for [Antigravity CLI](https://antigravity.google) — Google's Go-based terminal user interface (TUI) agent client.

## 🚀 Why this Flake?

- **⚡ Bleeding Edge**: Automatically checks for updates from Google Cloud Storage every 24 hours.
- **✅ Verified Hashes**: Securely prefetches and calculates SRI hashes for all platforms.
- **🐧 NixOS Ready**: Pre-configured with `autoPatchelfHook` for immediate use on NixOS.
- **💻 Multi-Arch**: Supports `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, and `aarch64-darwin`.

> **Note**: This package is named `antigravity-cli` to distinguish it from other tools. The main binary is available as `agy`.

---

## 📦 Installation

### 1. Add to your Flake inputs

```nix
{
  inputs = {
    antigravity-cli.url = "github:xsen/antigravity-cli-nix";
  };

  outputs = { self, nixpkgs, antigravity-cli, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            antigravity-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
          ];
        })
      ];
    };
  };
}
```

### 2. Quick Run (Try it now)

```bash
nix run github:xsen/antigravity-cli-nix
```

---

## 🛠 Maintenance & Automation

The project is fully autonomous. A GitHub Action runs daily to:

1. Query Google's storage manifests for new releases.
2. Update `meta.json` with the latest version, build ID, and integrity hashes.
3. Commit and push updates automatically.

To manually trigger an update (requires Nix):

```bash
nix run .#update
```

---

## 📜 License

This flake is licensed under the **MIT License**.
The `antigravity-cli` binary itself is proprietary software by Google and is subject to their terms (**unfree license**).

---

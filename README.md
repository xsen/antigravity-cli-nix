# Antigravity CLI Nix Flake

A Nix flake for [Antigravity CLI](https://antigravity.google) (Google's Go-based TUI agent client) with an automated updater. This flake allows you to stay on the bleeding edge without waiting for updates in `nixpkgs`.

## Features

- **Automated Updates**: Stay updated with `nix run .#update`.
- **NixOS Compatible**: Uses `autoPatchelfHook` for seamless execution on NixOS.
- **Multi-Platform**: Supports `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, and `aarch64-darwin`.
- **SRI Hashes**: Uses modern SRI hashes for integrity verification.

## Installation

### Add to your `flake.nix`

```nix
{
  inputs = {
    antigravity.url = "github:xsen/antigravity-cli-nix";
    # OR for local testing:
    # antigravity.url = "git+file:///path/to/your/repo";
  };

  outputs = { self, nixpkgs, antigravity, ... }: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [
            antigravity.packages.${pkgs.system}.default
          ];
        })
      ];
    };
  };
}
```

### Try without installing

```bash
nix run github:xsen/antigravity-cli-nix
```

## Maintenance

### Updating hashes

To fetch the latest version from Google Storage and update `meta.json` with new hashes:

```bash
nix run .#update
```

This script:
1. Queries the Google Storage JSON API for the latest version and build ID.
2. Prefetches the archives for all supported platforms.
3. Calculates SRI hashes (handling the single-file archive quirk in Nix).
4. Updates `meta.json`.

## License

This flake is licensed under the MIT License. The `antigravity-cli` binary itself is subject to Google's terms (unfree license).

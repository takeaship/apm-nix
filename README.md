# apm-nix

`apm-nix` packages the official [Microsoft APM](https://github.com/microsoft/apm)
binary bundles as a reusable Nix flake. It supports Linux and macOS on x86_64
and ARM64.

## Use

Run APM directly:

```sh
nix run github:takeaship/apm-nix -- --help
```

Or add it as a flake input:

```nix
inputs.apm.url = "github:takeaship/apm-nix";
```

Then install `inputs.apm.packages.${pkgs.system}.default`. The package keeps the
complete upstream bundle in `lib/apm`, exposes `bin/apm`, and adds Git to APM's
`PATH`. Manage upgrades by updating this flake; `apm self-update` cannot modify
the immutable Nix store and is not supported.

## Security and updates

`version.nix` pins one version and a Nix SRI hash for each of the four official
archives. The scheduled/manual workflow reads GitHub's latest-release metadata,
downloads every archive and its `.sha256` sidecar, verifies exact asset names and
hashes, and rejects downgrades. Credential-free validation jobs build and execute
all four packages on native GitHub-hosted Linux and macOS runners. Only after all
validation succeeds does a separate
write-enabled job re-fetch and re-verify all assets, ensure `main` has not moved,
and commit `version.nix`; that job never executes the release binaries.

Permissions are scoped per job, checkout credentials are never persisted, and
the ephemeral `GITHUB_TOKEN` is exposed only to the final push step. Actions are
pinned by full commit SHA and maintained by Dependabot.

### Trust boundary

The release archives, GitHub asset digests, and `.sha256` sidecars are all
published through the same upstream GitHub release. Their agreement detects
corruption but is not independent authentication: anyone who can replace an APM
release can replace all three. Pinning the resulting hashes makes an accepted
release reproducible, but users still trust Microsoft's release pipeline at
ingestion time.

### Validation executes unvetted code

Validation deliberately runs each newly downloaded native binary to check its
reported version. Those jobs have no repository write permission, persist no Git
credentials, and use no Actions cache, but the candidate release still executes
on a GitHub-hosted runner before it has been reviewed.

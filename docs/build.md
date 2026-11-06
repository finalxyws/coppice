# Build Record

## Branch and remote

- Branch: `codex/development`
- Base: `origin/preservation`
- Push target: `origin/codex/development`

## Build workflow

Run the project-local entrypoint from the repository root:

```sh
./script/build_and_run.sh --build
```

The script builds the cross-project targets in dependency order (`M3Subscriptions`,
`CoppiceCore`, then `Coppice`) with a repository-local derived data directory.
It uses `-skipMacroValidation` for the reviewed open-source `M3Data` macro package,
and disables code signing for this local development build. Use `--verify` to build,
launch, and check the running process.

## Artifact

The generated application is retained at:

```text
/Users/sheldon/kaios/source-code/coppice/build/DerivedData/Build/Products/Debug/Coppice.app
```

Related retained build data and logs are under:

```text
/Users/sheldon/kaios/source-code/coppice/build/
```

## Compatibility fixes

- Added the `m3data` package reference to `CoppiceCore`, which previously had
  `M3Data` product references without a package declaration.
- Prebuilt `M3Subscriptions` and `CoppiceCore` before the main app because the
  command-line Xcode workflow does not resolve the repository's cross-project
  workspace dependencies automatically.
- Converted the `Double` polygon coordinates to `CGFloat` before calling the
  existing `toDecimalPlaces` helper in `ImageHotspot.swift`.

## Verification

The Debug build completed successfully with Xcode and the app launch check
reported `Verified running process: Coppice`.

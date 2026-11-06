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

The script creates a temporary workspace containing the three existing Xcode
projects and builds the `Coppice` scheme with a repository-local derived data
directory. This is required so Xcode produces one shared dynamic `M3Data`
framework for both `CoppiceCore` and the app. Building the projects separately
would embed duplicate `M3Data` runtime metadata and crash when `New Project`
initializes Combine publishers. The script uses `-skipMacroValidation` for the
reviewed open-source `M3Data` macro package and disables code signing for this
local development build. Use `--verify` to build, launch, and check the running
process.

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
- Built all cross-project targets through a generated workspace so the app and
  `CoppiceCore` share one embedded `M3Data` framework instead of carrying
  duplicate static copies.
- Converted the `Double` polygon coordinates to `CGFloat` before calling the
  existing `toDecimalPlaces` helper in `ImageHotspot.swift`.

## Verification

The Debug build completed successfully with Xcode and the app launch check
reported `Verified running process: Coppice`.

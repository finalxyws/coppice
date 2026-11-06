#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEME="Coppice"
APP_NAME="Coppice"
BUNDLE_ID="com.mcubedsw.Coppice"
BUILD_DIR="$ROOT_DIR/build"
WORKSPACE_DIR="$BUILD_DIR/CoppiceBuild.xcworkspace"
WORKSPACE_PATH="$WORKSPACE_DIR"
DERIVED_DATA_DIR="$BUILD_DIR/DerivedData"
PACKAGE_DIR="$BUILD_DIR/SourcePackages"
APP_BUNDLE="$DERIVED_DATA_DIR/Build/Products/Debug/$APP_NAME.app"

pkill -x "$APP_NAME" >/dev/null 2>&1 || true

mkdir -p "$WORKSPACE_DIR"
cat > "$WORKSPACE_DIR/contents.xcworkspacedata" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Workspace version="1.0">
  <FileRef location="group:../Coppice/Coppice.xcodeproj" />
  <FileRef location="group:../CoppiceCore/CoppiceCore.xcodeproj" />
  <FileRef location="group:../M3Subscriptions/M3Subscriptions.xcodeproj" />
</Workspace>
EOF

xcodebuild \
  -workspace "$WORKSPACE_PATH" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  -clonedSourcePackagesDirPath "$PACKAGE_DIR" \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO \
  build

if [[ ! -d "$APP_BUNDLE" ]]; then
  echo "Build succeeded but app bundle was not found at $APP_BUNDLE" >&2
  exit 1
fi

M3DATA_FRAMEWORK="$(find "$APP_BUNDLE/Contents/Frameworks" -maxdepth 1 -type d -name 'M3Data_*_PackageProduct.framework' -print -quit)"
if [[ -z "$M3DATA_FRAMEWORK" ]]; then
  echo "Build succeeded but the shared M3Data framework was not embedded in $APP_BUNDLE" >&2
  exit 1
fi

case "$MODE" in
  run)
    /usr/bin/open -n "$APP_BUNDLE"
    ;;
  --debug|debug)
    lldb -- "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
    ;;
  --logs|logs)
    /usr/bin/open -n "$APP_BUNDLE"
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    /usr/bin/open -n "$APP_BUNDLE"
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    /usr/bin/open -n "$APP_BUNDLE"
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    echo "Verified running process: $APP_NAME"
    ;;
  --build|build)
    echo "Built app: $APP_BUNDLE"
    ;;
  *)
    echo "usage: $0 [run|--build|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac

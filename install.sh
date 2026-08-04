#!/bin/bash
set -euo pipefail

# Full setup for csv_to_drive — run this on each Mac (Mac mini, MacBook, etc.)

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$HOME/Library/Services"
WORKFLOW_NAME="UploadToSheets.workflow"
APP_SRC="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Csv_to_Sheets_rbz.app"
APP_DEST="$HOME/Applications/Upload to Sheets.app"
BUNDLE_ID="com.apple.automator.Csv-to-Sheets-rbz"
CONTENT_TYPE="public.comma-separated-values-text"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

echo "==> Setting up Python virtual environment..."
python3 -m venv "$DIR/.venv"
"$DIR/.venv/bin/pip" install -r "$DIR/requirements.txt"

echo "==> Ensuring launcher.sh is executable..."
chmod +x "$DIR/launcher.sh"

echo "==> Installing Quick Action (right-click -> Upload to Sheets)..."
mkdir -p "$SERVICES_DIR"
cp -R "$DIR/$WORKFLOW_NAME" "$SERVICES_DIR/"
if [[ -d "$SERVICES_DIR/Upload to Sheets.workflow" ]]; then
  rm -rf "$SERVICES_DIR/Upload to Sheets.workflow"
fi
"$LSREGISTER" -f "$SERVICES_DIR/$WORKFLOW_NAME" 2>/dev/null || true

echo "==> Installing default app for double-click (~/Applications/Upload to Sheets.app)..."
if [[ ! -d "$APP_SRC" ]]; then
  echo "Warning: $APP_SRC not found."
  echo "         Skipping double-click setup. Ensure Csv_to_Sheets_rbz.app is in iCloud Drive."
else
  mkdir -p "$HOME/Applications"
  rm -rf "$APP_DEST"
  cp -R "$APP_SRC" "$APP_DEST"

  python3 << PY
import plistlib
from pathlib import Path

plist_path = Path("$APP_DEST/Contents/Info.plist")
with open(plist_path, "rb") as f:
    data = plistlib.load(f)

data["CFBundleName"] = "Upload to Sheets"
csv_type = {
    "CFBundleTypeExtensions": ["csv"],
    "CFBundleTypeName": "Comma Separated Values",
    "CFBundleTypeRole": "Viewer",
    "LSHandlerRank": "Owner",
    "LSItemContentTypes": ["$CONTENT_TYPE"],
}
existing = data.get("CFBundleDocumentTypes", [])
if not any("csv" in t.get("CFBundleTypeExtensions", []) for t in existing):
    existing.insert(0, csv_type)
data["CFBundleDocumentTypes"] = existing
with open(plist_path, "wb") as f:
    plistlib.dump(data, f)
PY

  echo "==> Setting Upload to Sheets as default app for .csv files..."
  python3 << PY
import plistlib
from pathlib import Path

plist_path = Path.home() / "Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
plist_path.parent.mkdir(parents=True, exist_ok=True)
data = {}
if plist_path.exists():
    with open(plist_path, "rb") as f:
        data = plistlib.load(f)

handlers = data.get("LSHandlers", [])
handlers = [h for h in handlers if h.get("LSHandlerContentType") != "$CONTENT_TYPE"]
handlers.append({"LSHandlerContentType": "$CONTENT_TYPE", "LSHandlerRoleAll": "$BUNDLE_ID"})
data["LSHandlers"] = handlers
with open(plist_path, "wb") as f:
    plistlib.dump(data, f)
PY

  "$LSREGISTER" -f "$APP_DEST" 2>/dev/null || true
fi

killall Finder 2>/dev/null || true

echo ""
echo "Installation complete."
echo ""
if [[ ! -f "$DIR/credentials.json" ]]; then
  echo "NEXT: Add Google credentials to $DIR/credentials.json"
  echo "      See README.md for Google Cloud Console steps."
  echo ""
fi
if [[ ! -f "$DIR/token.pickle" ]]; then
  echo "NEXT: Authenticate once on this Mac:"
  echo "      $DIR/launcher.sh $DIR/test.csv"
  echo ""
fi

echo "Usage on this Mac:"
echo "  • Double-click any .csv file"
echo "  • Right-click -> Upload to Sheets (best for downloaded files)"
echo ""

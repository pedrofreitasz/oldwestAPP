#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -d "$ROOT/android" || -d "$ROOT/ios" ]]; then
  echo "As pastas android/ ou ios/ já existem; não vou sobrescrevê-las." >&2
  exit 1
fi
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK não encontrado. Instale Flutter e tente novamente." >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
flutter create --project-name=oldwest --platforms=android,ios "$TMP/native_shell"
cp -R "$TMP/native_shell/android" "$ROOT/android"
cp -R "$TMP/native_shell/ios" "$ROOT/ios"

# Permite HTTP somente na variante debug para testar a API local.
mkdir -p "$ROOT/android/app/src/debug"
cat > "$ROOT/android/app/src/debug/AndroidManifest.xml" <<'XML'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application android:usesCleartextTraffic="true" />
</manifest>
XML

# Permite conexões locais HTTP no simulador iOS durante o desenvolvimento.
python3 - "$ROOT/ios/Runner/Info.plist" <<'PY'
import plistlib
import sys
from pathlib import Path

path = Path(sys.argv[1])
with path.open('rb') as source:
    data = plistlib.load(source)
settings = data.setdefault('NSAppTransportSecurity', {})
settings['NSAllowsLocalNetworking'] = True
with path.open('wb') as target:
    plistlib.dump(data, target)
PY

echo "Plataformas Android/iOS adicionadas. Execute flutter pub get e flutter run."
echo "A exceção HTTP está limitada ao debug; use HTTPS em produção."

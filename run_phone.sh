#!/usr/bin/env bash
# Lance l'app sur un téléphone Android branché en USB.
# Le tunnel « adb reverse » fait pointer 127.0.0.1:8080 du téléphone vers le backend du PC ;
# il disparaît à chaque débranchement, d'où sa recréation systématique ici.
set -euo pipefail

ADB="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
PORT=8080

cd "$(dirname "$0")"

if ! curl -s -o /dev/null "http://localhost:$PORT/api/programmes-fonciers"; then
  echo "⚠  Le backend ne répond pas sur le port $PORT : lancez Foncierback d'abord."
fi

"$ADB" reverse "tcp:$PORT" "tcp:$PORT"
echo "✓ Tunnel USB actif (téléphone 127.0.0.1:$PORT → PC :$PORT)"

flutter run --dart-define=API_BASE_URL=http://127.0.0.1:$PORT/api "$@"

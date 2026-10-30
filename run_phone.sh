#!/usr/bin/env bash
# Lance l'app sur un téléphone Android branché en USB (avec support multi-appareils).
# Usage : ./run_phone.sh [NUMERO_DE_SERIE] [options flutter additionnelles...]
# Exemple : ./run_phone.sh 0826605000010453
set -euo pipefail

ADB="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
PORT=8080

cd "$(dirname "$0")"

# Gestion du numéro de série passé en paramètre
ADB_ARGS=""
FLUTTER_ARGS=""

if [ $# -gt 0 ] && [[ ! "$1" =~ ^-+ ]]; then
  SERIAL="$1"
  shift # Décale les arguments pour ne garder que la suite pour flutter
  ADB_ARGS="-s $SERIAL"
  FLUTTER_ARGS="-d $SERIAL"
  echo "📱 Cible configurée pour l'appareil : $SERIAL"
else
  echo "📱 Aucun appareil spécifique spécifié, utilisation de l'appareil par défaut..."
fi

if ! curl -s -o /dev/null "http://localhost:$PORT/api/programmes-fonciers"; then
  echo "⚠  Le backend ne répond pas sur le port $PORT : lancez Foncierback d'abord."
fi

# Application du tunnel adb sur le bon appareil
if [ -n "$ADB_ARGS" ]; then
  "$ADB" $ADB_ARGS reverse "tcp:$PORT" "tcp:$PORT"
else
  "$ADB" reverse "tcp:$PORT" "tcp:$PORT"
fi
echo "✓ Tunnel USB actif (127.0.0.1:$PORT → PC :$PORT)"

# Lancement de Flutter sur le bon appareil
flutter run $FLUTTER_ARGS --dart-define=API_BASE_URL=http://127.0.0.1:$PORT/api "$@"
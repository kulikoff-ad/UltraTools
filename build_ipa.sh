#!/usr/bin/env bash
#
# Сборка UltraTools.ipa — запускать на macOS с установленным Xcode 15+.
#
# Использование:
#   ./build_ipa.sh                     # подпись Developer ID (по умолчанию)
#   ./build_ipa.sh ad-hoc              # ad-hoc (установка на свои устройства)
#   ./build_ipa.sh app-store          # подготовка в App Store
#
# Переменные окружения:
#   TEAM_ID  — идентификатор вашей команды Apple (10 символов).
#              Пример: TEAM_ID=ABCDE12345 ./build_ipa.sh

set -euo pipefail

cd "$(dirname "$0")"

METHOD="${1:-developer-id}"
PROJECT="UltraTools.xcodeproj"
SCHEME="UltraTools"
BUILD_DIR="build"
ARCHIVE="$BUILD_DIR/UltraTools.xcarchive"
EXPORT_PLIST="$BUILD_DIR/ExportOptions.plist"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "✖ xcodebuild не найден." >&2
  echo "  Скрипт нужно запускать на macOS с установленным Xcode (App Store → Xcode, затем: xcode-select --install)." >&2
  exit 1
fi

echo "==> 1/3 Архивация проекта (Release, generic/platform=iOS)..."

EXTRA=()
if [[ -n "${TEAM_ID:-}" ]]; then
  EXTRA=(DEVELOPMENT_TEAM="$TEAM_ID")
fi

xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE" \
  ${EXTRA[@]+"${EXTRA[@]}"}

case "$METHOD" in
  developer-id)
    cat > "$EXPORT_PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>developer-id</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
EOF
    ;;
  ad-hoc)
    cat > "$EXPORT_PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>ad-hoc</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
EOF
    ;;
  app-store)
    cat > "$EXPORT_PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store</string>
	<key>uploadSymbols</key>
	<true/>
</dict>
</plist>
EOF
    ;;
  *)
    echo "✖ Неизвестный метод: $METHOD (варианты: developer-id, ad-hoc, app-store)" >&2
    exit 1
    ;;
esac

echo "==> 2/3 Экспорт IPA (метод: $METHOD)..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -exportPath "$BUILD_DIR"

IPA="$BUILD_DIR/UltraTools.ipa"
if [[ -f "$IPA" ]]; then
  SIZE=$(du -h "$IPA" | cut -f1)
  echo ""
  echo "✅ Готово! IPA: $IPA ($SIZE)"
  echo ""
  echo "Установка на iPhone:"
  echo "  • AltStore / Sideloadly / TrollStore — просто откройте файл .ipa"
  echo "  • TestFlight — при методе app-store и учётной записи разработчика"
else
  echo "✖ IPA не найдена: $IPA" >&2
  exit 1
fi

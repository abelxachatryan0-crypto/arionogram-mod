#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "===================================="
echo " Arionogram Mod Setup"
echo " Android 11 / 12 / 13 / 14"
echo "===================================="

# Проверяем структуру проекта
SETTINGS="TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java"

if [[ ! -f "$SETTINGS" ]]; then
    echo "ERROR: SettingsActivity.java not found."
    exit 1
fi

# Создаём отдельный каталог ресурсов мода
RES="TMessagesProj/src/main/res/drawable"
mkdir -p "$RES"

# Полупрозрачная стеклянная карточка.
# Работает без API, доступных только на новых Android.
cat > "$RES/arionogram_glass.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="20dp" />
    <solid android:color="#26FFFFFF" />
    <stroke
        android:width="1dp"
        android:color="#40FFFFFF" />
    <padding
        android:left="12dp"
        android:top="10dp"
        android:right="12dp"
        android:bottom="10dp" />
</shape>
XML

# Анимация мягкого сжатия и подпрыгивания.
cat > "$RES/arionogram_button_press.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="180"
    android:interpolator="@android:anim/overshoot_interpolator">
    <scale
        android:fromXScale="0.96"
        android:toXScale="1.0"
        android:fromYScale="0.96"
        android:toYScale="1.0"
        android:pivotX="50%"
        android:pivotY="50%" />
</set>
XML

# Проверяем, что ресурсы созданы.
test -s "$RES/arionogram_glass.xml"
test -s "$RES/arionogram_button_press.xml"

echo "Glass drawable created."
echo "Button animation resource created."
echo
echo "Compatibility target: Android 11-14."
echo "No app Java files were modified."
echo "Setup finished."

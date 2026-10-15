#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "=== Arionogram Mod ==="
echo "Preparing Liquid Glass resources for Android 11-14"

SETTINGS="TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java"
RES="TMessagesProj/src/main/res/drawable"

if [[ ! -f "$SETTINGS" ]]; then
    echo "ERROR: SettingsActivity.java not found"
    exit 1
fi

mkdir -p "$RES"

cat > "$RES/arionogram_glass.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="22dp" />
    <solid android:color="#26FFFFFF" />
    <stroke
        android:width="1dp"
        android:color="#55FFFFFF" />
</shape>
XML

cat > "$RES/arionogram_glass_dark.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="22dp" />
    <solid android:color="#33182030" />
    <stroke
        android:width="1dp"
        android:color="#44FFFFFF" />
</shape>
XML

cat > "$RES/arionogram_button_press.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="180"
    android:interpolator="@android:anim/overshoot_interpolator">
    <scale
        android:fromXScale="0.94"
        android:toXScale="1.0"
        android:fromYScale="0.94"
        android:toYScale="1.0"
        android:pivotX="50%"
        android:pivotY="50%" />
</set>
XML

cat > "$RES/arionogram_fade_in.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<alpha xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="220"
    android:fromAlpha="0.0"
    android:toAlpha="1.0" />
XML

echo "Created:"
echo " - arionogram_glass.xml"
echo " - arionogram_glass_dark.xml"
echo " - arionogram_button_press.xml"
echo " - arionogram_fade_in.xml"
echo
echo "Resources prepared. UI integration is not yet enabled."

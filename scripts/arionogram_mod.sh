#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

FILE="TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java"
RES="TMessagesProj/src/main/res/drawable"

test -f "$FILE" || {
    echo "ERROR: SettingsActivity.java not found"
    exit 1
}

mkdir -p "$RES"

cat > "$RES/arionogram_glass.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="20dp"/>
    <solid android:color="#26FFFFFF"/>
    <stroke android:width="1dp" android:color="#40FFFFFF"/>
</shape>
XML

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
        android:pivotY="50%"/>
</set>
XML

python3 - <<'PY'
from pathlib import Path

p = Path("TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java")
s = p.read_text()

# Добавляем стандартную кнопку через UItem.asButton (совместимо с официальным TG)
button_anchor = '        items.add(UItem.asHeader(getString(R.string.SettingsHelp)));'
button = '''        items.add(UItem.asButton(26, R.drawable.msg_settings, "Настройки мода", "Arionogram • Дополнительные функции"));
        items.add(UItem.asShadow(null));
'''

if '"Настройки мода"' not in s:
    if button_anchor not in s:
        raise SystemExit("ERROR: Settings list anchor not found; no changes made.")
    s = s.replace(button_anchor, button + button_anchor, 1)

# Добавляем обработчик нажатия на кнопку
case_anchor = '        switch (item.id) {'
case_code = '''        switch (item.id) {
            case 26: {
                android.content.SharedPreferences prefs =
                    org.telegram.messenger.ApplicationLoader.applicationContext
                    .getSharedPreferences(
                        "arionogram_mod",
                        android.content.Context.MODE_PRIVATE
                    );

                String[] options = {
                    "Показывать удалённые сообщения",
                    "Liquid Glass",
                    "Пружинные анимации"
                };

                boolean[] checked = {
                    prefs.getBoolean("show_deleted_messages", false),
                    prefs.getBoolean("liquid_glass", false),
                    prefs.getBoolean("jelly_animations", false)
                };

                new android.app.AlertDialog.Builder(getParentActivity())
                    .setTitle("Настройки мода")
                    .setMultiChoiceItems(options, checked,
                        (dialog, which, enabled) -> {
                            String key;
                            if (which == 0) {
                                key = "show_deleted_messages";
                            } else if (which == 1) {
                                key = "liquid_glass";
                            } else {
                                key = "jelly_animations";
                            }
                            prefs.edit().putBoolean(key, enabled).apply();
                        })
                    .setPositiveButton("Готово", null)
                    .show();
                return;
            }
'''

if 'case 26: {' not in s:
    if case_anchor not in s:
        raise SystemExit("ERROR: Click handler not found; no changes made.")
    s = s.replace(case_anchor, case_code, 1)

p.write_text(s)
print("OK: Arionogram mod button and settings added.")
PY

echo "Arionogram patch completed."

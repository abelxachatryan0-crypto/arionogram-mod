#!/usr/bin/env bash
set -euo pipefail

FILE="TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java"

if [ ! -f "$FILE" ]; then
  echo "ОШИБКА: не найден $FILE"
  exit 1
fi

python3 - "$FILE" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
s = p.read_text(encoding="utf-8")

button = 'items.add(SettingCell.Factory.of(9901, 0xFF5686E1, 0xFF3867B7, 0, "Настройки мода"));'

if button not in s:
    marker = "        items.add(UItem.asCustomShadow(versionView));"
    if marker not in s:
        raise SystemExit("Не найдено место для кнопки. Файл не изменён.")
    s = s.replace(marker, "        " + button + "\n" + marker, 1)

case = '''            case 9901:
                Toast.makeText(getContext(),
                    "Настройки мода: следующий этап разработки",
                    Toast.LENGTH_LONG).show();
                break;
'''

if "case 9901:" not in s:
    marker = "        switch (item.id) {"
    if marker not in s:
        raise SystemExit("Не найден обработчик нажатий. Файл не изменён.")
    s = s.replace(marker, marker + "\n" + case, 1)

p.write_text(s, encoding="utf-8")
print("Кнопка «Настройки мода» добавлена.")
PY

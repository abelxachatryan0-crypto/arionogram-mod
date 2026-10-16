#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

SETTINGS_FILE="TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java"
MOD_DIR="TMessagesProj/src/main/java/org/telegram/ui/Arionogram"

test -f "$SETTINGS_FILE" || {
    echo "ERROR: SettingsActivity.java not found"
    exit 1
}

# 1. Отключаем google-services плагин в Gradle, чтобы предотвратить ошибку 'processAfatDebugGoogleServices'
python3 - <<'PY'
import re
from pathlib import Path

app_gradle = Path("TMessagesProj_App/build.gradle")
if app_gradle.exists():
    content = app_gradle.read_text()
    content = re.sub(r"^.*google-services.*$", "", content, flags=re.MULTILINE)
    content = re.sub(r"^.*apply plugin: 'com.google.gms.google-services'.*$", "", content, flags=re.MULTILINE)
    app_gradle.write_text(content)
    print("OK: Removed google-services plugin from TMessagesProj_App/build.gradle")
PY

# 2. Меняем заголовок "Telegram" в ресурсах приложения на "Arionogram"
find TMessagesProj/src/main/res TMessagesProj_App/src \
  -type f -name 'strings.xml' -print0 2>/dev/null |
  xargs -0 -r sed -i \
    -e 's/<string name="AppName">Telegram<\/string>/<string name="AppName">Arionogram<\/string>/g' \
    -e 's/>Telegram</>Arionogram</g' || true

# 3. Создаем папку мода
mkdir -p "$MOD_DIR"

# 4. Создаем экран ArionogramSettingsActivity.java со свойствами мода
cat > "$MOD_DIR/ArionogramSettingsActivity.java" <<'JAVA'
package org.telegram.ui.Arionogram;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.Toast;

import org.telegram.messenger.ApplicationLoader;
import org.telegram.messenger.R;
import org.telegram.ui.ActionBar.BaseFragment;
import org.telegram.ui.ActionBar.ActionBar;
import org.telegram.ui.ActionBar.Theme;
import org.telegram.ui.Cells.HeaderCell;
import org.telegram.ui.Cells.TextCell;
import org.telegram.ui.Cells.TextCheckCell;
import org.telegram.ui.Components.LayoutHelper;
import org.telegram.ui.Components.RecyclerListView;

import androidx.appcompat.app.AlertDialog;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

public class ArionogramSettingsActivity extends BaseFragment {

    private RecyclerListView listView;
    private ListAdapter listAdapter;
    
    private int rowCount;
    private int headerRow;
    private int liquidGlassRow;
    private int jellyAnimRow;
    private int colorPickerRow;

    @Override
    public View createView(Context context) {
        actionBar.setBackButtonImage(R.drawable.ic_ab_back);
        actionBar.setAllowOverlayTitle(true);
        actionBar.setTitle("Настройки мода");
        actionBar.setActionBarMenuOnItemClick(new ActionBar.ActionBarMenuOnItemClick() {
            @Override
            public void onItemClick(int id) {
                if (id == -1) {
                    finishFragment();
                }
            }
        });

        fragmentView = new FrameLayout(context);
        FrameLayout frameLayout = (FrameLayout) fragmentView;
        frameLayout.setBackgroundColor(Theme.getColor(Theme.key_windowBackgroundGray));

        listView = new RecyclerListView(context);
        listView.setLayoutManager(new LinearLayoutManager(context, LinearLayoutManager.VERTICAL, false));
        listView.setAdapter(listAdapter = new ListAdapter(context));
        
        frameLayout.addView(listView, LayoutHelper.createFrame(LayoutHelper.MATCH_PARENT, LayoutHelper.MATCH_PARENT));

        listView.setOnItemClickListener((view, position) -> {
            SharedPreferences prefs = ApplicationLoader.applicationContext.getSharedPreferences("arionogram_mod", Context.MODE_PRIVATE);
            if (position == liquidGlassRow && view instanceof TextCheckCell) {
                TextCheckCell cell = (TextCheckCell) view;
                boolean val = !cell.isChecked();
                cell.setChecked(val);
                prefs.edit().putBoolean("liquid_glass", val).apply();
                Toast.makeText(context, "Перезапустите приложение для применения", Toast.LENGTH_SHORT).show();
            } else if (position == jellyAnimRow && view instanceof TextCheckCell) {
                TextCheckCell cell = (TextCheckCell) view;
                boolean val = !cell.isChecked();
                cell.setChecked(val);
                prefs.edit().putBoolean("jelly_animations", val).apply();
                Toast.makeText(context, "Перезапустите приложение для применения", Toast.LENGTH_SHORT).show();
            } else if (position == colorPickerRow) {
                showColorPickerDialog(context, prefs);
            }
        });

        updateRows();
        return fragmentView;
    }

    private void showColorPickerDialog(Context context, SharedPreferences prefs) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Select theme color (RGB)");

        LinearLayout layout = new LinearLayout(context);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(50, 20, 50, 20);

        final EditText redInput = new EditText(context);
        redInput.setHint("Red (0-255)");
        layout.addView(redInput);

        final EditText greenInput = new EditText(context);
        greenInput.setHint("Green (0-255)");
        layout.addView(greenInput);

        final EditText blueInput = new EditText(context);
        blueInput.setHint("Blue (0-255)");
        layout.addView(blueInput);

        builder.setView(layout);

        builder.setPositiveButton("Применить", (dialog, which) -> {
            try {
                int r = Integer.parseInt(redInput.getText().toString().trim());
                int g = Integer.parseInt(greenInput.getText().toString().trim());
                int b = Integer.parseInt(blueInput.getText().toString().trim());

                r = Math.max(0, Math.min(255, r));
                g = Math.max(0, Math.min(255, g));
                b = Math.max(0, Math.min(255, b));

                int colorHex = Color.rgb(r, g, b);
                prefs.edit().putInt("theme_bg_color", colorHex).apply();
                Toast.makeText(context, "Перезапустите приложение для смены цвета", Toast.LENGTH_SHORT).show();
            } catch (Exception e) {
                Toast.makeText(context, "Неверный формат RGB", Toast.LENGTH_SHORT).show();
            }
        });

        builder.setNegativeButton("Отмена", null);
        builder.show();
    }

    private void updateRows() {
        rowCount = 0;
        headerRow = rowCount++;
        liquidGlassRow = rowCount++;
        jellyAnimRow = rowCount++;
        colorPickerRow = rowCount++;
        if (listAdapter != null) {
            listAdapter.notifyDataSetChanged();
        }
    }

    private class ListAdapter extends RecyclerListView.SelectionAdapter {
        private final Context mContext;

        public ListAdapter(Context context) {
            mContext = context;
        }

        @Override
        public int getItemCount() {
            return rowCount;
        }

        @Override
        public boolean isEnabled(RecyclerView.ViewHolder holder) {
            int pos = holder.getAdapterPosition();
            return pos == liquidGlassRow || pos == jellyAnimRow || pos == colorPickerRow;
        }

        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            View view;
            if (viewType == 0) {
                view = new HeaderCell(mContext);
            } else if (viewType == 1) {
                view = new TextCheckCell(mContext);
            } else {
                view = new TextCell(mContext);
            }
            return new RecyclerListView.Holder(view);
        }

        @Override
        public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
            SharedPreferences prefs = ApplicationLoader.applicationContext.getSharedPreferences("arionogram_mod", Context.MODE_PRIVATE);
            if (holder.getItemViewType() == 0) {
                ((HeaderCell) holder.itemView).setText("Настройки внешнего вида");
            } else if (holder.getItemViewType() == 1) {
                TextCheckCell cell = (TextCheckCell) holder.itemView;
                if (position == liquidGlassRow) {
                    cell.setTextAndCheck("Liquid Glass", prefs.getBoolean("liquid_glass", false), true);
                } else if (position == jellyAnimRow) {
                    cell.setTextAndCheck("Jelly Animations", prefs.getBoolean("jelly_animations", false), true);
                }
            } else {
                TextCell cell = (TextCell) holder.itemView;
                if (position == colorPickerRow) {
                    int savedColor = prefs.getInt("theme_bg_color", Color.WHITE);
                    String hexStr = String.format("#%06X", (0xFFFFFF & savedColor));
                    cell.setTextAndValue("Select theme color", hexStr, false);
                }
            }
        }

        @Override
        public int getItemViewType(int position) {
            if (position == headerRow) return 0;
            if (position == liquidGlassRow || position == jellyAnimRow) return 1;
            return 2;
        }
    }
}
JAVA

# 5. Подключаем пункт "Настройки мода" в SettingsActivity.java
python3 - <<'PY'
from pathlib import Path

settings_file = Path("TMessagesProj/src/main/java/org/telegram/ui/SettingsActivity.java")
s = settings_file.read_text()
MOD_ID = "9999"

button_anchor = '        items.add(UItem.asHeader(getString(R.string.SettingsHelp)));'
button = f'''        items.add(UItem.asButton({MOD_ID}, "Настройки мода", "Arionogram"));
        items.add(UItem.asShadow(null));
'''

if '"Настройки мода"' not in s:
    if button_anchor not in s:
        button_anchor = 'items.add(UItem.asHeader('
        if button_anchor not in s:
            raise SystemExit("ERROR: Settings list anchor not found.")
    s = s.replace(button_anchor, button + button_anchor, 1)

case_anchor = '        switch (item.id) {'
case_code = f'''        switch (item.id) {{
            case {MOD_ID}: {{
                presentFragment(new org.telegram.ui.Arionogram.ArionogramSettingsActivity());
                return;
            }}
'''

if f'case {MOD_ID}: {{' not in s:
    if case_anchor not in s:
        raise SystemExit("ERROR: Click handler switch not found.")
    s = s.replace(case_anchor, case_code, 1)

settings_file.write_text(s)
print("OK: Integrated into SettingsActivity successfully.")
PY

echo "Script execution finished."

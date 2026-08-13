#!/usr/bin/env bash
# Синхронизация скиллов и агентов из репозитория в места, где они реально работают.
#
# Репозиторий — источник истины. Живая установка (~/.claude) и любые пакеты,
# которые держат копии этих файлов, получают их отсюда.
#
# Использование:
#   scripts/sync-skills.sh                       показать расхождения, ничего не менять
#   scripts/sync-skills.sh --apply               скопировать из репозитория в цели
#   scripts/sync-skills.sh --check ПУТЬ ПУТЬ     добавить свои цели к проверке
#   scripts/sync-skills.sh --apply ПУТЬ          и записать в них тоже
#
# Цель — каталог, внутри которого лежат skills/ и (необязательно) agents/.
# По умолчанию цель одна: ~/.claude (можно переопределить переменной CLAUDE_HOME).
#
# Для дополнительных целей действует правило: переносятся только те файлы,
# которые в цели уже есть. Пакет с десятью скиллами не получит одиннадцатый.

set -euo pipefail

MODE="check"
TARGETS=()

for arg in "$@"; do
  case "$arg" in
    --apply) MODE="apply" ;;
    --check) MODE="check" ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Неизвестный флаг: $arg" >&2; exit 1 ;;
    *) TARGETS+=("$arg") ;;
  esac
done

# Корень репозитория — каталог уровнем выше scripts/
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

if [ ! -d "$REPO_ROOT/skills" ]; then
  echo "Не нашел skills/ в $REPO_ROOT — запусти скрипт из репозитория." >&2
  exit 1
fi

# Первая цель — живая установка, дальше пользовательские
ALL_TARGETS=("$CLAUDE_HOME" "${TARGETS[@]+"${TARGETS[@]}"}")

same=0
copied=0
differ=0
newer=0
missing=0

for target in "${ALL_TARGETS[@]}"; do
  if [ ! -d "$target" ]; then
    echo "ПРОПУСК  $target — каталога нет"
    continue
  fi

  # Живая установка получает все файлы репозитория,
  # дополнительные цели — только те, что у них уже есть.
  if [ "$target" = "$CLAUDE_HOME" ]; then
    only_existing="no"
  else
    only_existing="yes"
  fi

  echo "ЦЕЛЬ  $target"

  for dir in skills agents; do
    [ -d "$REPO_ROOT/$dir" ] || continue

    while IFS= read -r src; do
      rel="${src#$REPO_ROOT/}"
      dst="$target/$rel"

      if [ ! -f "$dst" ]; then
        if [ "$only_existing" = "yes" ]; then
          continue
        fi
        missing=$((missing + 1))
        if [ "$MODE" = "apply" ]; then
          mkdir -p "$(dirname "$dst")"
          cp "$src" "$dst"
          copied=$((copied + 1))
          echo "  СОЗДАН    $rel"
        else
          echo "  НЕТ В ЦЕЛИ  $rel"
        fi
        continue
      fi

      if cmp -s "$src" "$dst"; then
        same=$((same + 1))
        continue
      fi

      differ=$((differ + 1))

      # Файл в цели новее — скорее всего, там правили руками
      # и правка еще не вернулась в репозиторий. Это и есть главный
      # способ разъехаться, поэтому предупреждаем отдельно.
      if [ "$dst" -nt "$src" ]; then
        newer=$((newer + 1))
        echo "  ВНИМАНИЕ  $rel — в цели новее репозитория"
        if [ "$MODE" = "apply" ]; then
          echo "            не перезаписываю. Перенеси правку в репозиторий"
          echo "            или удали файл в цели и запусти снова."
          continue
        fi
      else
        echo "  ОТЛИЧАЕТСЯ  $rel"
      fi

      if [ "$MODE" = "apply" ]; then
        cp "$src" "$dst"
        copied=$((copied + 1))
        echo "  ОБНОВЛЕН  $rel"
      fi
    done < <(find "$REPO_ROOT/$dir" -type f -name "*.md" -o -type f -name "*.sh" | sort)
  done
done

echo
echo "Совпадает: $same. Отличается: $differ (из них новее в цели: $newer). Нет в цели: $missing."

if [ "$MODE" = "apply" ]; then
  echo "Скопировано: $copied."
  if [ "$newer" -gt 0 ]; then
    echo "Часть файлов не тронута: в цели они новее. Разберись с ними вручную."
    exit 2
  fi
else
  if [ "$differ" -gt 0 ] || [ "$missing" -gt 0 ]; then
    echo "Запусти с --apply, чтобы перенести из репозитория."
    exit 1
  fi
fi

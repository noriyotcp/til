#!/bin/bash
# Astro article template generator for macOS

MSG=$(cat <<-EOD
DESCRIPTION
    Create a new Astro article with frontmatter template

    The options are as follows:
    -d +/-val     Adjust the day according to val (e.g., -d +2, -d -3)
    -p DIR        Target directory to create the file in (default: src/content/posts)
    -t TITLE      Custom title for the article (default: date)
    --draft       Create as draft (draft: true)
    --time        Include time in filename (YYYY-MM-DD-HHMM.md)
    --auto        Auto-increment filename if exists (YYYY-MM-DD-2.md, etc.)
    -h            Display this help
EOD
)

# 初期値の設定
DATE=$(date +"%Y-%m-%d")
TARGET_DIR="src/content/posts"
DA_FLAG=0   # -d オプションが指定されたかを追跡
CUSTOM_TITLE=""
IS_DRAFT=false
INCLUDE_TIME=false
AUTO_INCREMENT=false

# コマンドライン引数の解析
while [[ $# -gt 0 ]]; do
  case "$1" in
    -d)
      if [[ $DA_FLAG -eq 1 ]]; then
        echo "-d option cannot be specified more than once"
        echo "$MSG"
        exit 1
      fi
      DA_FLAG=1
      shift
      if [[ "$1" =~ ^((\+|\-)[[:digit:]]+)$ ]]; then
        DATE=$(date -v "$1"d +"%Y-%m-%d")
      else
        echo "Invalid date adjustment value: $1"
        echo "$MSG"
        exit 1
      fi
      shift
      ;;
    -p)
      TARGET_DIR="$2"
      if [[ -z "$TARGET_DIR" ]]; then
        echo "Target directory not specified."
        exit 1
      fi
      shift 2
      ;;
    -t)
      CUSTOM_TITLE="$2"
      if [[ -z "$CUSTOM_TITLE" ]]; then
        echo "Title not specified."
        exit 1
      fi
      shift 2
      ;;
    --draft)
      IS_DRAFT=true
      shift
      ;;
    --time)
      INCLUDE_TIME=true
      shift
      ;;
    --auto)
      AUTO_INCREMENT=true
      shift
      ;;
    -h)
      echo "$MSG"
      exit 0
      ;;
    *)
      echo "Invalid option: $1"
      echo "$MSG"
      exit 1
      ;;
  esac
done

# ディレクトリの検証
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Target directory does not exist: $TARGET_DIR"
  exit 1
fi

# タイトルの設定（カスタムタイトルがない場合は日付を使用）
TITLE=${CUSTOM_TITLE:-$DATE}

# ファイル名の決定
if [[ $INCLUDE_TIME == true ]]; then
  FILENAME="${DATE}-$(date +"%H%M").md"
elif [[ $AUTO_INCREMENT == true ]]; then
  FILENAME="${DATE}.md"
  COUNTER=2
  while [[ -f "$TARGET_DIR/$FILENAME" ]]; do
    FILENAME="${DATE}-${COUNTER}.md"
    ((COUNTER++))
  done
else
  FILENAME="${DATE}.md"
fi

FILE_PATH="$TARGET_DIR/$FILENAME"

# ファイルが既に存在するかチェック（auto-incrementが無効の場合のみ）
if [[ $AUTO_INCREMENT == false && $INCLUDE_TIME == false && -f "$FILE_PATH" ]]; then
  echo "File already exists: $FILE_PATH"
  read -p "Do you want to overwrite it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
  fi
fi

# ファイル作成
cat <<-EOD > "$FILE_PATH"
---
title: "${TITLE}"
date: "$(date +"%Y-%m-%d %H:%M:%S %z")"
last_modified_at: "$(date +"%Y-%m-%d %H:%M:%S %z")"
draft: ${IS_DRAFT}
---

# ${TITLE}

EOD

echo "File created: $FILE_PATH"

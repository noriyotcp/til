#!/bin/bash
# This is for macOS

MSG=$(cat <<-EOD
DESCRIPTION
    The options are as follows:
    -d +/-val     Adjust the day according to val (e.g., -d +2, -d -3)
    -p DIR        Target directory to create the file in
    -h            Display this help
EOD
)

# 初期値の設定
DATE=$(date +"%Y-%m-%d")
TARGET_DIR="."
DA_FLAG=0   # -d オプションが指定されたかを追跡

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

FILE_PATH="$TARGET_DIR/${DATE}-${DATE}.md"

# ファイル作成
cat <<-EOD >> "$FILE_PATH"
---
title: "${DATE}"
date: "$(date +"%Y-%m-%d %H:%M:%S %z")"
last_modified_at: "$(date +"%Y-%m-%d %H:%M:%S %z")"
---

# ${DATE}

EOD

echo "File created: $FILE_PATH"


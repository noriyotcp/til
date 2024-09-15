#!/bin/sh
# This is for macOS

MSG="${BASH_SOURCE:-$0} $(date +"%Y-%m")"

if [ ${#} -eq 0 ]; then
  echo "No args: eg) ${MSG}"
elif [ "${1}" = "-h" ]; then
  echo "${MSG}"
else
  mkdir "${1}"
  mv "${1}"*.md "${1}"
fi

#!/bin/bash

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

# ファイル作成
cat <<-EOD >> "$TARGET_DIR/${DATE}.md"
# ${DATE}

EOD

echo "File created: $TARGET_DIR/${DATE}.md"

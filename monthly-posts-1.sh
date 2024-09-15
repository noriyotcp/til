#!/bin/sh
# This is for macOS

MSG="${BASH_SOURCE:-$0} $(date +"%Y-%m")"
DESC=$(cat <<-EOD
DESCRIPTION
    The options are as follows:
    -p DIR        Target directory to create the file in
    -h            Display this help
EOD
)

if [ ${#} -eq 0 ]; then
  echo "No args: eg) ${MSG}"
  echo "$DESC"
elif [ "${1}" = "-h" ]; then
  echo "$DESC"
else
  mkdir "${1}"
  mv "${1}"*.md "${1}"
fi

# 初期値の設定
TARGET_DIR="."

# コマンドライン引数の解析
while [[ $# -gt 0 ]]; do
  case "$1" in
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


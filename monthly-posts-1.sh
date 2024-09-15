#!/bin/bash
# This is for macOS

MSG="${BASH_SOURCE:-$0} $(date +"%Y-%m")"
DESC=$(cat <<-EOD
DESCRIPTION
    The options are as follows:
    -p DIR        Target directory to create the directory in
    -h            Display this help
EOD
)

# 初期値の設定
TARGET_DIR="."

# ディレクトリ名が指定されているか確認
if [ ${#} -eq 0 ]; then
  echo "No args: eg) ${MSG}"
  echo "$DESC"
  exit 1
fi

# 最初の引数が-オプションで始まる場合、エラーメッセージを表示
if [[ "$1" == -* ]]; then
  echo "The first argument must be the directory name in YYYY-MM format"
  echo "$DESC"
  exit 1
fi

# 最初の引数を新しいディレクトリ名として設定
NEW_DIR="$1"
shift

# オプション解析
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
      echo "$DESC"
      exit 0
      ;;
    *)
      echo "Invalid option: $1"
      echo "$DESC"
      exit 1
      ;;
  esac
done

# 作成するディレクトリの完全パスを決定
NEW_DIR_PATH="$TARGET_DIR/$NEW_DIR"

# ディレクトリの存在確認と作成
mkdir -p "$NEW_DIR_PATH"

# 指定された日付形式のファイルをディレクトリに移動
mv "${NEW_DIR}"*.md "$NEW_DIR_PATH"

echo "Files moved to: $NEW_DIR_PATH"

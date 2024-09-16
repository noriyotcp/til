#!/bin/sh

get_file_info() {
  if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
  fi

  FILE=$1

  # ファイルの作成日時と最終更新日時（LinuxおよびmacOSで異なるコマンド）
  if [ "$(uname)" = "Darwin" ]; then
    # macOSの場合
    CREATED_DATE=$(stat -f '%SB' -t '%Y-%m-%d %H:%M:%S' "$FILE" 2>/dev/null)
    MODIFIED_DATE=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$FILE" 2>/dev/null)
  else
    # Linuxの場合
    CREATED_DATE=$(stat -c %w "$FILE" 2>/dev/null)
    MODIFIED_DATE=$(stat -c %y "$FILE" 2>/dev/null)
  fi

  # 不要な空行やエラーメッセージを除外しつつ、結果を表示
  echo "File: $FILE"
  echo "Created: ${CREATED_DATE:-"N/A"}"
  echo "Modified: $MODIFIED_DATE"
}

# 実行
get_file_info "$1"


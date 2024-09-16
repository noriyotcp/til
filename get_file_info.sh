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
    CREATED_DATE=$(stat -f '%SB' -t '%Y-%m-%d %H:%M:%S %z' "$FILE" 2>/dev/null)
    MODIFIED_DATE=$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S %z' "$FILE" 2>/dev/null)
  else
    # Linuxの場合
    CREATED_DATE=$(stat -c '%w' "$FILE" 2>/dev/null)
    MODIFIED_DATE=$(stat -c '%y' "$FILE" 2>/dev/null)

    # 作成日時が N/A の場合（ファイルシステムが作成日時をサポートしない場合）
    if [ "$CREATED_DATE" = '-' ] || [ -z "$CREATED_DATE" ]; then
      CREATED_DATE='N/A'
    else
      # タイムゾーンオフセットを追加（`date` コマンドを使用）
      CREATED_DATE=$(date -d "$CREATED_DATE" +"%Y-%m-%d %H:%M:%S %z")
    fi

    # 最終更新日時が N/A の場合（ファイルシステムが最終更新日時をサポートしない場合）
    if [ "$MODIFIED_DATE" = '-' ] || [ -z "$MODIFIED_DATE" ]; then
      MODIFIED_DATE='N/A'
    else
      # 最終更新日時にタイムゾーンオフセットを追加
      MODIFIED_DATE=$(date -d "$MODIFIED_DATE" +"%Y-%m-%d %H:%M:%S %z")
    fi
  fi

  # 不要な空行やエラーメッセージを除外しつつ、結果を表示
  echo "File: ${FILE}"
  echo "Created: ${CREATED_DATE}"
  echo "Modified: ${MODIFIED_DATE}"
}

# 実行
get_file_info "$1"


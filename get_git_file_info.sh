#!/bin/sh

get_git_file_info() {
  if [ -z "$1" ]; then
    echo "Usage: $0 <filename>"
    exit 1
  fi

  FILE=$1

  # 最初にコミットされた日時（作成日時）
  CREATION_DATE=$(git log --follow --diff-filter=A --format=%ai -1 "$FILE")

  # 最後にコミットされた日時（最終更新日時）
  LAST_MODIFIED_DATE=$(git log --follow -1 --format=%ai "$FILE")

  echo "File: $FILE"
  echo "Created: $CREATION_DATE"
  echo "Last Modified: $LAST_MODIFIED_DATE"
}

get_git_file_info "$1"


#!/bin/sh

CMD="$0"

USAGE="USAGE: $0 <path/to/file>"

DESC=$(cat <<-EOD
$USAGE

DESCRIPTION:
    The options are as follows:
    -h            Display this help
EOD
)

# ファイルパスが指定されているか確認
if [ $# -eq 0 ]; then
  echo "$DESC"
  exit 1
fi

# 最初の引数が - オプションで始まる場合、エラーメッセージを表示
if [ "${1#-}" != "$1" ]; then
  echo "The first argument must be the path to the file\n"
  echo "$DESC"
  exit 1
fi

# 最初の引数をファイルパスとして設定
FILE_PATH="$1"
shift

# オプション解析
while [ $# -gt 0 ]; do
  case "$1" in
    -h)
      echo "$DESC"
      exit 0
      ;;
    *)
      echo "Invalid option: $1\n"
      echo "$DESC"
      exit 1
      ;;
  esac
done

# Get created/last updated dates from file
get_git_file_info() {
  FILE=$1

  # 最初にコミットされた日時（作成日時）
  CREATION_DATE=$(git log --follow --diff-filter=A --format=%ai -1 "$FILE")

  # 最後にコミットされた日時（最終更新日時）
  LAST_MODIFIED_DATE=$(git log --follow -1 --format=%ai "$FILE")

  echo "Created: $CREATION_DATE"
  echo "Last Modified: $LAST_MODIFIED_DATE"
}

# ファイル情報を取得する関数を呼び出す
get_git_file_info "$FILE_PATH"

# Front matterの生成
FRONTMATTER=$(cat <<-EOM
---
date: "${CREATION_DATE}"
last_modified_at: "${LAST_MODIFIED_DATE}"
---

EOM
)

# 改行を適切に処理し、Front matterをファイルの先頭行に挿入
sed -i.bak -e "1i\\
${FRONTMATTER//$'\n'/\\
}\\
" "$FILE_PATH"

# 一時ファイルを削除
rm "${FILE_PATH}.bak"


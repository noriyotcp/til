#!/bin/sh
#
# 既にFront Matterが存在する前提で、`last_modified_at`の部分だけを更新するスクリプトを修正します。そのため、既存のFront Matterを残したまま、`last_modified_at`の値を新しい日時で置き換えるようにします。

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

  # 最後にコミットされた日時（最終更新日時）
  LAST_MODIFIED_DATE=$(git log --follow -1 --format=%ai "$FILE")

  echo "Last Modified: $LAST_MODIFIED_DATE"
}

# ファイル情報を取得する関数を呼び出す
get_git_file_info "$FILE_PATH"

# Backup original file
cp "$FILE_PATH" "$FILE_PATH.bak"

# New temporary file for editing
TEMP_FILE=$(mktemp)

# 既存のFront Matterが存在する前提でlast_modified_atのみ更新
awk -v last_modified="last_modified_at: \"${LAST_MODIFIED_DATE}\"" '
  BEGIN { in_front_matter = 0 }
  /^---$/ {
    if (in_front_matter == 1) {
      # 終了タグに到達したときはそのまま出力して終了
      in_front_matter = 0
      print $0
    } else {
      # 開始タグに到達した最初の一度だけ中に入る
      in_front_matter = 1
      print $0
    }
    next
  }
  in_front_matter == 1 && $1 ~ /^last_modified_at:/ {
    # 最終更新日時の行を置き換える
    print last_modified
    next
  }
  { print $0 }
' "$FILE_PATH" > "$TEMP_FILE"

# 更新内容を元のファイルに反映
mv "$TEMP_FILE" "$FILE_PATH"

# バックアップファイルを削除
rm "${FILE_PATH}.bak"


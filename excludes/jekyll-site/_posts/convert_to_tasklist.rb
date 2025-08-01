def convert(content)
  box_unchecked = '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" />'
  box_checked   = '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked" />'

  # タスクリストの置換処理
  content.gsub!(/(\*|\-) \[ \]\s+/) do
    box_unchecked
  end
  content.gsub!(/(\*|\-) \[x\]\s+/i) do
    box_checked
  end

  # 変換後の文字列を返す
  content
end

# 呼び出しはこうです
p convert("* [ ] foo\n* [x] bar")
p convert("- [ ] foo\n- [x] bar")
# p convert("* [ ] foo\n    * [x] bar")

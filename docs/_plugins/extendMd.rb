module Jekyll
  module Converters
    class Markdown
      class KramdownParser
        safe false

        alias :old_convert :convert

        def convert(content)
          # cf. https://github.com/kramdown/parser-gfm/blob/bb3a2b2572b3b5a290465c0d6976f0e02628b207/lib/kramdown/parser/gfm.rb#L189
          box_unchecked = '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" />'
          box_checked   = '<input type="checkbox" class="task-list-item-checkbox" disabled="disabled" checked="checked" />'

          # タスクリストの置換処理
          content.gsub!(/(\*|\-) \[ \]\s+/) do
            box_unchecked
          end
          content.gsub!(/(\*|\-) \[x\]\s+/i) do
            box_checked
          end

          old_convert(content)
        end
      end
    end
  end
end

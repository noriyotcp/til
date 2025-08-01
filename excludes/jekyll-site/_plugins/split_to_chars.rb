module SplitCharsFilter
  def split_to_chars(input)
    input.chars
  end
end

Liquid::Template.register_filter(SplitCharsFilter)

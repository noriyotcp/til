require 'uri'

def convert_url_to_a_element(text)
  uri_reg = URI.regexp(%w[http https])
  text.gsub(uri_reg) { %{<a href='#{$&}' target='_blank' rel="noopener noreferrer">#{$&}</a>} }
end

def converted_url(url)
  converted = "[#{url}](#{url})"
  {
    url:,
    converted:
  }
end

text = 'url1: http://hogehoge.com/hoge?q=hoge url2: http://hogehoge.com/#conversion-and-markdown-processing'

p convert_url_to_a_element(text)


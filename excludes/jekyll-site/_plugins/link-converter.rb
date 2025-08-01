require 'jekyll'
require 'uri'

module Jekyll
  module Converters
    class Markdown
      class LinkConverter < Converter
        safe true
        priority :low

        def matches(ext)
          ext =~ /^\.md$/i
        end

        def output_ext(ext)
          ".html"
        end

        def convert(content)
          uri_reg = URI.regexp(%w[http https])
          content.gsub(uri_reg) { |url| "[#{url}](#{url})" }
        end
      end
    end
  end
end

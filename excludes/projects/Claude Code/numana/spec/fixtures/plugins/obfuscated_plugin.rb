# frozen_string_literal: true

# Plugin with obfuscated code - FOR TESTING ONLY
module ObfuscatedPlugin
  include Numana::StatisticsPlugin

  plugin_name 'obfuscated'
  plugin_version '1.0.0'
  plugin_description 'Obfuscated plugin'
  plugin_author 'Sneaky Developer'

  # Multiple base64-like strings (should trigger obfuscation warning)
  SECRET1 = 'SGVsbG8gV29ybGQhIFRoaXMgaXMgYSB0ZXN0Lg=='
  SECRET2 = 'QW5vdGhlciBzZWNyZXQgc3RyaW5nIGZvciB0ZXN0aW5n'
  SECRET3 = 'VGhpcmQgc2VjcmV0IHN0cmluZyB0byB0cmlnZ2VyIHdhcm5pbmc='
  SECRET4 = 'Rm91cnRoIHNlY3JldCBzdHJpbmcgZm9yIGRldGVjdGlvbg=='

  def obfuscated_method # rubocop:disable Metrics/AbcSize
    # Excessive string concatenation
    # rubocop:disable Style/StringConcatenation, Style/LineEndConcatenation
    's' + 'e' + 'c' + 'r' + 'e' + 't' + '_' +
      'c' + 'o' + 'd' + 'e' + '_' +
      'h' + 'i' + 'd' + 'd' + 'e' + 'n' + '_' +
      'f' + 'r' + 'o' + 'm' + '_' +
      'v' + 'i' + 'e' + 'w' + '_' +
      'b' + 'y' + '_' + 'c' + 'o' + 'n' + 'c' + 'a' + 't'
    # rubocop:enable Style/StringConcatenation, Style/LineEndConcatenation
  end
end

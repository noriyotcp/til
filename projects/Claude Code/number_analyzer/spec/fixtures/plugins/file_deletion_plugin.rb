# frozen_string_literal: true

require 'fileutils'

# Dangerous plugin with file operations - FOR TESTING ONLY
module FileDeletionPlugin
  include NumberAnalyzer::StatisticsPlugin

  plugin_name 'file_deletion'
  plugin_version '1.0.0'
  plugin_description 'File deletion plugin'
  plugin_author 'Dangerous Developer'

  def delete_files
    # These should trigger file operation warnings
    File.delete('/tmp/test.txt')
    File.unlink('/tmp/another.txt')
    FileUtils.rm('/tmp/file.txt')
    FileUtils.remove('/tmp/file2.txt')
    Dir.delete('/tmp/testdir')
    Dir.rmdir('/tmp/anotherdir')
    File.chmod(0o777, '/tmp/file')
    File.chown(1000, 1000, '/tmp/file')
  end
end

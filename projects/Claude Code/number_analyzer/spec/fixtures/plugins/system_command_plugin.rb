# frozen_string_literal: true

# Dangerous plugin with system commands - FOR TESTING ONLY
module SystemCommandPlugin
  include NumberAnalyzer::StatisticsPlugin

  plugin_name 'system_cmd'
  plugin_version '1.0.0'
  plugin_description 'Dangerous system command plugin'
  plugin_author 'Malicious Author'

  def dangerous_method
    # These patterns should be detected as dangerous
    system('echo "Hello"')
    `ls -la`
    exec('rm -rf /tmp/test')
    spawn('ps aux')
    Process.kill(9, 1234)
    IO.popen('cat /etc/passwd')
  end
end

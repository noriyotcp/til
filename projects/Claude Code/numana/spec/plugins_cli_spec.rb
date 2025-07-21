# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli'
require 'numana/plugin_system'
require 'numana/plugin_interface'

RSpec.describe 'Plugins CLI Commands' do
  before do
    # Reset plugin state for each test
    Numana::CLI.reset_plugin_state!
    allow(Numana::CLI).to receive(:plugin_system).and_return(plugin_system)
    allow(Numana::CLI).to receive(:initialize_plugins) # Skip plugin initialization
  end

  let(:plugin_system) { instance_double(Numana::PluginSystem) }
  let(:mock_plugins) do
    {
      'test_plugin' => {
        class: test_plugin_class,
        priority: :local
      },
      'another_plugin' => {
        class: another_plugin_class,
        priority: :official
      }
    }
  end

  let(:test_plugin_class) do
    Class.new do
      def self.commands
        { 'test-command' => :run_test }
      end

      def self.provided_methods
        %i[test_method another_method]
      end
    end
  end

  let(:another_plugin_class) do
    Class.new do
      def self.commands
        { 'test-command' => :run_test, 'unique-command' => :run_unique }
      end

      def self.provided_methods
        %i[test_method unique_method]
      end
    end
  end

  describe 'plugins help' do
    it 'shows help when no subcommand is provided' do
      expect { Numana::CLI.run(['plugins']) }.to output(/Usage: bundle exec numana plugins/).to_stdout
    end

    it 'shows help with --help flag' do
      expect { Numana::CLI.run(['plugins', '--help']) }.to output(/Subcommands:/).to_stdout
    end

    it 'shows help with help subcommand' do
      expect { Numana::CLI.run(%w[plugins help]) }.to output(/list \[--show-conflicts\]/).to_stdout
    end
  end

  describe 'plugins list' do
    before do
      allow(plugin_system).to receive(:instance_variable_get).with(:@plugins).and_return(mock_plugins)
    end

    it 'lists all loaded plugins' do
      output = capture_stdout { Numana::CLI.run(%w[plugins list]) }

      expect(output).to include('ロード済みプラグイン (2個):')
      expect(output).to include('test_plugin:')
      expect(output).to include('another_plugin:')
      expect(output).to include('優先度: local')
      expect(output).to include('優先度: official')
    end

    it 'shows message when no plugins are loaded' do
      allow(plugin_system).to receive(:instance_variable_get).with(:@plugins).and_return({})

      expect { Numana::CLI.run(%w[plugins list]) }
        .to output(/プラグインがロードされていません。/).to_stdout
    end

    it 'detects and shows conflicts with --show-conflicts flag' do
      output = capture_stdout { Numana::CLI.run(['plugins', 'list', '--show-conflicts']) }

      expect(output).to include('⚠️  重複:')
      expect(output).to include('コマンド重複 with another_plugin: test-command')
      expect(output).to include('重複サマリー:')
    end
  end

  describe 'plugins conflicts' do
    before do
      allow(plugin_system).to receive(:instance_variable_get).with(:@plugins).and_return(mock_plugins)
    end

    it 'shows all conflicts' do
      output = capture_stdout { Numana::CLI.run(%w[plugins conflicts]) }

      expect(output).to include('プラグイン重複検出結果:')
      expect(output).to include('コマンドの重複:')
      expect(output).to include("'test-command' は以下のプラグインで重複しています:")
      expect(output).to include('test_plugin (優先度: local)')
      expect(output).to include('another_plugin (優先度: official)')
    end

    it 'works with --conflicts flag' do
      output = capture_stdout { Numana::CLI.run(['plugins', '--conflicts']) }

      expect(output).to include('プラグイン重複検出結果:')
    end

    it 'shows no conflicts message when none exist' do
      # Create plugins without conflicts
      non_conflicting_plugins = {
        'plugin1' => {
          class: Class.new { def self.commands = { 'cmd1' => :run } },
          priority: :local
        },
        'plugin2' => {
          class: Class.new { def self.commands = { 'cmd2' => :run } },
          priority: :local
        }
      }

      allow(plugin_system).to receive(:instance_variable_get).with(:@plugins).and_return(non_conflicting_plugins)

      output = capture_stdout { Numana::CLI.run(%w[plugins conflicts]) }
      expect(output).to include('✅ 重複は検出されませんでした。')
      expect(output).to include('ロード済みプラグイン数: 2')
    end
  end

  describe 'plugins resolve' do
    before do
      allow(plugin_system).to receive(:instance_variable_get).with(:@plugins).and_return(mock_plugins)
      allow($stdin).to receive(:gets).and_return("n\n") # Default to 'no' for interactive prompts
    end

    it 'requires plugin name' do
      expect { Numana::CLI.run(%w[plugins resolve]) }
        .to output(/エラー: 解決するプラグイン名を指定してください。/)
        .to_stdout.and raise_error(SystemExit)
    end

    it 'validates plugin exists' do
      expect { Numana::CLI.run(%w[plugins resolve nonexistent]) }
        .to output(/エラー: プラグイン 'nonexistent' が見つかりません。/)
        .to_stdout.and raise_error(SystemExit)
    end

    it 'detects conflicts for specified plugin' do
      output = capture_stdout { Numana::CLI.run(%w[plugins resolve test_plugin]) }

      expect(output).to include("プラグイン 'test_plugin' の重複:")
      expect(output).to include('コマンド重複 with another_plugin: test-command')
    end

    it 'shows no conflicts message when plugin has none' do
      # Mock a plugin without conflicts
      non_conflicting_plugins = {
        'unique_plugin' => {
          class: Class.new { def self.commands = { 'unique' => :run } },
          priority: :local
        }
      }
      allow(plugin_system).to receive(:instance_variable_get).with(:@plugins).and_return(non_conflicting_plugins)

      output = capture_stdout { Numana::CLI.run(%w[plugins resolve unique_plugin]) }
      expect(output).to include("プラグイン 'unique_plugin' に重複はありません。")
    end

    context 'with namespace strategy' do
      it 'resolves conflicts using namespace' do
        output = capture_stdout do
          Numana::CLI.run(['plugins', 'resolve', 'test_plugin', '--strategy=namespace'])
        end

        expect(output).to include('名前空間を使用して解決します...')
        expect(output).to include("✅ プラグイン 'test_plugin' を")
        expect(output).to include('として再登録します。')
        expect(output).to include('設定ファイルを更新してください: plugins.yml')
      end
    end

    context 'with priority strategy' do
      it 'resolves conflicts using priority' do
        output = capture_stdout do
          Numana::CLI.run(['plugins', 'resolve', 'test_plugin', '--strategy=priority'])
        end

        expect(output).to include('優先度に基づいて解決します...')
        expect(output).to include("プラグイン 'test_plugin' の優先度:")
        expect(output).to include('より低い優先度のプラグインを上書きします。')
      end
    end

    context 'with disable strategy' do
      it 'suggests disabling the plugin' do
        output = capture_stdout do
          Numana::CLI.run(['plugins', 'resolve', 'test_plugin', '--strategy=disable'])
        end

        expect(output).to include("プラグイン 'test_plugin' を無効化します...")
        expect(output).to include('enabled: false を設定してください。')
      end
    end

    context 'with interactive strategy' do
      it 'prompts for user input' do
        allow($stdin).to receive(:gets).and_return("y\n", "4\n") # Yes, then Cancel

        output = capture_stdout do
          Numana::CLI.run(['plugins', 'resolve', 'test_plugin', '--strategy=interactive'])
        end

        expect(output).to include('対話的重複解決モード')
        expect(output).to include('重複を解決しますか? (y/n)')
        expect(output).to include('解決方法を選択してください:')
        expect(output).to include('解決をキャンセルしました。')
      end

      it 'skips confirmation with --force flag' do
        allow($stdin).to receive(:gets).and_return("4\n") # Cancel

        output = capture_stdout do
          Numana::CLI.run(['plugins', 'resolve', 'test_plugin', '--strategy=interactive', '--force'])
        end

        expect(output).not_to include('重複を解決しますか? (y/n)')
        expect(output).to include('解決方法を選択してください:')
      end
    end

    it 'validates strategy option' do
      expect { Numana::CLI.run(['plugins', 'resolve', 'test_plugin', '--strategy=invalid']) }
        .to output(/エラー: 無効な戦略: invalid/)
        .to_stdout.and raise_error(SystemExit)
    end
  end

  describe 'unknown subcommand' do
    it 'shows error for unknown subcommand' do
      expect { Numana::CLI.run(%w[plugins unknown]) }
        .to output(/エラー: 不明なpluginsサブコマンド: unknown/)
        .to_stdout.and raise_error(SystemExit)
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/commands/median_command'
require 'number_analyzer/cli/commands/mean_command'
require 'number_analyzer/cli/commands/sum_command'
require 'number_analyzer/cli/commands/min_command'
require 'number_analyzer/cli/commands/max_command'
require 'number_analyzer/cli/commands/mode_command'

RSpec.describe 'Basic Commands Integration' do
  let(:test_data) { %w[1 2 3 4 5] }
  let(:test_data_with_duplicates) { %w[1 2 2 3 3 3 4] }

  describe 'MedianCommand' do
    let(:command) { NumberAnalyzer::Commands::MedianCommand.new }

    it 'calculates correct median' do
      expect { command.execute(test_data) }.to output("3.0\n").to_stdout
    end
  end

  describe 'MeanCommand' do
    let(:command) { NumberAnalyzer::Commands::MeanCommand.new }

    it 'calculates correct mean' do
      expect { command.execute(test_data) }.to output("3.0\n").to_stdout
    end
  end

  describe 'SumCommand' do
    let(:command) { NumberAnalyzer::Commands::SumCommand.new }

    it 'calculates correct sum' do
      expect { command.execute(test_data) }.to output("15.0\n").to_stdout
    end
  end

  describe 'MinCommand' do
    let(:command) { NumberAnalyzer::Commands::MinCommand.new }

    it 'finds correct minimum' do
      expect { command.execute(test_data) }.to output("1.0\n").to_stdout
    end
  end

  describe 'MaxCommand' do
    let(:command) { NumberAnalyzer::Commands::MaxCommand.new }

    it 'finds correct maximum' do
      expect { command.execute(test_data) }.to output("5.0\n").to_stdout
    end
  end

  describe 'ModeCommand' do
    let(:command) { NumberAnalyzer::Commands::ModeCommand.new }

    it 'finds correct mode' do
      expect { command.execute(test_data_with_duplicates) }.to output("3.0\n").to_stdout
    end
  end

  describe 'all commands with JSON format' do
    let(:commands) do
      [
        NumberAnalyzer::Commands::MedianCommand.new,
        NumberAnalyzer::Commands::MeanCommand.new,
        NumberAnalyzer::Commands::SumCommand.new,
        NumberAnalyzer::Commands::MinCommand.new,
        NumberAnalyzer::Commands::MaxCommand.new,
        NumberAnalyzer::Commands::ModeCommand.new
      ]
    end

    it 'supports JSON output format' do
      commands.each do |command|
        expect { command.execute(test_data, format: 'json') }
          .to output(include('"value":')).to_stdout
      end
    end
  end

  describe 'all commands with empty input' do
    let(:commands) do
      [
        NumberAnalyzer::Commands::MedianCommand.new,
        NumberAnalyzer::Commands::MeanCommand.new,
        NumberAnalyzer::Commands::SumCommand.new,
        NumberAnalyzer::Commands::MinCommand.new,
        NumberAnalyzer::Commands::MaxCommand.new,
        NumberAnalyzer::Commands::ModeCommand.new
      ]
    end

    it 'handles empty input gracefully' do
      commands.each do |command|
        expect { command.execute([]) }
          .to output(include('エラー')).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end
end

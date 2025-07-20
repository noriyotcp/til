# frozen_string_literal: true

require 'spec_helper'
require 'numana/cli/commands/median_command'
require 'numana/cli/commands/mean_command'
require 'numana/cli/commands/sum_command'
require 'numana/cli/commands/min_command'
require 'numana/cli/commands/max_command'
require 'numana/cli/commands/mode_command'

RSpec.describe 'Basic Commands Integration' do
  let(:test_data) { %w[1 2 3 4 5] }
  let(:test_data_with_duplicates) { %w[1 2 2 3 3 3 4] }

  describe 'MedianCommand' do
    let(:command) { Numana::Commands::MedianCommand.new }

    it 'calculates correct median' do
      expect { command.execute(test_data) }.to output("3.0\n").to_stdout
    end
  end

  describe 'MeanCommand' do
    let(:command) { Numana::Commands::MeanCommand.new }

    it 'calculates correct mean' do
      expect { command.execute(test_data) }.to output("3.0\n").to_stdout
    end
  end

  describe 'SumCommand' do
    let(:command) { Numana::Commands::SumCommand.new }

    it 'calculates correct sum' do
      expect { command.execute(test_data) }.to output("15.0\n").to_stdout
    end
  end

  describe 'MinCommand' do
    let(:command) { Numana::Commands::MinCommand.new }

    it 'finds correct minimum' do
      expect { command.execute(test_data) }.to output("1.0\n").to_stdout
    end
  end

  describe 'MaxCommand' do
    let(:command) { Numana::Commands::MaxCommand.new }

    it 'finds correct maximum' do
      expect { command.execute(test_data) }.to output("5.0\n").to_stdout
    end
  end

  describe 'ModeCommand' do
    let(:command) { Numana::Commands::ModeCommand.new }

    it 'finds correct mode' do
      expect { command.execute(test_data_with_duplicates) }.to output("3.0\n").to_stdout
    end
  end

  describe 'all commands with JSON format' do
    let(:commands) do
      [
        Numana::Commands::MedianCommand.new,
        Numana::Commands::MeanCommand.new,
        Numana::Commands::SumCommand.new,
        Numana::Commands::MinCommand.new,
        Numana::Commands::MaxCommand.new,
        Numana::Commands::ModeCommand.new
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
        Numana::Commands::MedianCommand.new,
        Numana::Commands::MeanCommand.new,
        Numana::Commands::SumCommand.new,
        Numana::Commands::MinCommand.new,
        Numana::Commands::MaxCommand.new,
        Numana::Commands::ModeCommand.new
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

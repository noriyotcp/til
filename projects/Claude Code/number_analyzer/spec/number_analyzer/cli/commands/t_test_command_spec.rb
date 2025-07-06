# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/commands/t_test_command'

RSpec.describe NumberAnalyzer::Commands::TTestCommand do
  describe '#show_help' do
    let(:command) { described_class.new }

    it 'displays comprehensive help information' do
      output = capture_stdout do
        command.execute([], { help: true })
      end

      expect(output).to include('t-test - Perform statistical t-test analysis')
      expect(output).to include('Usage: number_analyzer t-test')
      expect(output).to include('Test Types:')
      expect(output).to include('Independent samples')
      expect(output).to include('Paired samples')
      expect(output).to include('One-sample')
      expect(output).to include('Options:')
      expect(output).to include('--help')
      expect(output).to include('--paired')
      expect(output).to include('--one-sample')
      expect(output).to include('--population-mean')
      expect(output).to include('Examples:')
    end
  end

  describe '#execute' do
    let(:command) { described_class.new }

    context 'with independent samples data' do
      it 'performs independent t-test correctly' do
        output = capture_stdout do
          command.execute(%w[1 2 3 -- 4 5 6])
        end
        expect(output).to include('t検定結果')
        expect(output).to include('独立2標本')
        expect(output).to include('t統計量')
        expect(output).to include('p値')
      end
    end

    context 'with paired samples data' do
      it 'performs paired t-test correctly' do
        output = capture_stdout do
          command.execute(%w[1 2 3 -- 4 5 6], { paired: true })
        end
        expect(output).to include('t検定結果')
        expect(output).to include('対応あり')
        expect(output).to include('t統計量')
        expect(output).to include('ペア数: 3')
      end
    end

    context 'with one-sample data' do
      it 'performs one-sample t-test correctly' do
        output = capture_stdout do
          command.execute(%w[1 2 3 4 5], { one_sample: true, population_mean: '3' })
        end
        expect(output).to include('t検定結果')
        expect(output).to include('一標本')
        expect(output).to include('t統計量')
      end
    end

    context 'with insufficient arguments' do
      it 'exits due to missing data' do
        expect do
          capture_stdout do
            command.execute([])
          end
        end.to raise_error(SystemExit)
      end
    end
  end
end

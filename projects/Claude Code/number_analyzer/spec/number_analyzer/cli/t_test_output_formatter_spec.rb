# frozen_string_literal: true

require 'spec_helper'
require 'number_analyzer/cli/t_test_output_formatter'

RSpec.describe NumberAnalyzer::CLI::TTestOutputFormatter do
  let(:options) { {} }
  let(:formatter) { described_class.new(options) }

  describe '#format_standard_output' do
    let(:result) do
      {
        test_type: :independent,
        t_statistic: 2.5,
        degrees_of_freedom: 8,
        p_value: 0.036,
        significant: true,
        dataset1_size: 5,
        dataset2_size: 5
      }
    end

    it 'formats standard output correctly' do
      output = capture_stdout do
        formatter.format_standard_output(result)
      end

      expect(output).to include('t検定結果')
      expect(output).to include('独立2標本')
      expect(output).to include('t統計量: 2.5')
      expect(output).to include('自由度: 8')
      expect(output).to include('p値: 0.036')
    end
  end

  describe '#format_json_output' do
    let(:result) { { test_type: :paired, t_statistic: 1.8 } }

    it 'formats JSON output correctly' do
      output = capture_stdout do
        formatter.format_json_output(result)
      end

      json_data = JSON.parse(output)
      expect(json_data['test_type']).to eq('paired')
      expect(json_data['t_statistic']).to eq(1.8)
    end
  end

  describe '#format_quiet_output' do
    let(:result) { { p_value: 0.025 } }

    it 'formats quiet output with p-value only' do
      output = capture_stdout do
        formatter.format_quiet_output(result)
      end

      expect(output.strip).to eq('0.025000')
    end

    context 'with precision option' do
      let(:options) { { precision: 3 } }

      it 'applies precision formatting' do
        output = capture_stdout do
          formatter.format_quiet_output(result)
        end

        expect(output.strip).to eq('0.025')
      end
    end
  end
end

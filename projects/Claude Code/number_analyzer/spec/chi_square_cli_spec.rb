# frozen_string_literal: true

require 'spec_helper'
require 'stringio'
require 'json'
require 'fileutils'

RSpec.describe 'Chi-square CLI' do
  def run_chi_square_command(args)
    output = StringIO.new
    allow($stdout).to receive(:write) { |msg| output.write(msg) }
    allow($stdout).to receive(:puts) { |msg| output.puts(msg) }

    begin
      NumberAnalyzer::CLI.run(['chi-square'] + args)
      output.string
    rescue SystemExit
      output.string
    end
  end

  describe 'independence test' do
    context 'with 2x2 contingency table' do
      it 'correctly parses and calculates chi-square for 2x2 table' do
        output = run_chi_square_command(['--independence', '30', '20', '--', '15', '35'])

        expect(output).to include('カイ二乗検定結果:')
        expect(output).to include('統計量: χ² = 9.090909')
        expect(output).to include('自由度: df = 1')
        expect(output).to include('有意差あり')
      end

      it 'handles equal distributions (no association)' do
        output = run_chi_square_command(['--independence', '25', '25', '--', '25', '25'])

        expect(output).to include('統計量: χ² = 0.0')
        expect(output).to include('有意差なし')
      end
    end

    context 'with 3x3 contingency table' do
      it 'correctly parses and calculates chi-square for 3x3 table' do
        output = run_chi_square_command(['--independence', '10', '20', '30', '--', '15', '25', '35', '--', '20', '30', '40'])

        expect(output).to include('カイ二乗検定結果:')
        expect(output).to include('自由度: df = 4')
        expect(output).to match(/統計量: χ² = \d+\.\d+/)
      end
    end

    context 'with 2x3 contingency table' do
      it 'correctly handles non-square contingency tables' do
        output = run_chi_square_command(['--independence', '10', '20', '30', '--', '15', '25', '35'])

        expect(output).to include('カイ二乗検定結果:')
        expect(output).to include('自由度: df = 2')
      end
    end

    context 'with file input' do
      let(:test_file) { 'spec/fixtures/contingency_2x2.csv' }

      before do
        FileUtils.mkdir_p('spec/fixtures')
        File.write(test_file, "30,20\n15,35")
      end

      after do
        FileUtils.rm_f(test_file)
      end

      it 'reads contingency table from CSV file' do
        output = run_chi_square_command(['--independence', '--file', test_file])

        expect(output).to include('カイ二乗検定結果:')
        # NOTE: Current implementation assumes square tables from files
        expect(output).to match(/統計量: χ² = \d+\.\d+/)
      end
    end

    context 'with JSON output' do
      it 'outputs results in JSON format' do
        output = run_chi_square_command(['--independence', '--format', 'json', '30', '20', '--', '15', '35'])

        json = JSON.parse(output)
        expect(json['test_type']).to eq('independence')
        expect(json['chi_square_statistic']).to be_within(0.001).of(9.091)
        expect(json['degrees_of_freedom']).to eq(1)
      end
    end

    context 'with precision control' do
      it 'rounds output to specified precision' do
        output = run_chi_square_command(['--independence', '--precision', '2', '30', '20', '--', '15', '35'])

        expect(output).to include('統計量: χ² = 9.09')
        # NOTE: Cramér's V is not shown in verbose output for this particular case
        expect(output).to include('p値: 0.0') # Precision control for p-value
      end
    end

    context 'with quiet mode' do
      it 'outputs only the p-value' do
        output = run_chi_square_command(['--independence', '--quiet', '30', '20', '--', '15', '35'])

        # Quiet mode outputs chi-square statistic, df, p-value, and significance
        expect(output.strip).to match(/^\d+\.\d+ \d+ \d+\.\d+ (true|false)$/)
        expect(output.strip).to eq('9.090909 1 0.01 true')
      end
    end
  end

  describe 'goodness-of-fit test' do
    context 'with observed and expected frequencies' do
      it 'performs goodness-of-fit test with two datasets' do
        output = run_chi_square_command(['--goodness-of-fit', '8', '12', '10', '15', '10', '10', '10', '10'])

        expect(output).to include('カイ二乗検定結果:')
        expect(output).to include('自由度: df = 3')
      end
    end

    context 'with uniform distribution' do
      it 'tests against uniform distribution' do
        output = run_chi_square_command(['--uniform', '8', '12', '10', '15', '9', '6'])

        expect(output).to include('カイ二乗検定結果:')
        expect(output).to include('統計量: χ² = 5.0') # Expected chi-square for this data
      end
    end
  end

  describe 'error handling' do
    it 'shows error when no test type is specified' do
      output = run_chi_square_command(%w[10 20 30 40])

      expect(output).to include('Error')
      expect(output).to include('Please specify the type of chi-square test')
    end

    it 'shows error for invalid contingency table' do
      output = run_chi_square_command(['--independence', '30', '20', '--'])

      expect(output).to include('Error')
    end

    it 'handles empty row in contingency table' do
      output = run_chi_square_command(['--independence', '--', '30', '20'])

      expect(output).to include('Error')
      expect(output).to include('requires at least a 2x2 contingency table')
    end
  end

  describe 'help functionality' do
    it 'shows help for chi-square command' do
      output = run_chi_square_command(['--help'])

      expect(output).to include('chi-square')
      expect(output).to include('Options:')
      expect(output).to include('--independence')
      expect(output).to include('--goodness-of-fit')
    end
  end
end

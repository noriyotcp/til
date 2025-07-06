# frozen_string_literal: true

require 'English'
require 'fileutils'
require_relative '../../lib/number_analyzer/cli'

RSpec.describe NumberAnalyzer::CLI do
  let(:script_path) { File.join(__dir__, '..', '..', 'lib', 'number_analyzer', 'cli.rb') }

  describe 'CLI.parse_arguments' do
    context 'with no arguments' do
      it 'returns default array' do
        result = NumberAnalyzer::CLI.parse_arguments([])
        expect(result).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
      end
    end

    context 'with valid integer arguments' do
      it 'parses integers correctly' do
        result = NumberAnalyzer::CLI.parse_arguments(%w[1 2 3 4 5])
        expect(result).to eq([1.0, 2.0, 3.0, 4.0, 5.0])
      end
    end

    context 'with valid float arguments' do
      it 'parses floats correctly' do
        result = NumberAnalyzer::CLI.parse_arguments(['1.5', '2.7', '3.2'])
        expect(result).to eq([1.5, 2.7, 3.2])
      end
    end

    context 'with mixed valid arguments' do
      it 'parses mixed integers and floats' do
        result = NumberAnalyzer::CLI.parse_arguments(['1', '2.5', '3', '4.7'])
        expect(result).to eq([1.0, 2.5, 3.0, 4.7])
      end
    end

    context 'with invalid arguments' do
      it 'exits with error message for non-numeric input' do
        expect { NumberAnalyzer::CLI.parse_arguments(%w[1 abc 3]) }
          .to output(/Error: Invalid arguments found: abc/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'exits with error message for all invalid input' do
        expect { NumberAnalyzer::CLI.parse_arguments(%w[abc def]) }
          .to output(/Error: Invalid arguments found: abc, def/).to_stdout
          .and raise_error(SystemExit)
      end
    end
  end

  describe 'CLI file option' do
    it 'parses --file option correctly' do
      require 'tempfile'

      Tempfile.create(['test', '.csv']) do |file|
        file.write("numbers\n1\n2\n3")
        file.rewind

        result = NumberAnalyzer::CLI.parse_arguments(['--file', file.path])
        expect(result).to eq([1.0, 2.0, 3.0])
      end
    end

    it 'parses -f option correctly' do
      require 'tempfile'

      Tempfile.create(['test', '.json']) do |file|
        file.write('[4, 5, 6]')
        file.rewind

        result = NumberAnalyzer::CLI.parse_arguments(['-f', file.path])
        expect(result).to eq([4.0, 5.0, 6.0])
      end
    end

    it 'exits with error when file path is missing after --file' do
      expect do
        NumberAnalyzer::CLI.parse_arguments(['--file'])
      end.to output(/Error: --file option requires a file path/).to_stdout
                                                                .and raise_error(SystemExit)
    end

    it 'exits with error when file does not exist' do
      expect do
        NumberAnalyzer::CLI.parse_arguments(['--file', '/nonexistent/file.csv'])
      end.to output(/File read error/).to_stdout
                                      .and raise_error(SystemExit)
    end
  end

  describe 'CLI integration' do
    it 'runs with default values when no arguments provided' do
      output = `ruby "#{script_path}"`
      expect(output).to include('Total: 55')
      expect(output).to include('Average: 5.5')
      expect(output).to include('Median: 5.5')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'runs with custom values when arguments provided' do
      output = `ruby "#{script_path}" 1 2 3 4 5`
      expect(output).to include('Total: 15')
      expect(output).to include('Average: 3')
      expect(output).to include('Median: 3')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'handles decimal input correctly' do
      output = `ruby "#{script_path}" 1.5 2.7 3.2`
      expect(output).to include('Total: 7.4')
      expect(output).to include('Median: 2.7')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'exits with error for invalid input' do
      output = `ruby "#{script_path}" 1 2 abc 4 2>&1`
      expect(output).to include('Error: Invalid arguments found: abc')
      expect($CHILD_STATUS.success?).to be false
    end

    it 'runs with file input using --file option' do
      require 'tempfile'

      Tempfile.create(['test', '.csv']) do |file|
        file.write("numbers\n10\n20\n30")
        file.rewind

        output = `ruby "#{script_path}" --file "#{file.path}"`
        expect(output).to include('Total: 60')
        expect(output).to include('Average: 20')
        expect(output).to include('Median: 20')
        expect($CHILD_STATUS.success?).to be true
      end
    end

    it 'runs with fixture CSV file' do
      fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.csv')
      output = `ruby "#{script_path}" --file "#{fixture_path}"`
      expect(output).to include('Total: 205')
      expect(output).to include('Average: 20.5')
      expect($CHILD_STATUS.success?).to be true
    end

    it 'runs with fixture JSON file' do
      fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.json')
      output = `ruby "#{script_path}" -f "#{fixture_path}"`
      expect(output).to include('Total: 550')
      expect(output).to include('Average: 55')
      expect($CHILD_STATUS.success?).to be true
    end
  end

  describe 'CLI.run with subcommands' do
    context 'median subcommand' do
      it 'returns median value' do
        expect { NumberAnalyzer::CLI.run(%w[median 1 2 3 4 5]) }
          .to output("3.0\n").to_stdout
      end

      it 'handles even number of values' do
        expect { NumberAnalyzer::CLI.run(%w[median 1 2 3 4]) }
          .to output("2.5\n").to_stdout
      end
    end

    context 'mean subcommand' do
      it 'returns mean value' do
        expect { NumberAnalyzer::CLI.run(%w[mean 1 2 3 4 5]) }
          .to output("3.0\n").to_stdout
      end

      it 'handles decimal values' do
        expect { NumberAnalyzer::CLI.run(['mean', '1.5', '2.5', '3.5']) }
          .to output("2.5\n").to_stdout
      end
    end

    context 'mode subcommand' do
      it 'returns mode value' do
        expect { NumberAnalyzer::CLI.run(%w[mode 1 2 2 3]) }
          .to output("2.0\n").to_stdout
      end

      it 'returns multiple modes' do
        expect { NumberAnalyzer::CLI.run(%w[mode 1 1 2 2]) }
          .to output("1.0, 2.0\n").to_stdout
      end

      it 'returns no mode message when no mode exists' do
        expect { NumberAnalyzer::CLI.run(%w[mode 1 2 3]) }
          .to output("No mode\n").to_stdout
      end
    end

    context 'sum subcommand' do
      it 'returns sum value' do
        expect { NumberAnalyzer::CLI.run(%w[sum 1 2 3 4 5]) }
          .to output("15.0\n").to_stdout
      end

      it 'handles decimal values' do
        expect { NumberAnalyzer::CLI.run(['sum', '1.5', '2.5']) }
          .to output("4.0\n").to_stdout
      end
    end

    context 'min subcommand' do
      it 'returns minimum value' do
        expect { NumberAnalyzer::CLI.run(%w[min 5 1 3 2 4]) }
          .to output("1.0\n").to_stdout
      end

      it 'handles negative values' do
        expect { NumberAnalyzer::CLI.run(['min', '-1', '5', '-3']) }
          .to output("-3.0\n").to_stdout
      end
    end

    context 'max subcommand' do
      it 'returns maximum value' do
        expect { NumberAnalyzer::CLI.run(%w[max 5 1 3 2 4]) }
          .to output("5.0\n").to_stdout
      end

      it 'handles negative values' do
        expect { NumberAnalyzer::CLI.run(['max', '-1', '-5', '-3']) }
          .to output("-1.0\n").to_stdout
      end
    end

    context 'histogram subcommand' do
      it 'displays histogram' do
        expected_output = <<~OUTPUT
          Frequency Distribution Histogram:
          1.0: ■ (1)
          2.0: ■■ (2)
          3.0: ■■■ (3)
        OUTPUT

        expect { NumberAnalyzer::CLI.run(%w[histogram 1 2 2 3 3 3]) }
          .to output(expected_output).to_stdout
      end
    end

    context 'subcommands with file input' do
      it 'handles median with CSV file' do
        fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.csv')
        expect { NumberAnalyzer::CLI.run(['median', '--file', fixture_path]) }
          .to output("10.0\n").to_stdout
      end

      it 'handles mean with JSON file' do
        fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.json')
        expect { NumberAnalyzer::CLI.run(['mean', '-f', fixture_path]) }
          .to output("55.0\n").to_stdout
      end
    end

    context 'subcommand error handling' do
      it 'exits with error for subcommand without arguments' do
        expect { NumberAnalyzer::CLI.run(['median']) }
          .to output(/Error: Please specify numbers or --file option/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'exits with error for invalid file path' do
        expect { NumberAnalyzer::CLI.run(['mean', '--file', 'nonexistent.csv']) }
          .to output(/File read error/).to_stdout
          .and raise_error(SystemExit)
      end

      it 'exits with error for invalid numeric arguments' do
        expect { NumberAnalyzer::CLI.run(%w[sum 1 abc 3]) }
          .to output(/Error: Invalid arguments found: abc/).to_stdout
          .and raise_error(SystemExit)
      end
    end

    context 'advanced statistics subcommands' do
      context 'outliers subcommand' do
        it 'returns outlier values' do
          expect { NumberAnalyzer::CLI.run(%w[outliers 1 2 3 100]) }
            .to output("100.0\n").to_stdout
        end

        it 'returns no outliers message when none exist' do
          expect { NumberAnalyzer::CLI.run(%w[outliers 1 2 3 4 5]) }
            .to output("None\n").to_stdout
        end

        it 'handles multiple outliers' do
          expect { NumberAnalyzer::CLI.run(%w[outliers 1 2 3 4 100 200]) }
            .to output("200.0\n").to_stdout
        end
      end

      context 'percentile subcommand' do
        it 'calculates specified percentile' do
          expect { NumberAnalyzer::CLI.run(%w[percentile 75 1 2 3 4 5]) }
            .to output("4.0\n").to_stdout
        end

        it 'calculates median as 50th percentile' do
          expect { NumberAnalyzer::CLI.run(%w[percentile 50 1 2 3 4 5]) }
            .to output("3.0\n").to_stdout
        end

        it 'handles boundary percentiles' do
          expect { NumberAnalyzer::CLI.run(%w[percentile 0 1 2 3 4 5]) }
            .to output("1.0\n").to_stdout
        end

        it 'exits with error for missing percentile value' do
          expect { NumberAnalyzer::CLI.run(%w[percentile]) }
            .to output(/Error: percentile command requires percentile value and numbers/).to_stdout
            .and raise_error(SystemExit)
        end

        it 'exits with error for invalid percentile range' do
          expect { NumberAnalyzer::CLI.run(%w[percentile 150 1 2 3]) }
            .to output(/Error: percentile value must be between 0-100/).to_stdout
            .and raise_error(SystemExit)
        end

        it 'exits with error for non-numeric percentile' do
          expect { NumberAnalyzer::CLI.run(%w[percentile abc 1 2 3]) }
            .to output(/Error: Invalid percentile value/).to_stdout
            .and raise_error(SystemExit)
        end

        it 'handles file input with percentile' do
          fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.csv')
          expect { NumberAnalyzer::CLI.run(['percentile', '25', '--file', fixture_path]) }
            .to output("3.25\n").to_stdout
        end
      end

      context 'quartiles subcommand' do
        it 'displays formatted quartiles' do
          expected_output = <<~OUTPUT
            Q1: 2.0
            Q2: 3.0
            Q3: 4.0
          OUTPUT

          expect { NumberAnalyzer::CLI.run(%w[quartiles 1 2 3 4 5]) }
            .to output(expected_output).to_stdout
        end

        it 'handles even number of values' do
          expected_output = <<~OUTPUT
            Q1: 1.75
            Q2: 2.5
            Q3: 3.25
          OUTPUT

          expect { NumberAnalyzer::CLI.run(%w[quartiles 1 2 3 4]) }
            .to output(expected_output).to_stdout
        end
      end

      context 'variance subcommand' do
        it 'calculates variance' do
          expect { NumberAnalyzer::CLI.run(%w[variance 1 2 3 4 5]) }
            .to output("2.0\n").to_stdout
        end

        it 'handles single value' do
          expect { NumberAnalyzer::CLI.run(%w[variance 42]) }
            .to output("0.0\n").to_stdout
        end
      end

      context 'std subcommand' do
        it 'calculates standard deviation' do
          # sqrt(2.0) ≈ 1.4142135623730951
          expect { NumberAnalyzer::CLI.run(%w[std 1 2 3 4 5]) }
            .to output("1.4142135623730951\n").to_stdout
        end

        it 'handles identical values' do
          expect { NumberAnalyzer::CLI.run(%w[std 3 3 3 3]) }
            .to output("0.0\n").to_stdout
        end
      end

      context 'deviation-scores subcommand' do
        it 'calculates deviation scores' do
          expect { NumberAnalyzer::CLI.run(%w[deviation-scores 1 2 3 4 5]) }
            .to output("35.86, 42.93, 50.0, 57.07, 64.14\n").to_stdout
        end

        it 'handles identical values with score 50' do
          expect { NumberAnalyzer::CLI.run(%w[deviation-scores 5 5 5 5]) }
            .to output("50.0, 50.0, 50.0, 50.0\n").to_stdout
        end
      end

      context 'advanced subcommands with file input' do
        it 'handles outliers with CSV file' do
          fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.csv')
          expect { NumberAnalyzer::CLI.run(['outliers', '--file', fixture_path]) }
            .to output("100.0\n").to_stdout
        end

        it 'handles variance with JSON file' do
          fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.json')
          expect { NumberAnalyzer::CLI.run(['variance', '-f', fixture_path]) }
            .to output("825.0\n").to_stdout
        end
      end
    end

    context 'backward compatibility' do
      it 'runs full analysis when no subcommand provided' do
        expect { NumberAnalyzer::CLI.run(%w[1 2 3]) }
          .to output(/Total: 6/).to_stdout
      end

      it 'runs with default values when no arguments' do
        expect { NumberAnalyzer::CLI.run([]) }
          .to output(/Total: 55/).to_stdout
      end
    end

    context 'Phase 6.3: Output Format & Options' do
      context 'JSON format output' do
        it 'outputs JSON for median command' do
          expect { NumberAnalyzer::CLI.run(%w[median --format=json 1 2 3 4 5]) }
            .to output("{\"value\":3.0,\"dataset_size\":5}\n").to_stdout
        end

        it 'outputs JSON for quartiles command' do
          output = capture_stdout { NumberAnalyzer::CLI.run(%w[quartiles --format=json 1 2 3 4 5]) }
          parsed = JSON.parse(output)
          expect(parsed).to include('q1' => 2.0, 'q2' => 3.0, 'q3' => 4.0, 'dataset_size' => 5)
        end

        it 'outputs JSON for outliers command' do
          expect { NumberAnalyzer::CLI.run(%w[outliers --format=json 1 2 3 100]) }
            .to output("{\"outliers\":[100.0],\"dataset_size\":4}\n").to_stdout
        end

        it 'outputs JSON for mode command with values' do
          expect { NumberAnalyzer::CLI.run(%w[mode --format=json 1 2 2 3]) }
            .to output(/"mode":\[2.0\]/).to_stdout
        end

        it 'outputs JSON for mode command with no mode' do
          expect { NumberAnalyzer::CLI.run(%w[mode --format=json 1 2 3]) }
            .to output(/"mode":null/).to_stdout
        end

        it 'outputs JSON for histogram command' do
          output = capture_stdout { NumberAnalyzer::CLI.run(%w[histogram --format=json 1 2 2 3]) }
          parsed = JSON.parse(output)
          expect(parsed).to include('histogram', 'dataset_size')
          expect(parsed['histogram']).to eq({ '1.0' => 1, '2.0' => 2, '3.0' => 1 })
        end
      end

      context 'precision control' do
        it 'rounds output to specified decimal places' do
          expect { NumberAnalyzer::CLI.run(%w[median --precision=2 1.23456 2.34567 3.45678]) }
            .to output("2.35\n").to_stdout
        end

        it 'works with JSON format' do
          output = capture_stdout { NumberAnalyzer::CLI.run(%w[mean --format=json --precision=1 1.234 2.567]) }
          parsed = JSON.parse(output)
          expect(parsed['value']).to eq(1.9)
        end

        it 'applies to quartiles output' do
          expect { NumberAnalyzer::CLI.run(%w[quartiles --precision=1 1.1111 2.2222 3.3333 4.4444]) }
            .to output("Q1: 1.9\nQ2: 2.8\nQ3: 3.6\n").to_stdout
        end
      end

      context 'quiet mode' do
        it 'outputs only the value for median' do
          expect { NumberAnalyzer::CLI.run(%w[median --quiet 1 2 3 4 5]) }
            .to output("3.0\n").to_stdout
        end

        it 'outputs space-separated values for quartiles' do
          expect { NumberAnalyzer::CLI.run(%w[quartiles --quiet 1 2 3 4 5]) }
            .to output("2.0 3.0 4.0\n").to_stdout
        end

        it 'outputs empty string for no outliers' do
          expect { NumberAnalyzer::CLI.run(%w[outliers --quiet 1 2 3 4 5]) }
            .to output("\n").to_stdout
        end

        it 'outputs space-separated outliers when present' do
          expect { NumberAnalyzer::CLI.run(%w[outliers --quiet 1 2 3 4 5 100]) }
            .to output("100.0\n").to_stdout
        end

        it 'outputs space-separated values for histogram' do
          expect { NumberAnalyzer::CLI.run(%w[histogram --quiet 1 2 2]) }
            .to output("1.0:1 2.0:2\n").to_stdout
        end
      end

      context 'help system' do
        it 'shows help for median command' do
          expect { NumberAnalyzer::CLI.run(%w[median --help]) }
            .to output(/Usage: bundle exec number_analyzer median/).to_stdout
        end

        it 'shows help for percentile command' do
          expect { NumberAnalyzer::CLI.run(%w[percentile --help]) }
            .to output(/Calculate percentile value/).to_stdout
        end

        it 'shows examples in help output' do
          expect { NumberAnalyzer::CLI.run(%w[mean --help]) }
            .to output(/Examples:/).to_stdout
        end

        it 'shows options in help output' do
          expect { NumberAnalyzer::CLI.run(%w[variance --help]) }
            .to output(/--format json/).to_stdout
        end
      end

      context 'combined options' do
        it 'supports JSON format with precision' do
          output = capture_stdout { NumberAnalyzer::CLI.run(%w[median --format=json --precision=1 1.234 2.567 3.890]) }
          parsed = JSON.parse(output)
          expect(parsed['value']).to eq(2.6)
        end

        it 'supports file input with JSON format' do
          fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.csv')
          output = capture_stdout { NumberAnalyzer::CLI.run(['mean', '--format=json', '--file', fixture_path]) }
          parsed = JSON.parse(output)
          expect(parsed).to include('value', 'dataset_size')
        end

        it 'supports file input with precision' do
          fixture_path = File.join(__dir__, '..', 'fixtures', 'sample_data.json')
          expect { NumberAnalyzer::CLI.run(['mean', '--precision=1', '-f', fixture_path]) }
            .to output("55.0\n").to_stdout
        end
      end

      context 'error handling for new options' do
        it 'handles invalid format option gracefully' do
          expect { NumberAnalyzer::CLI.run(%w[median --format=xml 1 2 3]) }
            .to output("2.0\n").to_stdout
        end

        it 'exits with error for invalid precision value' do
          expect { NumberAnalyzer::CLI.run(%w[median --precision=abc 1 2 3]) }
            .to output(/invalid value for Integer/).to_stderr
            .and raise_error(SystemExit)
        end
      end
    end

    context 'trend subcommand' do
      it 'calculates trend for upward data' do
        expect { NumberAnalyzer::CLI.run(%w[trend 1 2 3 4 5]) }
          .to output("Trend Analysis Results:\nSlope: 1.0\nIntercept: 1.0\nR-squared: 1.0\nDirection: Upward\n").to_stdout
      end

      it 'calculates trend for downward data' do
        expect { NumberAnalyzer::CLI.run(%w[trend 5 4 3 2 1]) }
          .to output("Trend Analysis Results:\nSlope: -1.0\nIntercept: 5.0\nR-squared: 1.0\nDirection: Downward\n").to_stdout
      end

      it 'calculates trend for flat data' do
        expect { NumberAnalyzer::CLI.run(%w[trend 5 5 5 5 5]) }
          .to output("Trend Analysis Results:\nSlope: 0.0\nIntercept: 5.0\nR-squared: 1.0\nDirection: Stable\n").to_stdout
      end

      it 'outputs JSON format when requested' do
        expect { NumberAnalyzer::CLI.run(%w[trend --format=json 1 2 3]) }
          .to output("{\"trend\":{\"slope\":1.0,\"intercept\":1.0,\"r_squared\":1.0,\"direction\":\"Upward\"},\"dataset_size\":3}\n").to_stdout
      end

      it 'outputs quiet format when requested' do
        expect { NumberAnalyzer::CLI.run(%w[trend --quiet 1 2 3]) }
          .to output("1.0 1.0 1.0\n").to_stdout
      end

      it 'applies precision formatting' do
        expect { NumberAnalyzer::CLI.run(%w[trend --precision=2 1 2.1 3.2]) }
          .to output("Trend Analysis Results:\nSlope: 1.1\nIntercept: 1.0\nR-squared: 1.0\nDirection: Upward\n").to_stdout
      end

      it 'handles insufficient data' do
        expect { NumberAnalyzer::CLI.run(%w[trend 42]) }
          .to output("Error: Insufficient data (requires 2 or more values)\n").to_stdout
      end

      it 'shows help when requested' do
        expect { NumberAnalyzer::CLI.run(%w[trend --help]) }
          .to output(/Usage: bundle exec number_analyzer trend/).to_stdout
      end
    end

    context 'moving-average subcommand' do
      it 'calculates moving average with default window size 3' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average 1 2 3 4 5]) }
          .to output("Moving Average (Window Size: 3):\n2.0, 3.0, 4.0\n").to_stdout
      end

      it 'calculates moving average with custom window size' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --window=5 1 2 3 4 5 6 7]) }
          .to output("Moving Average (Window Size: 5):\n3.0, 4.0, 5.0\n").to_stdout
      end

      it 'outputs JSON format when requested' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --format=json --window=3 1 2 3 4]) }
          .to output("{\"moving_average\":[2.0,3.0],\"window_size\":3,\"dataset_size\":4}\n").to_stdout
      end

      it 'outputs quiet format when requested' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --quiet --window=2 1 2 3 4]) }
          .to output("1.5 2.5 3.5\n").to_stdout
      end

      it 'applies precision formatting' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --precision=1 --window=3 1.11 2.22 3.33 4.44]) }
          .to output("Moving Average (Window Size: 3):\n2.2, 3.3\n").to_stdout
      end

      it 'handles window size larger than dataset' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --window=5 1 2 3]) }
          .to output("エラー: データが不十分です（ウィンドウサイズがデータ長を超えています）\n").to_stdout
      end

      it 'handles invalid window size' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --window=0 1 2 3]) }
          .to output("エラー: ウィンドウサイズは正の整数である必要があります。\n").to_stdout.and raise_error(SystemExit)
      end

      it 'handles non-integer window size' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --window=abc 1 2 3]) }
          .to output("エラー: invalid argument: --window=abc\n").to_stdout.and raise_error(SystemExit)
      end

      it 'shows help when requested' do
        expect { NumberAnalyzer::CLI.run(%w[moving-average --help]) }
          .to output(/Usage: bundle exec number_analyzer moving-average/).to_stdout
      end
    end
  end

  describe 'growth-rate subcommand' do
    it 'calculates and displays growth rate analysis' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[growth-rate 100 110 121 133]) }

      expect(output).to include('成長率分析:')
      expect(output).to include('期間別成長率:')
      expect(output).to include('複合年間成長率 (CAGR):')
      expect(output).to include('平均成長率:')
    end

    it 'handles JSON format output' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[growth-rate --format=json 100 110 121 133]) }

      json_data = JSON.parse(output)
      expect(json_data).to have_key('growth_rate_analysis')
      expect(json_data['growth_rate_analysis']).to have_key('period_growth_rates')
      expect(json_data['growth_rate_analysis']).to have_key('compound_annual_growth_rate')
      expect(json_data['growth_rate_analysis']).to have_key('average_growth_rate')
    end

    it 'handles quiet mode output' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[growth-rate --quiet 100 110 121 133]) }

      # Should output CAGR and average growth rate separated by space
      values = output.strip.split
      expect(values.length).to eq(2)
      expect(values[0].to_f).to be_within(0.01).of(9.97)  # CAGR
      expect(values[1].to_f).to be_within(0.01).of(9.97)  # Average growth
    end

    it 'handles precision control' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[growth-rate --precision=1 100 110 121 133]) }

      expect(output).to include('CAGR')
      # Should display with 1 decimal place precision
      expect(output).to match(/\+\d+\.\d+%/)
    end

    it 'handles insufficient data error' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[growth-rate 100]) }

      expect(output).to include('エラー: データが不十分です（2つ以上の値が必要）')
    end

    it 'handles zero values appropriately' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[growth-rate 0 10 0]) }

      expect(output).to include('成長率分析:')
      expect(output).to include('+∞%') # Should show infinity symbol
      expect(output).to include('-100%') # Should show -100% for decline to zero
    end

    context 'with file input' do
      let(:csv_file) { 'test_growth_data.csv' }

      before do
        File.write(csv_file, "100\n110\n121\n133\n")
      end

      after do
        FileUtils.rm_f(csv_file)
      end

      it 'reads data from CSV file' do
        output = capture_stdout { NumberAnalyzer::CLI.run(['growth-rate', '--file', csv_file]) }

        expect(output).to include('成長率分析:')
        expect(output).to include('期間別成長率:')
      end
    end

    context 'help option' do
      it 'displays help message and exits' do
        expect { NumberAnalyzer::CLI.run(%w[growth-rate --help]) }
          .to output(/Usage: bundle exec number_analyzer growth-rate/).to_stdout
      end
    end
  end

  describe 'seasonal subcommand' do
    it 'calculates and displays seasonal decomposition analysis' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[seasonal 10 20 15 25 12 22 17 27]) }

      expect(output).to include('季節性分析結果:')
      expect(output).to include('検出周期:')
      expect(output).to include('季節指数:')
      expect(output).to include('季節性強度:')
      expect(output).to include('季節性判定:')
    end

    it 'handles JSON format output' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[seasonal --format=json 10 20 15 25 12 22 17 27]) }

      json_data = JSON.parse(output)
      expect(json_data).to have_key('seasonal_analysis')
      expect(json_data['seasonal_analysis']).to have_key('period')
      expect(json_data['seasonal_analysis']).to have_key('seasonal_indices')
      expect(json_data['seasonal_analysis']).to have_key('seasonal_strength')
      expect(json_data['seasonal_analysis']).to have_key('has_seasonality')
      expect(json_data).to have_key('dataset_size')
    end

    it 'handles quiet mode output' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[seasonal --quiet 10 20 15 25 12 22 17 27]) }

      values = output.strip.split
      expect(values.length).to eq(3) # period, strength, has_seasonality
      expect(values[0].to_i).to be > 0 # period
      expect(values[1].to_f).to be >= 0.0 # strength
      expect(%w[true false]).to include(values[2]) # has_seasonality boolean
    end

    it 'handles precision control' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[seasonal --precision=2 10 20 15 25 12 22 17 27]) }

      expect(output).to include('季節性分析結果:')
      # Check that precision is applied to seasonal indices and strength
      expect(output).to match(/\d+\.\d{2}/)
    end

    it 'handles manual period specification' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[seasonal --period=2 10 20 15 25 12 22]) }

      expect(output).to include('検出周期: 2')
      expect(output).to include('季節性分析結果:')
    end

    it 'handles insufficient data error' do
      output = capture_stdout { NumberAnalyzer::CLI.run(%w[seasonal 1 2 3]) }

      expect(output).to include('エラー: データが不十分です（季節性分析には最低4つの値が必要）')
    end

    it 'handles invalid period specification' do
      expect { NumberAnalyzer::CLI.run(%w[seasonal --period=1 10 20 15 25]) }
        .to output(/エラー: 周期は2以上である必要があります/).to_stdout
        .and raise_error(SystemExit)
    end

    it 'handles non-numeric period specification' do
      expect { NumberAnalyzer::CLI.run(%w[seasonal --period=abc 10 20 15 25]) }
        .to output("エラー: invalid argument: --period=abc\n").to_stdout
        .and raise_error(SystemExit)
    end

    context 'with file input' do
      let(:csv_file) { 'test_seasonal_data.csv' }

      before do
        File.write(csv_file, "10\n20\n15\n25\n12\n22\n17\n27\n")
      end

      after do
        FileUtils.rm_f(csv_file)
      end

      it 'reads data from CSV file' do
        output = capture_stdout { NumberAnalyzer::CLI.run(['seasonal', '--file', csv_file]) }

        expect(output).to include('季節性分析結果:')
        expect(output).to include('検出周期:')
      end

      it 'supports period option with file input' do
        output = capture_stdout { NumberAnalyzer::CLI.run(['seasonal', '--period=4', '--file', csv_file]) }

        expect(output).to include('検出周期: 4')
      end
    end

    context 'help option' do
      it 'displays help message and exits' do
        expect { NumberAnalyzer::CLI.run(%w[seasonal --help]) }
          .to output(/Usage: bundle exec number_analyzer seasonal/).to_stdout
      end
    end
  end
end

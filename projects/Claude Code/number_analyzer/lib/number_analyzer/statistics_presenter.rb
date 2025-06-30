# frozen_string_literal: true

require 'json'

# 統計結果の表示を担当するクラス
class NumberAnalyzer
  # Handles the presentation and formatting of statistical results
  class StatisticsPresenter
    def self.display_results(stats)
      puts "合計: #{stats[:total]}"
      puts "平均: #{stats[:average]}"
      puts "最大値: #{stats[:maximum]}"
      puts "最小値: #{stats[:minimum]}"
      puts "中央値: #{stats[:median_value]}"
      puts "分散: #{stats[:variance].round(2)}"
      puts "最頻値: #{format_mode(stats[:mode_values])}"
      puts "標準偏差: #{stats[:std_dev].round(2)}"
      puts "四分位範囲(IQR): #{stats[:iqr]&.round(2) || 'なし'}"
      puts "外れ値: #{format_outliers(stats[:outlier_values])}"
      puts "偏差値: #{format_deviation_scores(stats[:deviation_scores])}"
      puts # 空行を追加
      display_histogram(stats[:frequency_distribution])
    end

    def self.display_histogram(frequency_distribution)
      puts '度数分布ヒストグラム:'

      if frequency_distribution.nil? || frequency_distribution.empty?
        puts '(データが空です)'
        return
      end

      frequency_distribution.sort.each do |value, count|
        bar = '■' * count
        puts "#{value}: #{bar} (#{count})"
      end
    end

    def self.format_mode(mode_values)
      return 'なし' if mode_values.empty?

      mode_values.join(', ')
    end

    def self.format_outliers(outlier_values)
      return 'なし' if outlier_values.empty?

      outlier_values.join(', ')
    end

    def self.format_deviation_scores(deviation_scores)
      return 'なし' if deviation_scores.empty?

      deviation_scores.join(', ')
    end

    def self.format_levene_test(result, options = {})
      if options[:format] == 'json'
        format_levene_test_json(result, options)
      elsif options[:quiet]
        format_levene_test_quiet(result, options)
      else
        format_levene_test_verbose(result, options)
      end
    end

    def self.format_levene_test_verbose(result, options = {})
      precision = options[:precision] || 6

      output = []
      output << '=== Levene検定結果 (Brown-Forsythe修正版) ==='
      output << ''
      output << '検定統計量:'
      output << "  F統計量: #{result[:f_statistic].round(precision)}"
      output << "  p値: #{result[:p_value].round(precision)}"
      output << "  自由度: #{result[:degrees_of_freedom][0]}, #{result[:degrees_of_freedom][1]}"
      output << ''
      output << '統計的判定:'
      if result[:significant]
        output << '  結果: **有意差あり** (p < 0.05)'
        output << '  結論: 各グループの分散は等しくない'
      else
        output << '  結果: 有意差なし (p ≥ 0.05)'
        output << '  結論: 各グループの分散は等しいと考えられる'
      end
      output << ''
      output << '解釈:'
      output << "  #{result[:interpretation]}"
      output << ''
      output << '注意事項:'
      output << '  - Brown-Forsythe修正版は外れ値に対して頑健です'
      output << '  - この検定はANOVA分析の前提条件チェックに使用されます'

      output.join("\n")
    end

    def self.format_levene_test_json(result, options = {})
      precision = options[:precision] || 6

      formatted_result = {
        test_type: result[:test_type],
        f_statistic: result[:f_statistic].round(precision),
        p_value: result[:p_value].round(precision),
        degrees_of_freedom: result[:degrees_of_freedom],
        significant: result[:significant],
        interpretation: result[:interpretation]
      }

      JSON.generate(formatted_result)
    end

    def self.format_levene_test_quiet(result, options = {})
      precision = options[:precision] || 6
      f_stat = result[:f_statistic].round(precision)
      p_value = result[:p_value].round(precision)
      "#{f_stat} #{p_value}"
    end

    def self.format_bartlett_test(result, options = {})
      if options[:format] == 'json'
        format_bartlett_test_json(result, options)
      elsif options[:quiet]
        format_bartlett_test_quiet(result, options)
      else
        format_bartlett_test_verbose(result, options)
      end
    end

    def self.format_bartlett_test_verbose(result, options = {})
      precision = options[:precision] || 6

      output = []
      output.concat(build_bartlett_header)
      output.concat(build_bartlett_statistics(result, precision))
      output.concat(build_bartlett_interpretation(result))
      output.concat(build_bartlett_notes)

      output.join("\n")
    end

    def self.build_bartlett_header
      ['=== Bartlett検定結果 ===', '']
    end

    def self.build_bartlett_statistics(result, precision)
      [
        '検定統計量:',
        "  カイ二乗統計量: #{result[:chi_square_statistic].round(precision)}",
        "  p値: #{result[:p_value].round(precision)}",
        "  自由度: #{result[:degrees_of_freedom]}",
        "  補正係数: #{result[:correction_factor].round(precision)}",
        "  合併分散: #{result[:pooled_variance].round(precision)}",
        ''
      ]
    end

    def self.build_bartlett_interpretation(result)
      output = ['統計的判定:']
      if result[:significant]
        output << '  結果: **有意差あり** (p < 0.05)'
        output << '  結論: 各グループの分散は等しくない'
      else
        output << '  結果: 有意差なし (p ≥ 0.05)'
        output << '  結論: 各グループの分散は等しいと考えられる'
      end
      output << ''
      output << '解釈:'
      output << "  #{result[:interpretation]}"
      output << ''
    end

    def self.build_bartlett_notes
      [
        '注意事項:',
        '  - Bartlett検定は正規分布を仮定します',
        '  - 正規性が満たされる場合はLevene検定より高精度です',
        '  - この検定はANOVA分析の前提条件チェックに使用されます'
      ]
    end

    def self.format_bartlett_test_json(result, options = {})
      precision = options[:precision] || 6

      formatted_result = {
        test_type: result[:test_type],
        chi_square_statistic: result[:chi_square_statistic].round(precision),
        p_value: result[:p_value].round(precision),
        degrees_of_freedom: result[:degrees_of_freedom],
        significant: result[:significant],
        interpretation: result[:interpretation],
        correction_factor: result[:correction_factor].round(precision),
        pooled_variance: result[:pooled_variance].round(precision)
      }

      JSON.generate(formatted_result)
    end

    def self.format_bartlett_test_quiet(result, options = {})
      precision = options[:precision] || 6
      chi_square_stat = result[:chi_square_statistic].round(precision)
      p_value = result[:p_value].round(precision)
      "#{chi_square_stat} #{p_value}"
    end

    def self.format_kruskal_wallis_test(result, options = {})
      case options[:format]
      when 'json'
        format_kruskal_wallis_test_json(result, options)
      when 'quiet'
        format_kruskal_wallis_test_quiet(result, options)
      else
        format_kruskal_wallis_test_verbose(result, options)
      end
    end

    def self.format_kruskal_wallis_test_verbose(result, options = {})
      precision = options[:precision] || 6

      output = []
      output << build_kruskal_wallis_header
      output << build_kruskal_wallis_statistics(result, precision)
      output << build_kruskal_wallis_interpretation(result)
      output << build_kruskal_wallis_notes

      output.compact.join("\n")
    end

    def self.format_kruskal_wallis_test_json(result, options = {})
      precision = options[:precision] || 6

      formatted_result = {
        test_type: result[:test_type],
        h_statistic: result[:h_statistic].round(precision),
        p_value: result[:p_value].round(precision),
        degrees_of_freedom: result[:degrees_of_freedom],
        significant: result[:significant],
        interpretation: result[:interpretation],
        group_sizes: result[:group_sizes],
        total_n: result[:total_n]
      }

      JSON.generate(formatted_result)
    end

    def self.format_kruskal_wallis_test_quiet(result, options = {})
      precision = options[:precision] || 6
      h_stat = result[:h_statistic].round(precision)
      p_value = result[:p_value].round(precision)
      "#{h_stat} #{p_value}"
    end

    def self.build_kruskal_wallis_header
      '=== Kruskal-Wallis H検定 ==='
    end

    def self.build_kruskal_wallis_statistics(result, precision)
      [
        "H統計量: #{result[:h_statistic].round(precision)}",
        "自由度: #{result[:degrees_of_freedom]}",
        "p値: #{result[:p_value].round(precision)}",
        "総サンプル数: #{result[:total_n]}",
        "グループサイズ: #{result[:group_sizes].join(', ')}"
      ].join("\n")
    end

    def self.build_kruskal_wallis_interpretation(result)
      significance = result[:significant] ? '**有意**' : '非有意'
      [
        "結果: #{significance} (α = 0.05)",
        "解釈: #{result[:interpretation]}"
      ].join("\n")
    end

    def self.build_kruskal_wallis_notes
      [
        '',
        '注意事項:',
        '・ Kruskal-Wallis検定はノンパラメトリック検定です',
        '・ 正規分布の仮定は不要ですが、同一の分布形状を仮定します',
        '・ 有意差が見つかった場合は、事後検定（Dunn検定など）を検討してください'
      ].join("\n")
    end

    def self.format_mann_whitney_test(result, options = {})
      case options[:format]
      when 'json'
        format_mann_whitney_test_json(result, options)
      when 'quiet'
        format_mann_whitney_test_quiet(result, options)
      else
        format_mann_whitney_test_verbose(result, options)
      end
    end

    def self.format_mann_whitney_test_verbose(result, options = {})
      precision = options[:precision] || 6

      output = []
      output << build_mann_whitney_header
      output << build_mann_whitney_statistics(result, precision)
      output << build_mann_whitney_interpretation(result)
      output << build_mann_whitney_notes

      output.compact.join("\n")
    end

    def self.format_mann_whitney_test_json(result, options = {})
      precision = options[:precision] || 6

      formatted_result = {
        test_type: result[:test_type],
        u_statistic: result[:u_statistic].round(precision),
        u1: result[:u1].round(precision),
        u2: result[:u2].round(precision),
        z_statistic: result[:z_statistic].round(precision),
        p_value: result[:p_value].round(precision),
        significant: result[:significant],
        interpretation: result[:interpretation],
        effect_size: result[:effect_size].round(precision),
        group_sizes: result[:group_sizes],
        rank_sums: result[:rank_sums],
        total_n: result[:total_n]
      }

      JSON.generate(formatted_result)
    end

    def self.format_mann_whitney_test_quiet(result, options = {})
      precision = options[:precision] || 6
      u_stat = result[:u_statistic].round(precision)
      p_value = result[:p_value].round(precision)
      "#{u_stat} #{p_value}"
    end

    def self.build_mann_whitney_header
      '=== Mann-Whitney U検定 ==='
    end

    def self.build_mann_whitney_statistics(result, precision)
      [
        "U統計量: #{result[:u_statistic].round(precision)}",
        "U1: #{result[:u1].round(precision)}, U2: #{result[:u2].round(precision)}",
        "z統計量: #{result[:z_statistic].round(precision)}",
        "p値: #{result[:p_value].round(precision)}",
        "効果サイズ (r): #{result[:effect_size].round(precision)}",
        "グループサイズ: #{result[:group_sizes].join(', ')}",
        "順位和: #{result[:rank_sums].join(', ')}"
      ].join("\n")
    end

    def self.build_mann_whitney_interpretation(result)
      significance = result[:significant] ? '**有意**' : '非有意'
      effect_magnitude = case result[:effect_size]
                         when 0.0...0.1
                           '効果サイズ: 極小'
                         when 0.1...0.3
                           '効果サイズ: 小'
                         when 0.3...0.5
                           '効果サイズ: 中'
                         else
                           '効果サイズ: 大'
                         end

      [
        "結果: #{significance} (α = 0.05)",
        "解釈: #{result[:interpretation]}",
        effect_magnitude
      ].join("\n")
    end

    def self.build_mann_whitney_notes
      [
        '',
        '注意事項:',
        '・ Mann-Whitney U検定は2群比較のノンパラメトリック検定です',
        '・ t検定の代替として正規分布を仮定しない場合に使用します',
        '・ 順位に基づく検定のため外れ値に頑健です',
        '・ 同じ分布形状を仮定しますが、位置（中央値）の違いを検定します'
      ].join("\n")
    end

    private_class_method :format_mode, :format_outliers, :format_deviation_scores, :display_histogram,
                         :format_levene_test_verbose, :format_levene_test_json, :format_levene_test_quiet,
                         :format_bartlett_test_verbose, :format_bartlett_test_json, :format_bartlett_test_quiet,
                         :build_bartlett_header, :build_bartlett_statistics,
                         :build_bartlett_interpretation, :build_bartlett_notes,
                         :format_kruskal_wallis_test_verbose, :format_kruskal_wallis_test_json,
                         :format_kruskal_wallis_test_quiet, :build_kruskal_wallis_header,
                         :build_kruskal_wallis_statistics, :build_kruskal_wallis_interpretation,
                         :build_kruskal_wallis_notes,
                         :format_mann_whitney_test_verbose, :format_mann_whitney_test_json,
                         :format_mann_whitney_test_quiet, :build_mann_whitney_header,
                         :build_mann_whitney_statistics, :build_mann_whitney_interpretation,
                         :build_mann_whitney_notes
  end
end

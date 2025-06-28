# frozen_string_literal: true

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
      puts "度数分布ヒストグラム:"
      
      if frequency_distribution.nil? || frequency_distribution.empty?
        puts "(データが空です)"
        return
      end
      
      frequency_distribution.sort.each do |value, count|
        bar = "■" * count
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

    private_class_method :format_mode, :format_outliers, :format_deviation_scores, :display_histogram
  end
end

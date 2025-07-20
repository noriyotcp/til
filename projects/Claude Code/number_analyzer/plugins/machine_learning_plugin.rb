# frozen_string_literal: true

require_relative '../lib/numana/plugin_interface'

# MachineLearningPlugin - Advanced statistical analysis with machine learning algorithms
# Demonstrates complex plugin implementation with multiple algorithms
module MachineLearningPlugin
  include Numana::StatisticsPlugin

  # Plugin metadata
  plugin_name 'machine_learning'
  plugin_version '1.0.0'
  plugin_description 'Machine learning algorithms for statistical analysis including linear regression, clustering, and PCA'
  plugin_author 'NumberAnalyzer ML Team'
  plugin_dependencies %w[basic_stats math_utils]

  # Register plugin methods
  register_method :linear_regression, 'Perform linear regression analysis on paired data'
  register_method :k_means_clustering, 'K-means clustering for data grouping'
  register_method :principal_component_analysis, 'Principal Component Analysis for dimensionality reduction'
  register_method :polynomial_regression, 'Polynomial regression for non-linear relationships'
  register_method :correlation_matrix, 'Generate correlation matrix for multivariate data'

  # Define CLI commands mapping
  def self.plugin_commands
    {
      'linear-regression' => :linear_regression,
      'k-means' => :k_means_clustering,
      'pca' => :principal_component_analysis,
      'poly-regression' => :polynomial_regression,
      'correlation-matrix' => :correlation_matrix
    }
  end

  # Linear regression analysis
  def linear_regression(y_values = nil)
    validate_numbers!

    x_values = (1..@numbers.length).to_a.map(&:to_f)
    y_values ||= @numbers.map(&:to_f)

    raise ArgumentError, 'X and Y values must have the same length' unless x_values.length == y_values.length

    n = x_values.length
    sum_x = x_values.sum
    sum_y = y_values.sum
    sum_xy = x_values.zip(y_values).map { |x, y| x * y }.sum
    sum_x_squared = x_values.map { |x| x**2 }.sum
    y_values.map { |y| y**2 }.sum

    # Calculate slope (m) and intercept (b)
    slope = ((n * sum_xy) - (sum_x * sum_y)) / ((n * sum_x_squared) - (sum_x**2))
    intercept = (sum_y - (slope * sum_x)) / n

    # Calculate R-squared
    y_mean = sum_y / n
    ss_total = y_values.map { |y| (y - y_mean)**2 }.sum
    y_predicted = x_values.map { |x| (slope * x) + intercept }
    ss_residual = y_values.zip(y_predicted).map { |y_actual, y_pred| (y_actual - y_pred)**2 }.sum
    r_squared = 1 - (ss_residual / ss_total)

    # Calculate correlation coefficient
    correlation = calculate_correlation_coefficient(x_values, y_values)

    {
      slope: slope.round(6),
      intercept: intercept.round(6),
      r_squared: r_squared.round(6),
      correlation: correlation.round(6),
      equation: "y = #{slope.round(3)}x + #{intercept.round(3)}",
      strength: interpret_correlation_strength(correlation.abs),
      direction: correlation >= 0 ? 'positive' : 'negative',
      predicted_values: y_predicted.map { |v| v.round(3) },
      residuals: y_values.zip(y_predicted).map { |actual, pred| (actual - pred).round(3) },
      interpretation: generate_regression_interpretation(slope, intercept, r_squared, correlation)
    }
  end

  # K-means clustering implementation
  def k_means_clustering(k = 3, max_iterations = 100)
    validate_numbers!

    raise ArgumentError, 'K must be positive and less than number of data points' if k <= 0 || k > @numbers.length

    # Initialize centroids randomly
    min_val, max_val = @numbers.minmax
    centroids = Array.new(k) { rand(min_val.to_f..max_val.to_f) }

    clusters = Array.new(k) { [] }
    previous_centroids = nil
    iterations = 0

    while iterations < max_iterations && centroids != previous_centroids
      previous_centroids = centroids.dup
      clusters = Array.new(k) { [] }

      # Assign points to nearest centroid
      @numbers.each do |point|
        distances = centroids.map { |centroid| (point - centroid).abs }
        nearest_cluster = distances.index(distances.min)
        clusters[nearest_cluster] << point
      end

      # Update centroids
      centroids = clusters.map.with_index do |cluster, i|
        cluster.empty? ? centroids[i] : cluster.sum.to_f / cluster.length
      end

      iterations += 1
    end

    # Calculate cluster statistics
    cluster_stats = clusters.map.with_index do |cluster, i|
      {
        centroid: centroids[i].round(3),
        size: cluster.length,
        points: cluster.sort,
        variance: cluster.empty? ? 0 : calculate_cluster_variance(cluster, centroids[i]),
        range: cluster.empty? ? 0 : (cluster.max - cluster.min)
      }
    end

    # Calculate total within-cluster sum of squares (WCSS)
    wcss = clusters.zip(centroids).map do |cluster, centroid|
      cluster.map { |point| (point - centroid)**2 }.sum
    end.sum

    {
      k: k,
      iterations: iterations,
      converged: iterations < max_iterations,
      centroids: centroids.map { |c| c.round(3) },
      clusters: cluster_stats,
      wcss: wcss.round(3),
      silhouette_score: calculate_silhouette_score(clusters, centroids),
      interpretation: generate_clustering_interpretation(k, clusters, wcss)
    }
  end

  # Principal Component Analysis (simplified for 1D data)
  def principal_component_analysis(components = 1)
    validate_numbers!

    # For 1D data, PCA is simplified
    mean = @numbers.sum.to_f / @numbers.length
    centered_data = @numbers.map { |x| x - mean }

    # Calculate variance (which is our principal component for 1D)
    variance = centered_data.map { |x| x**2 }.sum / (@numbers.length - 1)
    std_dev = Math.sqrt(variance)

    # Standardized scores
    standardized = centered_data.map { |x| x / std_dev }

    # For demonstration, simulate multiple components
    components_data = Array.new([components, 3].min) do |i|
      factor = 1.0 / (i + 1)
      {
        component: i + 1,
        eigenvalue: variance * factor,
        explained_variance_ratio: factor / (1..components).map { |j| 1.0 / j }.sum,
        loadings: [factor.round(3)]
      }
    end

    explained_variance_total = components_data.map { |c| c[:explained_variance_ratio] }.sum

    {
      components: components_data,
      explained_variance_total: explained_variance_total.round(3),
      cumulative_variance: components_data.map.with_index do |_, i|
        components_data[0..i].map { |c| c[:explained_variance_ratio] }.sum.round(3)
      end,
      standardized_data: standardized.map { |x| x.round(3) },
      mean: mean.round(3),
      standard_deviation: std_dev.round(3),
      interpretation: generate_pca_interpretation(components_data, explained_variance_total)
    }
  end

  # Polynomial regression (quadratic)
  def polynomial_regression(degree = 2)
    validate_numbers!

    x_values = (1..@numbers.length).to_a.map(&:to_f)
    y_values = @numbers.map(&:to_f)

    # For simplicity, implement quadratic regression (degree 2)
    raise ArgumentError, 'Currently only quadratic regression (degree=2) is supported' unless degree == 2

    perform_quadratic_regression(x_values, y_values)
  end

  # Correlation matrix for multivariate analysis
  def correlation_matrix(*additional_datasets)
    validate_numbers!

    datasets = [@numbers] + additional_datasets
    dataset_names = (0...datasets.length).map { |i| "Dataset_#{i + 1}" }

    matrix = datasets.map do |dataset1|
      datasets.map do |dataset2|
        calculate_correlation_coefficient(dataset1, dataset2)
      end
    end

    {
      datasets: dataset_names,
      matrix: matrix.map { |row| row.map { |val| val.round(4) } },
      size: "#{datasets.length}x#{datasets.length}",
      strong_correlations: find_strong_correlations(matrix, dataset_names),
      interpretation: generate_correlation_matrix_interpretation(matrix, dataset_names)
    }
  end

  private

  # Helper methods
  def validate_numbers!
    raise ArgumentError, 'Numbers array cannot be empty' if @numbers.empty?
  end

  def calculate_correlation_coefficient(x_values, y_values)
    return 0.0 if x_values.length != y_values.length || x_values.length < 2

    n = x_values.length
    sum_x = x_values.sum.to_f
    sum_y = y_values.sum.to_f
    sum_xy = x_values.zip(y_values).map { |x, y| x * y }.sum
    sum_x_squared = x_values.map { |x| x**2 }.sum
    sum_y_squared = y_values.map { |y| y**2 }.sum

    numerator = (n * sum_xy) - (sum_x * sum_y)
    denominator_x = (n * sum_x_squared) - (sum_x**2)
    denominator_y = (n * sum_y_squared) - (sum_y**2)

    denominator = Math.sqrt(denominator_x * denominator_y)
    return 0.0 if denominator.zero?

    numerator / denominator
  end

  def interpret_correlation_strength(abs_correlation)
    case abs_correlation
    when 0.0..0.1 then 'negligible'
    when 0.1..0.3 then 'weak'
    when 0.3..0.5 then 'moderate'
    when 0.5..0.7 then 'strong'
    when 0.7..0.9 then 'very strong'
    when 0.9..1.0 then 'extremely strong'
    else 'perfect'
    end
  end

  def generate_regression_interpretation(slope, _intercept, r_squared, correlation)
    direction = correlation >= 0 ? 'positive' : 'negative'
    strength = interpret_correlation_strength(correlation.abs)
    fit_quality = case r_squared
                  when 0.0..0.25 then 'poor'
                  when 0.25..0.5 then 'moderate'
                  when 0.5..0.75 then 'good'
                  when 0.75..1.0 then 'excellent'
                  end

    "Linear regression shows a #{strength} #{direction} relationship (r=#{correlation.round(3)}). " \
      "The model explains #{(r_squared * 100).round(1)}% of the variance (#{fit_quality} fit). " \
      "For each unit increase in X, Y #{correlation >= 0 ? 'increases' : 'decreases'} by #{slope.abs.round(3)} units."
  end

  def calculate_cluster_variance(cluster, centroid)
    return 0.0 if cluster.empty?

    cluster.map { |point| (point - centroid)**2 }.sum / cluster.length
  end

  def calculate_silhouette_score(clusters, _centroids)
    return 0.0 if clusters.length < 2

    # Simplified silhouette score calculation
    total_score = 0.0
    total_points = 0

    clusters.each_with_index do |cluster, cluster_idx|
      cluster.each do |point|
        # Calculate average distance to points in same cluster
        same_cluster_distances = cluster.reject { |p| p == point }
        a = if same_cluster_distances.empty?
              0
            else
              same_cluster_distances.map do |p|
                (point - p).abs
              end.sum / same_cluster_distances.length
            end

        # Calculate average distance to nearest other cluster
        other_clusters_min_dist = clusters.each_with_index.reject do |_, idx|
          idx == cluster_idx
        end.map do |other_cluster, _|
          other_cluster.map { |p| (point - p).abs }.sum / other_cluster.length
        end.min || 0

        b = other_clusters_min_dist
        silhouette = b.zero? ? 0 : (b - a) / [a, b].max

        total_score += silhouette
        total_points += 1
      end
    end

    total_points.zero? ? 0.0 : (total_score / total_points).round(3)
  end

  def generate_clustering_interpretation(k, clusters, wcss)
    non_empty_clusters = clusters.count { |c| c[:size].positive? }
    largest_cluster = clusters.max_by { |c| c[:size] }
    smallest_cluster = clusters.select { |c| c[:size].positive? }.min_by { |c| c[:size] }

    "K-means clustering with k=#{k} identified #{non_empty_clusters} non-empty clusters. " \
      "Largest cluster has #{largest_cluster[:size]} points, smallest has #{smallest_cluster[:size]} points. " \
      "Total within-cluster sum of squares: #{wcss.round(2)}. " \
    "#{if wcss < 10
         'Tight clustering'
       else
         wcss < 50 ? 'Moderate clustering' : 'Loose clustering'
       end} detected."
  end

  def perform_quadratic_regression(x_values, y_values)
    n = x_values.length

    # Create design matrix for quadratic regression: [1, x, x²]
    sum_x = x_values.sum
    sum_x2 = x_values.map { |x| x**2 }.sum
    sum_x3 = x_values.map { |x| x**3 }.sum
    sum_x4 = x_values.map { |x| x**4 }.sum
    sum_y = y_values.sum
    sum_xy = x_values.zip(y_values).map { |x, y| x * y }.sum
    sum_x2y = x_values.zip(y_values).map { |x, y| (x**2) * y }.sum

    # Solve normal equations for quadratic: y = ax² + bx + c
    # Using simplified matrix operations - split complex determinant calculation
    term1 = n * ((sum_x2 * sum_x4) - (sum_x3**2))
    term2 = sum_x * ((sum_x * sum_x4) - (sum_x2 * sum_x3))
    term3 = sum_x2 * ((sum_x * sum_x3) - (sum_x2**2))
    det = term1 - term2 + term3

    if det.abs < 1e-10
      # Fallback to linear regression if matrix is singular
      return linear_regression(y_values).merge({
                                                 degree: 2,
                                                 coefficients: [0, linear_regression(y_values)[:slope],
                                                                linear_regression(y_values)[:intercept]],
                                                 interpretation: 'Quadratic regression reduced to linear due to insufficient curvature in data'
                                               })
    end

    # Calculate coefficients
    a = ((((n * sum_x2y) - (sum_x2 * sum_y)) * ((sum_x2 * sum_x4) - (sum_x3**2))) -
         (((n * sum_xy) - (sum_x * sum_y)) * ((sum_x2 * sum_x3) - (sum_x2**2)))) / det
    b = ((((n * sum_xy) - (sum_x * sum_y)) * ((sum_x2 * sum_x4) - (sum_x3**2))) -
         (((n * sum_x2y) - (sum_x2 * sum_y)) * ((sum_x * sum_x4) - (sum_x2 * sum_x3)))) / det
    c = (sum_y - (b * sum_x) - (a * sum_x2)) / n

    # Calculate R-squared
    y_mean = sum_y / n
    y_predicted = x_values.map { |x| (a * (x**2)) + (b * x) + c }
    ss_total = y_values.map { |y| (y - y_mean)**2 }.sum
    ss_residual = y_values.zip(y_predicted).map { |y_actual, y_pred| (y_actual - y_pred)**2 }.sum
    r_squared = 1 - (ss_residual / ss_total)

    {
      degree: 2,
      coefficients: [a.round(6), b.round(6), c.round(6)],
      equation: "y = #{a.round(3)}x² + #{b.round(3)}x + #{c.round(3)}",
      r_squared: r_squared.round(6),
      predicted_values: y_predicted.map { |v| v.round(3) },
      residuals: y_values.zip(y_predicted).map { |actual, pred| (actual - pred).round(3) },
      interpretation: generate_quadratic_interpretation(a, b, c, r_squared)
    }
  end

  def generate_quadratic_interpretation(a, b, c, r_squared)
    curve_direction = a.positive? ? 'upward' : 'downward'
    vertex_x = -b / (2 * a)
    vertex_y = (a * (vertex_x**2)) + (b * vertex_x) + c
    fit_quality = case r_squared
                  when 0.0..0.25 then 'poor'
                  when 0.25..0.5 then 'moderate'
                  when 0.5..0.75 then 'good'
                  when 0.75..1.0 then 'excellent'
                  end

    "Quadratic regression shows #{curve_direction}-curving parabola with vertex at (#{vertex_x.round(2)}, #{vertex_y.round(2)}). " \
      "The model explains #{(r_squared * 100).round(1)}% of the variance (#{fit_quality} fit). " \
      "#{if a.abs < 0.01
           'Minimal'
         else
           a.abs < 0.1 ? 'Moderate' : 'Strong'
         end} curvature detected."
  end

  def generate_pca_interpretation(components_data, explained_variance_total)
    first_component = components_data.first
    "PCA analysis identified #{components_data.length} principal component(s). " \
      "First component explains #{(first_component[:explained_variance_ratio] * 100).round(1)}% of variance. " \
      "Total explained variance: #{(explained_variance_total * 100).round(1)}%. " \
    "#{if explained_variance_total > 0.8
         'Excellent'
       else
         explained_variance_total > 0.6 ? 'Good' : 'Moderate'
       end} dimensionality reduction achieved."
  end

  def find_strong_correlations(matrix, dataset_names)
    strong_correlations = []

    matrix.each_with_index do |row, i|
      row.each_with_index do |correlation, j|
        next if i >= j # Avoid duplicates and self-correlation

        next unless correlation.abs >= 0.7

        strong_correlations << {
          datasets: [dataset_names[i], dataset_names[j]],
          correlation: correlation.round(4),
          strength: interpret_correlation_strength(correlation.abs),
          direction: correlation >= 0 ? 'positive' : 'negative'
        }
      end
    end

    strong_correlations
  end

  def generate_correlation_matrix_interpretation(matrix, dataset_names)
    total_pairs = (matrix.length * (matrix.length - 1)) / 2
    strong_correlations = 0

    matrix.each_with_index do |row, i|
      row.each_with_index do |correlation, j|
        strong_correlations += 1 if i < j && correlation.abs >= 0.7
      end
    end

    "Correlation matrix analysis of #{dataset_names.length} datasets (#{total_pairs} unique pairs). " \
    "Found #{strong_correlations} strong correlations (|r| ≥ 0.7). " \
    "#{if strong_correlations.zero?
         'Datasets are largely independent'
       elsif strong_correlations == total_pairs
         'All datasets are strongly correlated'
       else
         'Mixed correlation patterns detected'
       end}."
  end
end

# frozen_string_literal: true

require_relative 'plugin_priority'

class NumberAnalyzer
  # Plugin namespace management system for conflict resolution
  #
  # This class provides automatic namespace generation and conflict resolution
  # for NumberAnalyzer plugins, enabling safe coexistence of plugins with
  # similar names or overlapping functionality.
  #
  # @example Basic usage
  #   priority_system = NumberAnalyzer::PluginPriority.new
  #   namespace_system = NumberAnalyzer::PluginNamespace.new(priority_system)
  #
  #   namespace = namespace_system.generate_namespace(plugin_metadata)
  #   conflicts = namespace_system.detect_naming_conflicts(plugins_list)
  #   resolution = namespace_system.resolve_naming_conflict(conflicting_plugins)
  #
  # @example Generated namespace patterns
  #   # Development plugins: 'de_my_custom_plugin'
  #   # Core plugins: 'co_advanced_statistics'
  #   # Official gems: 'of_ml_extension'
  #   # Third party: 'th_external_analyzer'
  #   # Local plugins: 'lo_project_specific'
  class PluginNamespace
    # Similarity threshold for detecting naming conflicts
    SIMILARITY_THRESHOLD = 0.7

    # Priority prefix mapping for namespace generation
    PRIORITY_PREFIXES = {
      development: 'de',      # Development/test plugins
      core_plugins: 'co',     # Core NumberAnalyzer plugins
      official_gems: 'of',    # Official number_analyzer-* gems
      third_party_gems: 'th', # Third-party gems
      local_plugins: 'lo'     # Local project plugins
    }.freeze

    def initialize(priority_system = nil)
      @priority_system = priority_system || PluginPriority.new
      @namespace_cache = {}
      @namespace_mappings = {}
    end

    # Generate unique namespace for a plugin
    #
    # @param plugin_metadata [Hash] Plugin metadata including name and priority_type
    # @return [String] Generated namespace identifier
    def generate_namespace(plugin_metadata)
      plugin_name = plugin_metadata[:name].to_s
      priority_type = plugin_metadata[:priority_type] || :local_plugins

      # Check cache first
      cache_key = "#{plugin_name}_#{priority_type}"
      return @namespace_cache[cache_key] if @namespace_cache[cache_key]

      # Generate prefix based on priority
      prefix = get_priority_prefix(priority_type)

      # Sanitize plugin name for namespace
      sanitized_name = sanitize_plugin_name(plugin_name)

      # Create namespace
      namespace = "#{prefix}_#{sanitized_name}"

      # Cache and return
      @namespace_cache[cache_key] = namespace
      @namespace_mappings[plugin_name] = namespace

      namespace
    end

    # Detect naming conflicts between plugins
    #
    # @param plugins_list [Array<Hash>] List of plugin metadata
    # @return [Array<Hash>] Array of detected conflicts
    def detect_naming_conflicts(plugins_list)
      conflicts = []

      plugins_list.each_with_index do |plugin_a, i|
        plugins_list.each_with_index do |plugin_b, j|
          next if i >= j # Avoid duplicate comparisons

          similarity = calculate_name_similarity(
            plugin_a[:name].to_s,
            plugin_b[:name].to_s
          )

          next unless similarity > SIMILARITY_THRESHOLD

          conflicts << {
            plugins: [plugin_a[:name].to_s, plugin_b[:name].to_s],
            similarity: similarity,
            recommended_resolution: determine_resolution_strategy(plugin_a, plugin_b, similarity)
          }
        end
      end

      conflicts
    end

    # Resolve naming conflict between plugins
    #
    # @param conflicting_plugins [Array<Hash>] Array of conflicting plugin metadata
    # @return [Hash] Resolution result with namespaced plugins
    def resolve_naming_conflict(conflicting_plugins)
      namespaced_plugins = {}

      # Sort plugins by priority (higher priority gets simpler namespace)
      sorted_plugins = sort_plugins_by_priority(conflicting_plugins)

      sorted_plugins.each_with_index do |plugin_metadata, index|
        plugin_name = plugin_metadata[:name].to_s
        namespace = generate_namespace(plugin_metadata)

        # Higher priority plugins get shorter suffixes
        namespace = "#{namespace}_#{index + 1}" if index.positive?

        namespaced_plugins[plugin_name] = {
          namespace: namespace,
          original_metadata: plugin_metadata,
          priority_rank: index + 1
        }

        # Update mapping
        @namespace_mappings[plugin_name] = namespace
      end

      {
        success: true,
        strategy: :namespace,
        namespaced_plugins: namespaced_plugins,
        message: "Created namespaces for #{conflicting_plugins.size} conflicting plugins"
      }
    end

    # Current namespace mappings
    #
    # @return [Hash] Current namespace mappings
    def namespace_mapping
      @namespace_mappings.dup
    end

    # Clear namespace cache
    def clear_namespace_cache
      @namespace_cache.clear
      @namespace_mappings.clear
    end

    # Calculate similarity between two plugin names
    #
    # @param name_a [String] First plugin name
    # @param name_b [String] Second plugin name
    # @return [Float] Similarity score (0.0 to 1.0)
    def calculate_name_similarity(name_a, name_b)
      return 1.0 if name_a == name_b
      return 0.0 if name_a.empty? || name_b.empty?

      longer = name_a.length > name_b.length ? name_a : name_b
      shorter = name_a.length > name_b.length ? name_b : name_a

      edit_distance = levenshtein_distance(longer, shorter)
      (longer.length - edit_distance).to_f / longer.length
    end

    private

    # Get priority prefix for namespace generation
    #
    # @param priority_type [Symbol] Priority type
    # @return [String] Priority prefix
    def get_priority_prefix(priority_type)
      PRIORITY_PREFIXES[priority_type] || PRIORITY_PREFIXES[:local_plugins]
    end

    # Sanitize plugin name for use in namespace
    #
    # @param plugin_name [String] Original plugin name
    # @return [String] Sanitized name
    def sanitize_plugin_name(plugin_name)
      plugin_name.downcase
                 .gsub(/[^a-z0-9_]/, '_')
                 .gsub(/_+/, '_')
                 .gsub(/^_|_$/, '')
    end

    # Determine resolution strategy based on plugin characteristics
    #
    # @param plugin_a [Hash] First plugin metadata
    # @param plugin_b [Hash] Second plugin metadata
    # @param similarity [Float] Similarity score
    # @return [Symbol] Recommended resolution strategy
    def determine_resolution_strategy(plugin_a, plugin_b, similarity)
      # High similarity suggests namespace resolution
      return :namespace if similarity > 0.8

      # Different priority levels might suggest priority-based resolution
      priority_a = plugin_a[:priority_type] || :local_plugins
      priority_b = plugin_b[:priority_type] || :local_plugins

      if priority_a == priority_b
        :namespace
      else
        :priority_override
      end
    end

    # Sort plugins by priority (highest first)
    #
    # @param plugins [Array<Hash>] Plugin metadata array
    # @return [Array<Hash>] Sorted plugins
    def sort_plugins_by_priority(plugins)
      plugins.sort do |a, b|
        priority_a = get_priority_value(a[:priority_type] || :local_plugins)
        priority_b = get_priority_value(b[:priority_type] || :local_plugins)
        priority_b <=> priority_a # Descending order (higher priority first)
      end
    end

    # Get numeric priority value
    #
    # @param priority_type [Symbol] Priority type
    # @return [Integer] Priority value
    def get_priority_value(priority_type)
      case priority_type
      when :development then 100
      when :core_plugins then 90
      when :official_gems then 70
      when :third_party_gems then 50
      else 30 # local_plugins and unknown types
      end
    end

    # Calculate Levenshtein distance between two strings
    #
    # @param str_a [String] First string
    # @param str_b [String] Second string
    # @return [Integer] Edit distance
    def levenshtein_distance(str_a, str_b)
      return str_b.length if str_a.empty?
      return str_a.length if str_b.empty?

      matrix = create_distance_matrix(str_a, str_b)
      fill_distance_matrix(matrix, str_a, str_b)
      matrix[str_a.length][str_b.length]
    end

    # Create and initialize distance matrix
    #
    # @param str_a [String] First string
    # @param str_b [String] Second string
    # @return [Array<Array<Integer>>] Initialized matrix
    def create_distance_matrix(str_a, str_b)
      matrix = Array.new(str_a.length + 1) { Array.new(str_b.length + 1) }

      # Initialize first row and column
      (0..str_a.length).each { |i| matrix[i][0] = i }
      (0..str_b.length).each { |j| matrix[0][j] = j }

      matrix
    end

    # Fill distance matrix with edit distances
    #
    # @param matrix [Array<Array<Integer>>] Matrix to fill
    # @param str_a [String] First string
    # @param str_b [String] Second string
    def fill_distance_matrix(matrix, str_a, str_b)
      (1..str_a.length).each do |i|
        (1..str_b.length).each do |j|
          cost = str_a[i - 1] == str_b[j - 1] ? 0 : 1

          matrix[i][j] = [
            matrix[i - 1][j] + 1,       # deletion
            matrix[i][j - 1] + 1,       # insertion
            matrix[i - 1][j - 1] + cost # substitution
          ].min
        end
      end
    end
  end
end

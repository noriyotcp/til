# frozen_string_literal: true

# Conflict Resolution Strategies Module
# Contains all strategy implementations for resolving plugin conflicts
# This module provides various resolution approaches for different conflict scenarios
module ConflictResolutionStrategies
  # Strict resolution: fail immediately on conflict
  def resolve_strict(conflict_type, conflicting_plugins)
    error_message = "Conflict detected for #{conflict_type}: #{conflicting_plugins.join(', ')}"
    { status: :error, message: error_message }
  end

  # Warn and override using priority system
  def resolve_warn_override(conflict_type, conflicting_plugins)
    highest_priority_plugin = select_highest_priority_plugin(conflicting_plugins)
    overridden_plugins = conflicting_plugins - [highest_priority_plugin]

    warn "Plugin conflict resolved: #{conflict_type} from #{overridden_plugins.join(', ')} " \
         "overridden by #{highest_priority_plugin}"

    {
      status: :resolved,
      chosen_plugin: highest_priority_plugin,
      overridden_plugins: overridden_plugins,
      strategy: :warn_override
    }
  end

  # Silent override using priority system
  def resolve_silent_override(_conflict_type, conflicting_plugins)
    highest_priority_plugin = select_highest_priority_plugin(conflicting_plugins)
    overridden_plugins = conflicting_plugins - [highest_priority_plugin]

    {
      status: :resolved,
      chosen_plugin: highest_priority_plugin,
      overridden_plugins: overridden_plugins,
      strategy: :silent_override
    }
  end

  # Use namespaced plugin names
  def resolve_namespace(_conflict_type, conflicting_plugins)
    namespaced_plugins = conflicting_plugins.to_h do |plugin_name|
      namespaced_name = @namespace_system.generate_namespace(plugin_name)
      [plugin_name, namespaced_name]
    end

    {
      status: :resolved,
      strategy: :namespace,
      namespaced_plugins: namespaced_plugins,
      original_plugins: conflicting_plugins
    }
  end

  # Interactive resolution with user prompt
  def resolve_interactive(conflict_type, conflicting_plugins)
    cache_key = generate_cache_key(conflict_type, conflicting_plugins)
    cached_response = @interactive_responses[cache_key]

    response = cached_response || get_interactive_response(cache_key, conflict_type, conflicting_plugins)
    @interactive_responses[cache_key] = response

    handle_interactive_response(response, conflict_type, conflicting_plugins)
  end

  # Automatic resolution using heuristics
  def resolve_auto(conflict_type, conflicting_plugins)
    # Special handling for validators - try to chain them
    return resolve_chain_validators(conflicting_plugins) if conflict_type == :validator

    # For other types, use priority-based resolution with namespace fallback
    select_highest_priority_plugin(conflicting_plugins)
    similar_names = conflicting_plugins.any? do |p1|
      conflicting_plugins.any? { |p2| p1 != p2 && similar_plugin_names?(p1, p2) }
    end

    if similar_names
      resolve_namespace(conflict_type, conflicting_plugins)
    else
      resolve_silent_override(conflict_type, conflicting_plugins)
    end
  end

  private

  # Chain validators together for comprehensive validation
  def resolve_chain_validators(conflicting_plugins)
    {
      status: :resolved,
      strategy: :chain,
      chained_validators: conflicting_plugins,
      execution_order: conflicting_plugins.sort do |a, b|
        @priority_system.get(b) <=> @priority_system.get(a)
      end
    }
  end

  # Get interactive response from user or cache
  def get_interactive_response(_cache_key, conflict_type, conflicting_plugins)
    display_conflict_info(conflict_type, conflicting_plugins)
    display_resolution_options(conflicting_plugins)
    input = get_user_input(conflicting_plugins.length)
    parse_user_input(input, conflicting_plugins)
  end

  # Display conflict information to user
  def display_conflict_info(conflict_type, conflicting_plugins)
    puts "Plugin conflict detected for #{conflict_type}:"
    puts "Conflicting plugins: #{conflicting_plugins.join(', ')}"
  end

  # Display available resolution options
  def display_resolution_options(conflicting_plugins)
    puts "\nOptions:"
    puts "1. Select highest priority plugin (#{select_highest_priority_plugin(conflicting_plugins)})"
    puts '2. Use namespaced plugins'
    puts '3. Select specific plugin'
    puts '4. Cancel operation'

    conflicting_plugins.each_with_index do |plugin, index|
      priority = @priority_system.get(plugin)
      puts "   #{index + 5}. #{plugin} (priority: #{priority})"
    end
  end

  # Get user input
  def get_user_input(plugin_count)
    print "\nChoose option (1-#{4 + plugin_count}): "
    gets.chomp.to_i
  end

  # Parse user input to resolution strategy
  def parse_user_input(input, conflicting_plugins)
    if input == 1
      'priority'
    elsif input == 2
      'namespace'
    elsif input == 3
      'select'
    elsif input == 4
      'cancel'
    elsif input.between?(5, 4 + conflicting_plugins.length)
      conflicting_plugins[input - 5]
    else
      puts 'Invalid input. Using priority strategy as default.'
      'priority'
    end
  end

  # Handle the interactive response
  def handle_interactive_response(response, conflict_type, conflicting_plugins)
    case response
    when 'priority'
      resolve_silent_override(conflict_type, conflicting_plugins)
    when 'namespace'
      resolve_namespace(conflict_type, conflicting_plugins)
    when 'cancel'
      handle_cancel_response
    when 'select'
      handle_select_plugin_response(response, conflict_type, conflicting_plugins)
    else
      # Specific plugin selected or fallback
      if conflicting_plugins.include?(response)
        {
          status: :resolved,
          chosen_plugin: response,
          overridden_plugins: conflicting_plugins - [response],
          strategy: :interactive_select
        }
      else
        # Fallback for invalid responses
        {
          status: :error,
          message: "Invalid response: #{response}. Using priority fallback.",
          fallback: resolve_silent_override(conflict_type, conflicting_plugins)
        }
      end
    end
  end

  # Handle plugin selection response
  def handle_select_plugin_response(_response, conflict_type, conflicting_plugins)
    puts "Select plugin for #{conflict_type}:"
    conflicting_plugins.each_with_index do |plugin, index|
      priority = @priority_system.get(plugin)
      puts "#{index + 1}. #{plugin} (priority: #{priority})"
    end

    print "Choose plugin (1-#{conflicting_plugins.length}): "
    selection = gets.chomp.to_i

    if selection.between?(1, conflicting_plugins.length)
      chosen_plugin = conflicting_plugins[selection - 1]
      {
        status: :resolved,
        chosen_plugin: chosen_plugin,
        overridden_plugins: conflicting_plugins - [chosen_plugin],
        strategy: :interactive_select
      }
    else
      resolve_silent_override(conflict_type, conflicting_plugins)
    end
  end

  # Handle cancellation response
  def handle_cancel_response
    {
      status: :cancelled,
      message: 'Conflict resolution cancelled by user'
    }
  end

  # Select plugin with highest priority
  def select_highest_priority_plugin(conflicting_plugins)
    conflicting_plugins.max_by { |plugin| @priority_system.get(plugin) }
  end

  # Check if plugin names are similar using Levenshtein distance
  def similar_plugin_names?(name_a, name_b)
    similarity = calculate_name_similarity(name_a, name_b)
    similarity > 0.7 # 70% similarity threshold
  end

  # Calculate name similarity using Levenshtein distance
  def calculate_name_similarity(name_a, name_b)
    return 1.0 if name_a == name_b
    return 0.0 if name_a.empty? || name_b.empty?

    max_length = [name_a.length, name_b.length].max
    distance = levenshtein_distance(name_a, name_b)

    (max_length - distance).to_f / max_length
  end

  # Calculate Levenshtein distance between two strings
  def levenshtein_distance(str_a, str_b)
    return str_b.length if str_a.empty?
    return str_a.length if str_b.empty?

    matrix = create_distance_matrix(str_a, str_b)
    initialize_matrix_borders(matrix, str_a, str_b)
    calculate_distance_values(matrix, str_a, str_b)

    matrix[str_a.length][str_b.length]
  end

  # Create distance calculation matrix
  def create_distance_matrix(str_a, str_b)
    Array.new(str_a.length + 1) { Array.new(str_b.length + 1, 0) }
  end

  # Initialize matrix borders with base distances
  def initialize_matrix_borders(matrix, str_a, str_b)
    (0..str_a.length).each { |i| matrix[i][0] = i }
    (0..str_b.length).each { |j| matrix[0][j] = j }
  end

  # Calculate all distance values in the matrix
  def calculate_distance_values(matrix, str_a, str_b)
    (1..str_a.length).each do |i|
      (1..str_b.length).each do |j|
        cost = str_a[i - 1] == str_b[j - 1] ? 0 : 1
        matrix[i][j] = [
          matrix[i - 1][j] + 1,           # deletion
          matrix[i][j - 1] + 1,           # insertion
          matrix[i - 1][j - 1] + cost     # substitution
        ].min
      end
    end
  end

  # Generate cache key for conflict resolution
  def generate_cache_key(conflict_type, conflicting_plugins)
    "#{conflict_type}_#{conflicting_plugins.sort.join('_')}"
  end
end

# frozen_string_literal: true

# Error handling module for NumberAnalyzer CLI
# Provides contextual error messages and command suggestions
module Numana::CLI::ErrorHandler
  extend self

  # Custom error class with contextual information
  class CLIError < StandardError
    attr_reader :command, :context, :suggestion, :error_code

    def initialize(message, command: nil, context: nil, suggestion: nil, code: nil)
      super(message)
      @command = command
      @context = context
      @suggestion = suggestion
      @error_code = code
    end

    def user_message
      msg = ["Error: #{message}"]
      msg << "Command: #{command}" if command
      msg << "Context: #{context}" if context
      msg << "Suggestion: #{suggestion}" if suggestion
      msg.join("\n")
    end
  end

  # Handle unknown command with suggestions
  def handle_unknown_command(command, available_commands)
    similar = find_similar_commands(command, available_commands)

    if similar.any?
      suggestion = "Did you mean: #{similar.join(', ')}?"
      raise CLIError.new(
        "Unknown command: #{command}",
        command: command,
        suggestion: suggestion,
        code: :unknown_command
      )
    else
      raise CLIError.new(
        "Unknown command: #{command}",
        command: command,
        context: "Use 'bundle exec number_analyzer help' for available commands.",
        code: :unknown_command
      )
    end
  end

  # Handle invalid option errors
  def handle_invalid_option(option, command = nil)
    suggestion = suggest_option(option)
    raise CLIError.new(
      "Invalid option: #{option}",
      command: command,
      suggestion: suggestion,
      code: :invalid_option
    )
  end

  # Handle argument errors
  def handle_argument_error(error_message, command = nil)
    raise CLIError.new(
      "Argument error: #{error_message}",
      command: command,
      context: 'Please provide numeric values',
      code: :invalid_argument
    )
  end

  # Find similar commands using Levenshtein distance
  def find_similar_commands(input, commands)
    commands.select { |cmd| levenshtein_distance(input, cmd.to_s) <= 2 }
            .sort_by { |cmd| levenshtein_distance(input, cmd.to_s) }
            .first(3)
  end

  # Print error message and exit
  def print_error_and_exit(error)
    if error.is_a?(CLIError)
      warn error.user_message
      exit(error.error_code == :unknown_command ? 1 : 2)
    else
      warn "Error: #{error.message}"
      exit(1)
    end
  end

  private

  # Suggest similar options
  def suggest_option(invalid_option)
    common_options = %w[--help --format --precision --quiet --file]
    similar = find_similar_commands(invalid_option, common_options)
    return nil if similar.empty?

    "Did you mean: #{similar.join(', ')}?"
  end

  # Calculate Levenshtein distance between two strings
  def levenshtein_distance(str1, str2)
    return str2.length if str1.empty?
    return str1.length if str2.empty?

    matrix = initialize_distance_matrix(str1, str2)
    fill_distance_matrix(matrix, str1, str2)
    matrix[str1.length][str2.length]
  end

  # Initialize matrix for Levenshtein distance calculation
  def initialize_distance_matrix(str1, str2)
    matrix = Array.new(str1.length + 1) { Array.new(str2.length + 1) }
    (0..str1.length).each { |i| matrix[i][0] = i }
    (0..str2.length).each { |j| matrix[0][j] = j }
    matrix
  end

  # Fill the distance matrix with calculated values
  def fill_distance_matrix(matrix, str1, str2)
    (1..str1.length).each do |i|
      (1..str2.length).each do |j|
        cost = str1[i - 1] == str2[j - 1] ? 0 : 1
        matrix[i][j] = calculate_min_distance(matrix, i, j, cost)
      end
    end
  end

  # Calculate minimum distance for a cell
  def calculate_min_distance(matrix, row, col, cost)
    [
      matrix[row - 1][col] + 1,         # deletion
      matrix[row][col - 1] + 1,         # insertion
      matrix[row - 1][col - 1] + cost   # substitution
    ].min
  end
end

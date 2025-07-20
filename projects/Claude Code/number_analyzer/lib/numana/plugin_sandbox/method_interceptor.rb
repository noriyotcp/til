# frozen_string_literal: true

require 'set'

# Method interceptor for plugin sandboxing
# Blocks dangerous methods and allows only whitelisted operations
class Numana::PluginSandbox::MethodInterceptor
  ALLOWED_METHODS = {
    # Basic mathematical operations (always safe)
    mathematics: %i[
      + - * / % ** abs ceil floor round
      sqrt cbrt log log10 log2 exp
      sin cos tan asin acos atan atan2
      sinh cosh tanh asinh acosh atanh
      finite? infinite? nan? zero?
    ],

    # Array operations (read-only, safe transformations)
    array_operations: %i[
      each each_with_index each_with_object
      map map! select reject filter filter!
      reduce inject sum count size length
      min max sort sort_by reverse reverse!
      first last empty? include? index rindex
      zip flatten flatten! compact compact!
      uniq uniq! group_by partition
      slice slice! drop drop_while take take_while
      rotate rotate! shuffle shuffle!
    ],

    # String operations (safe manipulations)
    string_operations: %i[
      length size bytesize empty?
      upcase upcase! downcase downcase!
      strip strip! lstrip lstrip! rstrip rstrip!
      chomp chomp! squeeze squeeze!
      split join concat prepend
      gsub gsub! sub sub! tr tr! tr_s tr_s!
      include? start_with? end_with?
      match match? scan slice slice!
      insert delete delete! clear
    ],

    # Hash operations (safe key-value manipulations)
    hash_operations: %i[
      keys values each each_key each_value each_pair
      key? has_key? value? has_value? include?
      fetch dig select reject compact
      merge merge! transform_keys transform_values
      invert flatten to_a
    ],

    # Statistical and numerical methods
    statistics: %i[
      mean median mode variance standard_deviation
      correlation percentile quartiles outliers
      min_by max_by sort_by group_by
    ],

    # Object inspection (safe introspection)
    inspection: %i[
      class is_a? kind_of? instance_of?
      respond_to? methods public_methods
      to_s to_i to_f to_a to_h inspect
      nil? eql? equal? hash
    ],

    # Enumerable methods (safe iteration)
    enumerable: %i[
      all? any? none? one?
      find find_all find_index
      first_n last_n
      cycle lazy
    ]
  }.freeze

  FORBIDDEN_METHODS = %i[
    # Dynamic code execution - extremely dangerous
    eval instance_eval class_eval module_eval

    # System command execution - can execute arbitrary OS commands
    exec system backticks spawn fork

    # Process and thread control - can affect system stability
    exit exit! abort at_exit
    Thread Fiber Mutex ConditionVariable
    Process Kernel

    # Metaprogramming - can modify class definitions and method behavior
    send __send__ public_send private_send
    define_method remove_method undef_method alias_method
    define_singleton_method remove_singleton_method
    method_missing respond_to_missing?
    const_set const_missing remove_const
    include extend prepend

    # Dynamic loading - can load arbitrary code
    load require require_relative autoload

    # File system access - can access sensitive files
    File Dir IO Pathname FileUtils Tempfile
    open File.open Dir.open IO.open

    # Network access - can communicate with external systems
    Net TCPSocket UDPSocket Socket URI HTTP

    # Dangerous built-in methods
    binding caller caller_locations
    raise throw catch
    warn puts print printf p pp
    gets readline readlines

    # ObjectSpace manipulation
    ObjectSpace GC

    # Dangerous constants and globals
    ARGV ENV $LOAD_PATH $LOADED_FEATURES
    STDIN STDOUT STDERR

    # Time manipulation that could affect system
    sleep
  ].freeze

  WHITELIST_LEVELS = {
    permissive: ALLOWED_METHODS.values.flatten + %i[puts print warn],
    standard: ALLOWED_METHODS.values.flatten,
    strict: ALLOWED_METHODS.values_at(:mathematics, :array_operations, :statistics).flatten
  }.freeze

  def initialize(whitelist_level = :strict)
    @allowed_methods = Set.new(WHITELIST_LEVELS[whitelist_level] || WHITELIST_LEVELS[:strict])
    @violation_count = 0
  end

  # Intercept method calls and enforce security policy
  def intercept_method(method_name, ...)
    if @allowed_methods.include?(method_name)
      # Method is whitelisted - execute normally
      execute_allowed_method(method_name, ...)
    elsif FORBIDDEN_METHODS.include?(method_name)
      # Method is explicitly forbidden - raise security error
      security_violation(method_name, :forbidden)
    else
      # Method not in whitelist - raise security error with suggestion
      security_violation(method_name, :not_whitelisted)
    end
  end

  # Check if a method is allowed
  def method_allowed?(method_name)
    @allowed_methods.include?(method_name)
  end

  # Get violation statistics
  attr_reader :violation_count

  private

  def execute_allowed_method(method_name, *args, &block)
    # For mathematical operations, delegate to Math module or Kernel
    if ALLOWED_METHODS[:mathematics].include?(method_name)
      if Math.respond_to?(method_name)
        Math.send(method_name, *args, &block)
      else
        Kernel.send(method_name, *args, &block)
      end
    elsif args.first.respond_to?(method_name)
      # For other methods, delegate to the first argument if it responds
      args.first.send(method_name, *args[1..], &block)
    else
      # Try global method
      Kernel.send(method_name, *args, &block)
    end
  rescue NoMethodError
    # If method doesn't exist on the object, provide helpful error
    raise NoMethodError, "Method '#{method_name}' is not available in sandbox context"
  end

  def security_violation(method_name, violation_type)
    @violation_count += 1

    error_message = case violation_type
                    when :forbidden
                      case method_name
                      when :eval, :instance_eval, :class_eval, :module_eval
                        "Dynamic code evaluation (#{method_name}) is prohibited for security. Use explicit method calls instead."
                      when :system, :exec, :backticks, :spawn
                        "System command execution (#{method_name}) is not allowed. Use plugin APIs for external operations."
                      when :require, :load, :require_relative
                        "Dynamic code loading (#{method_name}) is restricted. Use plugin configuration for dependencies."
                      when :File, :Dir, :IO, :open
                        "Direct file system access (#{method_name}) is prohibited. Use plugin APIs for data access."
                      when :send, :__send__, :public_send
                        "Dynamic method invocation (#{method_name}) is not permitted for security."
                      when :Thread, :Process, :fork
                        "Process/thread manipulation (#{method_name}) is restricted. Use plugin APIs for concurrent operations."
                      when :puts, :print, :warn
                        "Direct output (#{method_name}) is restricted. Use plugin APIs for output generation."
                      else
                        "Method '#{method_name}' is explicitly forbidden in plugin sandbox for security reasons."
                      end
                    when :not_whitelisted
                      "Method '#{method_name}' is not whitelisted for plugin execution. Available methods: #{allowed_method_categories}"
                    else
                      "Method '#{method_name}' is not allowed in plugin sandbox."
                    end

    raise SecurityError, error_message
  end

  def allowed_method_categories
    categories = []
    categories << 'mathematics' if (@allowed_methods & ALLOWED_METHODS[:mathematics]).any?
    categories << 'arrays' if (@allowed_methods & ALLOWED_METHODS[:array_operations]).any?
    categories << 'strings' if (@allowed_methods & ALLOWED_METHODS[:string_operations]).any?
    categories << 'statistics' if (@allowed_methods & ALLOWED_METHODS[:statistics]).any?
    categories.join(', ')
  end
end

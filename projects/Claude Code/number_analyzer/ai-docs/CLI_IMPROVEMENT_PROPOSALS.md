# CLI.rb Improvement Proposals

## Executive Summary

This document outlines comprehensive improvement proposals for `lib/number_analyzer/cli.rb`, aiming to reduce the file from its current 385 lines to under 100 lines while enhancing functionality, maintainability, and developer experience.

## Current State Analysis

### Metrics
- **Current Size**: 385 lines (81% reduction from original 2094 lines)
- **Target Size**: < 100 lines (95%+ total reduction)
- **Role**: Lightweight command dispatcher
- **Dependencies**: 10 require statements
- **Main Responsibilities**: Command routing, plugin initialization, option parsing

### Architecture
The current CLI.rb serves as a dispatcher that:
1. Initializes the plugin system
2. Routes commands to CommandRegistry
3. Handles special argument parsing for complex commands
4. Manages plugin command registration

## Improvement Proposals

### 1. Further Code Reduction (Target: 100 lines)

#### a) Option Parsing Externalization
```ruby
# Current: 200+ lines of option parsing code in CLI.rb
# Proposed: Move to dedicated module

module NumberAnalyzer::CLIOptions
  extend self
  
  def parse(args)
    options = default_options
    parser = create_parser(options)
    remaining = parser.parse(args)
    [options, remaining]
  rescue OptionParser::InvalidOption => e
    handle_parse_error(e)
  end
  
  private
  
  def default_options
    # Move all default options here
  end
  
  def create_parser(options)
    # Move OptionParser creation here
  end
end
```

**Impact**: Removes ~80 lines from CLI.rb

#### b) Help System Separation
```ruby
# Current: Multiple show_help methods in CLI.rb
# Proposed: Dynamic help generation

module NumberAnalyzer::HelpGenerator
  extend self
  
  def for_command(command)
    template = load_template(command)
    ERB.new(template).result(binding)
  end
  
  def all_commands_help
    # Generate comprehensive help
  end
end
```

**Impact**: Removes ~40 lines from CLI.rb

#### c) Data Input Processing Consolidation
```ruby
# Current: Multiple parsing methods scattered
# Proposed: Unified input processor

module NumberAnalyzer::InputProcessor
  extend self
  
  def process(args, options)
    return read_file(options[:file]) if options[:file]
    return default_dataset if args.empty?
    parse_numeric(args)
  end
  
  private
  
  def parse_numeric(args)
    args.map { |arg| Float(arg) }
  rescue ArgumentError => e
    raise InputError, "Invalid numeric input: #{e.message}"
  end
end
```

**Impact**: Removes ~60 lines from CLI.rb

### 2. Plugin Command Priority Management

#### a) Command Conflict Resolution
```ruby
class NumberAnalyzer::CLI
  # Priority levels for command resolution
  COMMAND_PRIORITY = {
    core: 100,
    official: 80,
    community: 60,
    local: 40
  }.freeze
  
  class << self
    def resolve_command(name)
      candidates = find_all_commands(name)
      return candidates.first if candidates.size == 1
      
      candidates.max_by { |cmd| command_priority(cmd) }
    end
    
    private
    
    def command_priority(command)
      source = command_source(command)
      COMMAND_PRIORITY[source] || 0
    end
    
    def command_source(command)
      case command.class.name
      when /^NumberAnalyzer::Commands::/
        :core
      when /^NumberAnalyzer::Plugins::Official::/
        :official
      when /^NumberAnalyzer::Plugins::Community::/
        :community
      else
        :local
      end
    end
  end
end
```

#### b) Namespace Prefixing
```ruby
module NumberAnalyzer::CLI::PluginNamespacing
  extend self
  
  def register_with_namespace(plugin)
    prefix = namespace_prefix(plugin)
    plugin.commands.each do |name, handler|
      prefixed_name = "#{prefix}_#{name}"
      
      # Register both prefixed and original names
      registry.register(prefixed_name, handler)
      registry.register_alias(name, prefixed_name)
    end
  end
  
  private
  
  def namespace_prefix(plugin)
    case plugin.type
    when :machine_learning then 'ml'
    when :visualization then 'viz'
    when :export then 'exp'
    else plugin.name.downcase[0..2]
    end
  end
end
```

### 3. Advanced Error Handling

#### a) Contextual Error System
```ruby
module NumberAnalyzer::CLI::ErrorHandler
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
      msg = ["エラー: #{message}"]
      msg << "コマンド: #{command}" if command
      msg << "コンテキスト: #{context}" if context
      msg << "提案: #{suggestion}" if suggestion
      msg.join("\n")
    end
  end
  
  extend self
  
  def handle(error, command = nil)
    case error
    when OptionParser::InvalidOption
      suggestion = suggest_option(error.args.first)
      raise CLIError.new(
        "無効なオプション: #{error.args.first}",
        command: command,
        suggestion: suggestion,
        code: :invalid_option
      )
    when ArgumentError
      raise CLIError.new(
        "引数エラー: #{error.message}",
        command: command,
        context: "数値を入力してください",
        code: :invalid_argument
      )
    else
      raise error
    end
  end
  
  private
  
  def suggest_option(invalid_option)
    # Levenshtein distance to find similar options
    similar = find_similar_options(invalid_option)
    return nil if similar.empty?
    
    "もしかして: #{similar.join(', ')}"
  end
end
```

#### b) Interactive Error Recovery
```ruby
module NumberAnalyzer::CLI::InteractiveRecovery
  extend self
  
  def handle_unknown_command(command, args)
    similar = find_similar_commands(command)
    
    if similar.empty?
      puts "不明なコマンド: #{command}"
      show_command_list
      return
    end
    
    if interactive_mode?
      selected = prompt_command_selection(similar)
      NumberAnalyzer::CLI.run([selected] + args) if selected
    else
      suggest_commands(similar)
    end
  end
  
  private
  
  def prompt_command_selection(commands)
    puts "不明なコマンド。以下から選択してください："
    commands.each_with_index do |cmd, i|
      puts "  #{i + 1}. #{cmd}"
    end
    print "選択 (1-#{commands.size}): "
    
    choice = gets.chomp.to_i
    return nil unless (1..commands.size).include?(choice)
    
    commands[choice - 1]
  end
  
  def interactive_mode?
    $stdin.tty? && !ENV['NUMBER_ANALYZER_NON_INTERACTIVE']
  end
end
```

### 4. Performance Optimization

#### a) Lazy Loading Strategy
```ruby
class NumberAnalyzer::CLI
  class << self
    def plugin_system
      @plugin_system ||= begin
        return nil unless plugins_needed?
        
        require_relative 'plugin_system'
        system = NumberAnalyzer::PluginSystem.new
        system.load_enabled_plugins
        system
      end
    end
    
    private
    
    def plugins_needed?
      # Only load plugins if actually using plugin commands
      !ARGV.empty? && plugin_command?(ARGV.first)
    end
    
    def plugin_command?(command)
      # Quick check without loading plugin system
      File.exist?("plugins/#{command}_plugin.rb") ||
        configuration['plugins']['enabled'].include?(command)
    end
  end
end
```

#### b) Command Caching
```ruby
module NumberAnalyzer::CLI::CommandCache
  extend self
  
  CACHE_TTL = 60 # seconds
  
  def get_commands
    if cache_valid?
      @commands_cache
    else
      @commands_cache = build_command_list
      @cache_time = Time.now
      @commands_cache
    end
  end
  
  def invalidate!
    @commands_cache = nil
    @cache_time = nil
  end
  
  private
  
  def cache_valid?
    return false unless @cache_time
    Time.now - @cache_time < CACHE_TTL
  end
  
  def build_command_list
    commands = {}
    
    # Core commands from registry
    commands.merge!(NumberAnalyzer::Commands::CommandRegistry.all)
    
    # Plugin commands (lazy loaded)
    if NumberAnalyzer::CLI.plugin_system
      commands.merge!(plugin_commands)
    end
    
    commands
  end
end
```

### 5. Developer Experience Enhancement

#### a) Debug Mode
```ruby
module NumberAnalyzer::CLI::Debug
  extend self
  
  def enabled?
    ENV['NUMBER_ANALYZER_DEBUG'] == 'true'
  end
  
  def log(message, level = :info)
    return unless enabled?
    
    timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
    prefix = "[#{timestamp}] [#{level.upcase}]"
    
    case level
    when :error
      $stderr.puts "#{prefix} #{message}"
    else
      $stdout.puts "#{prefix} #{message}"
    end
  end
  
  def trace_command_execution(command, args, options)
    return yield unless enabled?
    
    log("Executing command: #{command}")
    log("Arguments: #{args.inspect}")
    log("Options: #{options.inspect}")
    
    start_time = Time.now
    result = yield
    duration = Time.now - start_time
    
    log("Execution completed in #{(duration * 1000).round(2)}ms")
    result
  end
end
```

#### b) Shell Completion Support
```ruby
module NumberAnalyzer::CLI::Completion
  extend self
  
  def generate_bash_completion
    <<~BASH
      _number_analyzer_completion() {
        local cur prev commands
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        
        # Command list
        commands="#{all_commands.join(' ')}"
        
        # Option completion
        case "${prev}" in
          --format)
            COMPREPLY=( $(compgen -W "json yaml csv" -- ${cur}) )
            return 0
            ;;
          --strategy)
            COMPREPLY=( $(compgen -W "interactive namespace priority disable" -- ${cur}) )
            return 0
            ;;
          *)
            COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
            ;;
        esac
      }
      
      complete -F _number_analyzer_completion number_analyzer
    BASH
  end
  
  def generate_zsh_completion
    # ZSH-specific completion
  end
  
  def install_completion
    shell = ENV['SHELL'] || '/bin/bash'
    
    case shell
    when /bash/
      install_bash_completion
    when /zsh/
      install_zsh_completion
    else
      puts "Unsupported shell: #{shell}"
    end
  end
end
```

### 6. Future Extensibility

#### a) Plugin Hooks
```ruby
module NumberAnalyzer::CLI::Hooks
  extend self
  
  HOOKS = %i[
    before_command
    after_command
    before_parse
    after_parse
    on_error
  ].freeze
  
  def register(hook, &block)
    raise ArgumentError, "Unknown hook: #{hook}" unless HOOKS.include?(hook)
    
    hooks[hook] ||= []
    hooks[hook] << block
  end
  
  def run(hook, *args)
    return unless hooks[hook]
    
    hooks[hook].each do |callback|
      callback.call(*args)
    rescue => e
      # Log but don't fail
      NumberAnalyzer::CLI::Debug.log("Hook error: #{e.message}", :error)
    end
  end
  
  private
  
  def hooks
    @hooks ||= {}
  end
end

# Usage in CLI
class NumberAnalyzer::CLI
  def self.run_subcommand(command, args)
    Hooks.run(:before_command, command, args)
    
    result = execute_command(command, args)
    
    Hooks.run(:after_command, command, args, result)
    result
  rescue => e
    Hooks.run(:on_error, e, command, args)
    raise
  end
end
```

#### b) Configuration File Support
```ruby
module NumberAnalyzer::CLI::Configuration
  extend self
  
  CONFIG_PATHS = [
    './.number_analyzer.yml',
    '~/.number_analyzer/config.yml',
    '/etc/number_analyzer/config.yml'
  ].freeze
  
  def load
    config_file = find_config_file
    return {} unless config_file
    
    config = YAML.load_file(config_file)
    merge_with_env(config)
  rescue => e
    NumberAnalyzer::CLI::Debug.log("Config load error: #{e.message}", :error)
    {}
  end
  
  def cli_defaults
    config = load
    config['cli_defaults'] || {}
  end
  
  private
  
  def find_config_file
    CONFIG_PATHS.find { |path| File.exist?(File.expand_path(path)) }
  end
  
  def merge_with_env(config)
    # Environment variables override config file
    ENV.each do |key, value|
      next unless key.start_with?('NUMBER_ANALYZER_')
      
      config_key = key.sub('NUMBER_ANALYZER_', '').downcase
      config[config_key] = value
    end
    
    config
  end
end
```

## Implementation Roadmap

### Phase 1: Modularization (2 weeks)
1. Extract option parsing to CLIOptions module
2. Extract help system to HelpGenerator
3. Extract input processing to InputProcessor
4. Update tests for new modules

### Phase 2: Enhanced Features (2 weeks)
1. Implement plugin priority system
2. Add advanced error handling
3. Implement command caching
4. Add debug mode support

### Phase 3: Developer Experience (1 week)
1. Add shell completion support
2. Implement plugin hooks
3. Add configuration file support
4. Create migration guide

## Expected Outcomes

### Metrics
- **Code Reduction**: 385 → <100 lines (>74% additional reduction)
- **Total Reduction**: 2094 → <100 lines (>95% total reduction)
- **Modularization**: 10+ specialized modules
- **Test Coverage**: Maintained at 100%

### Benefits
1. **Maintainability**: Each module has single responsibility
2. **Extensibility**: Easy to add new features via modules
3. **Performance**: Lazy loading and caching
4. **Developer Experience**: Debug mode, completions, hooks
5. **User Experience**: Better error messages, interactive recovery

### Risks and Mitigations
1. **Risk**: Breaking existing functionality
   - **Mitigation**: Comprehensive test suite, gradual migration
2. **Risk**: Performance regression
   - **Mitigation**: Benchmarking, lazy loading
3. **Risk**: Plugin compatibility
   - **Mitigation**: Compatibility layer, version checks

## Conclusion

These improvements will transform CLI.rb from a 385-line dispatcher into a sub-100-line orchestrator, with functionality distributed across specialized, testable modules. This architecture will be more maintainable, performant, and developer-friendly while maintaining full backward compatibility.
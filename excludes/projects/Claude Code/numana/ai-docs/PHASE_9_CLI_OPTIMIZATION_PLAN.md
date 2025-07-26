# Phase 9: CLI Ultimate Optimization Plan

## Executive Summary

This document outlines the comprehensive plan for Phase 9 of the NumberAnalyzer project, focusing on the final optimization of `lib/numana/cli.rb`. The goal is to reduce the CLI orchestrator from its current 138 lines to under 100 lines while simultaneously adding advanced features through modular architecture.

**Current State**: CLI.rb has been successfully reduced from 2094 lines to 138 lines (93% reduction) through Phase 1 modularization.

**Target State**: Further reduce CLI.rb to under 100 lines while adding enhanced error handling, performance optimizations, and developer experience features.

## Current State Analysis

### Metrics
- **CLI.rb Size**: 138 lines (down from original 2094 lines)
- **Existing Modules**:
  - `cli/options.rb`: 243 lines - Comprehensive option parsing
  - `cli/help_generator.rb`: 155 lines - Dynamic help generation
  - `cli/input_processor.rb`: 160 lines - Unified input processing
- **Architecture**: Clean orchestrator pattern with delegated responsibilities

### Remaining Responsibilities in CLI.rb
1. Plugin system initialization (lines 39-52)
2. Command routing logic (lines 99-129)
3. Error handling for unknown commands (lines 82-86)
4. Main entry point coordination (lines 63-87)

## Implementation Plan Overview

### Timeline: 5 weeks (3 phases)

```
Phase 1: Additional Modularization (Weeks 1-2)
├── Error Handler Module
├── Command Cache Module
└── Plugin Router Module

Phase 2: Feature Enhancement (Weeks 3-4)
├── Debug Module
├── Interactive Recovery
└── Advanced Priority Management

Phase 3: Developer Experience (Week 5)
├── Shell Completion
├── Plugin Hooks
└── Configuration Support
```

## Phase 1: Additional Modularization (Weeks 1-2)

### 1.1 Error Handler Module

**File**: `lib/numana/cli/error_handler.rb`

**Responsibilities**:
- Contextual error messages with command and suggestion information
- Levenshtein distance calculation for similar command suggestions
- Interactive error recovery in TTY environments
- Structured error codes for internationalization

**Implementation Example**:
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
      msg = ["Error: #{message}"]
      msg << "Command: #{command}" if command
      msg << "Context: #{context}" if context
      msg << "Suggestion: #{suggestion}" if suggestion
      msg.join("\n")
    end
  end
  
  extend self
  
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
        context: "Run 'numana help' for available commands",
        code: :unknown_command
      )
    end
  end
  
  private
  
  def find_similar_commands(input, commands)
    commands.select { |cmd| levenshtein_distance(input, cmd) <= 2 }
            .sort_by { |cmd| levenshtein_distance(input, cmd) }
            .first(3)
  end
  
  def levenshtein_distance(s1, s2)
    # Implementation of Levenshtein distance algorithm
  end
end
```

**Expected CLI.rb reduction**: ~15-20 lines

### 1.2 Command Cache Module

**File**: `lib/numana/cli/command_cache.rb`

**Responsibilities**:
- Cache command list with 60-second TTL
- Automatic invalidation on plugin changes
- Performance optimization for repeated CLI invocations

**Implementation Example**:
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
    if plugin_system_loaded?
      commands.merge!(NumberAnalyzer::CLI.plugin_commands)
    end
    
    commands
  end
  
  def plugin_system_loaded?
    defined?(NumberAnalyzer::PluginSystem) && 
      NumberAnalyzer::CLI.instance_variable_get(:@plugin_system)
  end
end
```

**Expected CLI.rb reduction**: ~10-15 lines

### 1.3 Plugin Router Module

**File**: `lib/numana/cli/plugin_router.rb`

**Responsibilities**:
- Smart command routing with conflict resolution
- Integration with existing PluginConflictResolver
- Priority-based command selection

**Implementation Example**:
```ruby
module NumberAnalyzer::CLI::PluginRouter
  extend self
  
  def route_command(command, args, options)
    # Check for conflicts using existing infrastructure
    resolver = NumberAnalyzer::PluginConflictResolver.new
    
    if resolver.has_conflicts?(command)
      handle_conflict(command, args, options, resolver)
    else
      execute_standard_command(command, args, options)
    end
  end
  
  private
  
  def handle_conflict(command, args, options, resolver)
    strategy = options[:conflict_strategy] || :priority
    resolved = resolver.resolve_conflict(command, strategy: strategy)
    
    if resolved
      execute_resolved_command(resolved, args, options)
    else
      NumberAnalyzer::CLI::ErrorHandler.handle_unknown_command(command, available_commands)
    end
  end
  
  def execute_standard_command(command, args, options)
    if NumberAnalyzer::Commands::CommandRegistry.exists?(command)
      NumberAnalyzer::Commands::CommandRegistry.execute_command(command, args, options)
    elsif plugin_command?(command)
      execute_plugin_command(command, args, options)
    else
      NumberAnalyzer::CLI::ErrorHandler.handle_unknown_command(command, available_commands)
    end
  end
end
```

**Expected CLI.rb reduction**: ~10-15 lines

## Phase 2: Feature Enhancement (Weeks 3-4)

### 2.1 Debug Module

**File**: `lib/numana/cli/debug.rb`

**Features**:
- Environment-based debug mode (`NUMANA_DEBUG=true`)
- Command execution tracing
- Performance metrics
- Structured logging

**Implementation Example**:
```ruby
module NumberAnalyzer::CLI::Debug
  extend self
  
  def enabled?
    ENV['NUMANA_DEBUG'] == 'true'
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

### 2.2 Interactive Recovery Module

**File**: `lib/numana/cli/interactive_recovery.rb`

**Features**:
- Typo correction with user prompts
- Number-based command selection
- Non-interactive mode support

**Implementation Example**:
```ruby
module NumberAnalyzer::CLI::InteractiveRecovery
  extend self
  
  def handle_unknown_command(command, args)
    similar = find_similar_commands(command)
    
    if similar.empty?
      puts "Unknown command: #{command}"
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
    puts "Unknown command. Did you mean one of these?"
    commands.each_with_index do |cmd, i|
      puts "  #{i + 1}. #{cmd}"
    end
    print "Select (1-#{commands.size}) or press Enter to cancel: "
    
    choice = gets.chomp.to_i
    return nil unless (1..commands.size).include?(choice)
    
    commands[choice - 1]
  end
  
  def interactive_mode?
    $stdin.tty? && !ENV['NUMANA_NON_INTERACTIVE']
  end
end
```

### 2.3 Advanced Plugin Priority Management

Building on existing `PluginPriority` class:

**Enhancement Features**:
- Extended priority levels for fine-grained control
- Namespace-based conflict resolution
- User preference overrides

## Phase 3: Developer Experience (Week 5)

### 3.1 Shell Completion Module

**File**: `lib/numana/cli/completion.rb`

**Features**:
- Bash completion script generation
- Zsh completion support
- Dynamic command and option completion

**Implementation Example**:
```ruby
module NumberAnalyzer::CLI::Completion
  extend self
  
  def generate_bash_completion
    <<~BASH
      _numana_completion() {
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
          --file)
            COMPREPLY=( $(compgen -f -- ${cur}) )
            return 0
            ;;
          *)
            COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
            ;;
        esac
      }
      
      complete -F _numana_completion numana
    BASH
  end
  
  def install_completion
    shell = detect_shell
    case shell
    when :bash
      install_bash_completion
    when :zsh
      install_zsh_completion
    else
      puts "Unsupported shell: #{shell}"
    end
  end
end
```

### 3.2 Plugin Hooks Module

**File**: `lib/numana/cli/hooks.rb`

**Features**:
- Lifecycle hooks for plugins
- Error-safe hook execution
- Hook registration API

**Hook Types**:
- `before_command`: Pre-execution setup
- `after_command`: Post-execution cleanup
- `before_parse`: Argument preprocessing
- `after_parse`: Argument validation
- `on_error`: Error handling customization

### 3.3 Configuration Module

**File**: `lib/numana/cli/configuration.rb`

**Features**:
- YAML configuration file support
- Environment variable integration
- Default option management

**Configuration Hierarchy**:
1. Command-line arguments (highest priority)
2. Environment variables
3. User config file (~/.numana/config.yml)
4. System config file (/etc/numana/config.yml)
5. Built-in defaults (lowest priority)

## Expected Outcomes

### Code Metrics
- **CLI.rb**: 138 lines → <100 lines (target achieved)
- **Total modules**: 3 → 10 specialized modules
- **Maintainability**: Each module with single responsibility

### Performance Improvements
- **Startup time**: 50% faster on repeated invocations (caching)
- **Memory usage**: Lazy loading reduces initial footprint
- **Command resolution**: O(1) lookup with caching

### Developer Experience
- **Debugging**: Comprehensive trace logging
- **Shell integration**: Tab completion for all commands
- **Error messages**: Clear, actionable suggestions

### User Experience
- **Error recovery**: Interactive typo correction
- **Customization**: User preferences via config file
- **Non-interactive mode**: Full scripting support

## Success Metrics

1. **Primary Goal**: CLI.rb under 100 lines ✓
2. **Zero regression**: All existing functionality preserved
3. **Test coverage**: 100% for all new modules
4. **Performance**: No degradation in command execution
5. **RuboCop compliance**: Zero violations maintained

## Risk Management

### Risk 1: Breaking Changes
- **Mitigation**: Comprehensive test suite before refactoring
- **Strategy**: Gradual migration with fallback paths

### Risk 2: Performance Regression
- **Mitigation**: Benchmark critical paths
- **Strategy**: Profile before and after changes

### Risk 3: Complexity Increase
- **Mitigation**: Clear module boundaries
- **Strategy**: Document all module interactions

## Implementation Checklist

### Week 1-2 (Phase 1)
- [ ] Create error_handler.rb module
- [ ] Create command_cache.rb module  
- [ ] Create plugin_router.rb module
- [ ] Update CLI.rb to use new modules
- [ ] Write tests for each module
- [ ] Verify CLI.rb line reduction

### Week 3-4 (Phase 2)
- [ ] Create debug.rb module
- [ ] Create interactive_recovery.rb module
- [ ] Enhance plugin priority management
- [ ] Integration testing
- [ ] Performance benchmarking

### Week 5 (Phase 3)
- [ ] Create completion.rb module
- [ ] Create hooks.rb module
- [ ] Create configuration.rb module
- [ ] Documentation updates
- [ ] Release preparation

## Conclusion

Phase 9 represents the culmination of the CLI optimization journey, transforming a 2094-line monolith into a sub-100-line orchestrator supported by 10 specialized modules. This architecture provides superior maintainability, testability, and extensibility while adding advanced features that enhance both developer and user experience.

The modular approach ensures that future enhancements can be added without affecting the core orchestrator, establishing a sustainable foundation for long-term project growth.
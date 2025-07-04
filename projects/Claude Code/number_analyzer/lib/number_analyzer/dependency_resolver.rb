# frozen_string_literal: true

require 'tsort'

# Advanced dependency resolution system for NumberAnalyzer plugins
class NumberAnalyzer
  # Handles complex dependency resolution with circular dependency detection
  class DependencyResolver
    include TSort

    # Custom error classes
    class CircularDependencyError < StandardError
      attr_reader :cycle

      def initialize(cycle)
        @cycle = cycle
        super("Circular dependency detected: #{cycle.join(' -> ')}")
      end
    end

    # Raised when a plugin has dependencies that cannot be found
    class UnresolvedDependencyError < StandardError
      attr_reader :plugin, :missing_dependencies

      def initialize(plugin, missing_deps)
        @plugin = plugin
        @missing_dependencies = missing_deps
        super("Plugin '#{plugin}' has unresolved dependencies: #{missing_deps.join(', ')}")
      end
    end

    # Raised when there are version conflicts between plugin dependencies
    class VersionConflictError < StandardError
      attr_reader :plugin, :dependency, :required_version, :available_version

      def initialize(plugin, dependency, required, available)
        @plugin = plugin
        @dependency = dependency
        @required_version = required
        @available_version = available
        super("Version conflict: '#{plugin}' requires #{dependency} #{required}, but #{available} is available")
      end
    end

    def initialize(plugin_registry)
      @plugin_registry = plugin_registry
      @dependency_graph = {}
      @version_requirements = {}
      @resolution_cache = {}
    end

    # Resolve dependencies for a plugin, returning ordered load sequence
    def resolve(plugin_name, options = {})
      return @resolution_cache[plugin_name] if @resolution_cache.key?(plugin_name)

      validate_plugin_exists!(plugin_name)
      build_dependency_graph(plugin_name)
      detect_circular_dependencies

      resolution = resolve_dependencies(plugin_name)
      validate_versions(resolution) if options[:check_versions]

      @resolution_cache[plugin_name] = resolution
      resolution
    end

    # Resolve dependencies for multiple plugins
    def resolve_multiple(plugin_names)
      all_plugins = Set.new

      plugin_names.each do |plugin_name|
        resolution = resolve(plugin_name)
        all_plugins.merge(resolution)
      end

      # Return in topological order
      order_by_dependencies(all_plugins.to_a)
    end

    # Check if all dependencies for a plugin are satisfied
    def dependencies_satisfied?(plugin_name)
      plugin_info = @plugin_registry[plugin_name]
      return false unless plugin_info

      dependencies = plugin_info[:metadata][:dependencies] || []
      dependencies.all? { |dep| dependency_available?(dep) }
    end

    # Get missing dependencies for a plugin
    def missing_dependencies(plugin_name)
      plugin_info = @plugin_registry[plugin_name]
      return [] unless plugin_info

      dependencies = plugin_info[:metadata][:dependencies] || []
      dependencies.reject { |dep| dependency_available?(dep) }
    end

    # Validate version compatibility
    def version_compatible?(_plugin_name, dependency_name, required_version)
      available_version = get_plugin_version(dependency_name)
      return true unless required_version && available_version

      satisfy_version_requirement?(available_version, required_version)
    end

    private

    # TSort implementation
    def tsort_each_node(&block)
      @dependency_graph.each_key(&block)
    end

    def tsort_each_child(node, &block)
      @dependency_graph[node]&.each(&block)
    end

    def validate_plugin_exists!(plugin_name)
      return if @plugin_registry.key?(plugin_name)

      raise ArgumentError, "Plugin '#{plugin_name}' not found in registry"
    end

    def build_dependency_graph(plugin_name, visited = Set.new)
      return if visited.include?(plugin_name)

      visited.add(plugin_name)
      plugin_info = @plugin_registry[plugin_name]
      return unless plugin_info

      dependencies = extract_dependencies(plugin_info)
      @dependency_graph[plugin_name] = dependencies.keys

      # Store version requirements
      dependencies.each do |dep_name, version_req|
        @version_requirements[[plugin_name, dep_name]] = version_req
      end

      # Recursively build graph for dependencies
      dependencies.each_key { |dep| build_dependency_graph(dep, visited) }
    end

    def extract_dependencies(plugin_info)
      deps = plugin_info[:metadata][:dependencies] || []

      # Support both simple array and hash with versions
      case deps
      when Array
        deps.each_with_object({}) { |dep, h| h[dep] = nil }
      when Hash
        deps
      else
        {}
      end
    end

    def detect_circular_dependencies
      # Use topological sort to detect cycles
      tsort
    rescue TSort::Cyclic
      # Extract the cycle from the error
      cycle = extract_cycle_from_graph
      raise CircularDependencyError, cycle
    end

    def extract_cycle_from_graph
      # Find a cycle in the dependency graph
      visited = Set.new
      stack = []

      @dependency_graph.each_key do |node|
        if (cycle = find_cycle(node, visited, stack))
          return cycle
        end
      end

      []
    end

    def find_cycle(node, visited, stack)
      return nil if visited.include?(node)

      visited.add(node)
      stack.push(node)

      @dependency_graph[node]&.each do |child|
        if stack.include?(child)
          # Found a cycle
          cycle_start = stack.index(child)
          return stack[cycle_start..] + [child]
        end

        if (cycle = find_cycle(child, visited, stack))
          return cycle
        end
      end

      stack.pop
      nil
    end

    def resolve_dependencies(plugin_name)
      # Topological sort gives us the correct load order
      all_dependencies = Set.new([plugin_name])
      collect_all_dependencies(plugin_name, all_dependencies)

      # Sort in dependency order
      sorted = tsort_nodes(all_dependencies.to_a)

      # Validate all dependencies are available
      missing = sorted.reject { |dep| dependency_available?(dep) }
      raise UnresolvedDependencyError.new(plugin_name, missing) if missing.any?

      sorted
    end

    def collect_all_dependencies(plugin_name, collected)
      dependencies = @dependency_graph[plugin_name] || []

      dependencies.each do |dep|
        next if collected.include?(dep)

        collected.add(dep)
        collect_all_dependencies(dep, collected)
      end
    end

    def tsort_nodes(nodes)
      subgraph = @dependency_graph.slice(*nodes)

      # Create a temporary resolver for the subgraph
      temp_resolver = self.class.new(@plugin_registry)
      temp_resolver.instance_variable_set(:@dependency_graph, subgraph)

      begin
        temp_resolver.tsort
      rescue TSort::Cyclic
        # This shouldn't happen as we already detected cycles
        []
      end
    end

    def order_by_dependencies(plugin_names)
      # Create subgraph containing only specified plugins
      subgraph = {}
      plugin_names.each do |name|
        deps = @dependency_graph[name] || []
        subgraph[name] = deps.select { |d| plugin_names.include?(d) }
      end

      # Sort the subgraph
      temp_resolver = self.class.new(@plugin_registry)
      temp_resolver.instance_variable_set(:@dependency_graph, subgraph)

      begin
        temp_resolver.tsort
      rescue TSort::Cyclic
        plugin_names # Return original order if there's a cycle
      end
    end

    def dependency_available?(dep_name)
      @plugin_registry.key?(dep_name)
    end

    def validate_versions(plugin_list)
      plugin_list.each do |plugin_name|
        @version_requirements.each do |(requirer, dependency), required_version|
          next unless requirer == plugin_name && plugin_list.include?(dependency)
          next unless required_version

          available_version = get_plugin_version(dependency)
          unless satisfy_version_requirement?(available_version, required_version)
            raise VersionConflictError.new(requirer, dependency, required_version, available_version)
          end
        end
      end
    end

    def get_plugin_version(plugin_name)
      @plugin_registry.dig(plugin_name, :metadata, :version) || '0.0.0'
    end

    def satisfy_version_requirement?(version, requirement)
      return true if requirement.nil? || requirement == '*'

      match_version_pattern?(version, requirement)
    end

    def match_version_pattern?(version, requirement)
      if pessimistic_constraint?(requirement)
        handle_pessimistic_constraint?(version, requirement)
      elsif comparison_constraint?(requirement)
        handle_comparison_constraint?(version, requirement)
      elsif exact_match_constraint?(requirement)
        handle_exact_match?(version, requirement)
      else
        version == requirement
      end
    end

    def pessimistic_constraint?(requirement)
      requirement.match?(/^~>(.+)$/)
    end

    def comparison_constraint?(requirement)
      requirement.match?(/^(>=|>|<=|<)(.+)$/)
    end

    def exact_match_constraint?(requirement)
      requirement.match?(/^(=|==)(.+)$/)
    end

    def handle_pessimistic_constraint?(version, requirement)
      required_version = requirement.match(/^~>(.+)$/)[1].strip
      pessimistic_version_satisfied?(required_version, version)
    end

    def handle_comparison_constraint?(version, requirement)
      operator, required_version = parse_comparison_constraint(requirement)
      case operator
      when '>='
        version_greater_or_equal?(version, required_version)
      when '>'
        version_greater?(version, required_version)
      when '<='
        version_less_or_equal?(version, required_version)
      when '<'
        version_less?(version, required_version)
      end
    end

    def handle_exact_match?(version, requirement)
      required_version = requirement.match(/^(=|==)(.+)$/)[2].strip
      version == required_version
    end

    def parse_comparison_constraint(requirement)
      match = requirement.match(/^(>=|>|<=|<)(.+)$/)
      [match[1], match[2].strip]
    end

    def version_greater_or_equal?(version, required)
      compare_versions(version, required) >= 0
    end

    def version_greater?(version, required)
      compare_versions(version, required).positive?
    end

    def version_less_or_equal?(version, required)
      compare_versions(version, required) <= 0
    end

    def version_less?(version, required)
      compare_versions(version, required).negative?
    end

    def pessimistic_version_satisfied?(required, actual)
      required_parts = required.split('.')
      actual_parts = actual.split('.')

      # For ~> to work, actual version must have at least as many parts as required
      return false if actual_parts.size < required_parts.size

      # Check all parts except the last one must match exactly
      (0...(required_parts.size - 1)).each do |i|
        return false if required_parts[i] != actual_parts[i]
      end

      # For the position of the last required part, actual must be >= required
      actual_parts[required_parts.size - 1].to_i >= required_parts.last.to_i
    end

    def compare_versions(version1, version2)
      parts1, parts2 = normalize_version_parts(version1, version2)

      compare_version_parts(parts1, parts2)
    end

    def normalize_version_parts(version1, version2)
      parts1 = version1.split('.').map(&:to_i)
      parts2 = version2.split('.').map(&:to_i)

      # Pad with zeros to make equal length
      max_length = [parts1.size, parts2.size].max
      parts1 += [0] * (max_length - parts1.size)
      parts2 += [0] * (max_length - parts2.size)

      [parts1, parts2]
    end

    def compare_version_parts(parts1, parts2)
      parts1.zip(parts2).each do |p1, p2|
        return 1 if p1 > p2
        return -1 if p1 < p2
      end

      0
    end
  end
end

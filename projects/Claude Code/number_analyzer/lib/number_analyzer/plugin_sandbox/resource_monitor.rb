# frozen_string_literal: true

# Resource monitor for plugin sandboxing
# Monitors and limits CPU time, memory usage, and output size
class NumberAnalyzer::PluginSandbox::ResourceMonitor
  DEFAULT_LIMITS = {
    cpu_time: 5.0,          # Maximum execution time in seconds
    memory: 100_000_000,    # Maximum memory usage in bytes (100MB)
    output_size: 1_000_000, # Maximum output size in characters (1MB)
    stack_depth: 100        # Maximum call stack depth
  }.freeze

  attr_reader :cpu_time_limit, :memory_limit, :output_size_limit, :stack_depth_limit

  def initialize(limits = {})
    @limits = DEFAULT_LIMITS.merge(limits)
    @cpu_time_limit = @limits[:cpu_time]
    @memory_limit = @limits[:memory]
    @output_size_limit = @limits[:output_size]
    @stack_depth_limit = @limits[:stack_depth]

    @start_time = nil
    @start_memory = nil
    @monitor_thread = nil
  end

  # Monitor resource usage during plugin execution
  def monitor
    @start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    @start_memory = current_memory_usage

    # Start memory monitoring thread
    @monitor_thread = start_memory_monitor_thread

    begin
      result = yield

      # Validate output size
      validate_output_size(result)

      result
    ensure
      @monitor_thread&.kill
      @monitor_thread = nil
    end
  rescue StandardError
    @monitor_thread&.kill
    @monitor_thread = nil
    raise
  end

  # Get current resource usage statistics
  def current_stats
    {
      elapsed_time: elapsed_time,
      memory_usage: current_memory_usage - (@start_memory || 0),
      memory_total: current_memory_usage,
      limits: @limits
    }
  end

  private

  def start_memory_monitor_thread
    Thread.new do
      loop do
        check_resource_limits
        sleep 0.1 # Check every 100ms
      end
    rescue StandardError
      # Thread was killed or other error - exit gracefully
      Thread.exit
    end
  end

  def check_resource_limits
    # Check CPU time limit
    if elapsed_time > @cpu_time_limit
      Thread.main.raise NumberAnalyzer::PluginTimeoutError,
                        "CPU time limit exceeded: #{elapsed_time.round(2)}s (limit: #{@cpu_time_limit}s)"
    end

    # Check memory limit
    current_usage = current_memory_usage - (@start_memory || 0)
    if current_usage > @memory_limit
      Thread.main.raise NumberAnalyzer::PluginResourceError,
                        "Memory limit exceeded: #{format_bytes(current_usage)} (limit: #{format_bytes(@memory_limit)})"
    end

    # Check stack depth (approximate)
    return unless caller.length > @stack_depth_limit

    Thread.main.raise NumberAnalyzer::PluginResourceError,
                      "Stack depth limit exceeded: #{caller.length} (limit: #{@stack_depth_limit})"
  end

  def elapsed_time
    return 0.0 unless @start_time

    Process.clock_gettime(Process::CLOCK_MONOTONIC) - @start_time
  end

  def current_memory_usage
    # Platform-specific memory usage detection
    case RUBY_PLATFORM
    when /darwin/ # macOS
      memory_usage_macos
    when /linux/
      memory_usage_linux
    else
      # Fallback: use GC statistics (less accurate but portable)
      memory_usage_gc
    end
  end

  def memory_usage_macos
    # Use ps command to get RSS (Resident Set Size) in KB, convert to bytes
    output = `ps -o rss= -p #{Process.pid}`.strip
    output.to_i * 1024
  rescue StandardError
    memory_usage_gc
  end

  def memory_usage_linux
    # Read from /proc/pid/status for VmRSS
    status_file = "/proc/#{Process.pid}/status"
    return memory_usage_gc unless File.exist?(status_file)

    File.readlines(status_file).each do |line|
      next unless line.start_with?('VmRSS:')

      # Extract memory in KB and convert to bytes
      memory_kb = line.split[1].to_i
      return memory_kb * 1024
    end

    memory_usage_gc
  rescue StandardError
    memory_usage_gc
  end

  def memory_usage_gc
    # Fallback: estimate from GC statistics
    gc_stats = GC.stat

    # Rough estimation: heap_live_slots * average_object_size
    # This is not precise but gives a reasonable approximation
    live_objects = gc_stats[:heap_live_slots] || 0
    heap_pages = gc_stats[:heap_allocated_pages] || 0

    # Estimate: assume average 64 bytes per object + page overhead
    (live_objects * 64) + (heap_pages * 16_384)
  end

  def validate_output_size(result)
    output_size = calculate_output_size(result)

    return unless output_size > @output_size_limit

    raise NumberAnalyzer::PluginResourceError,
          "Output size limit exceeded: #{format_bytes(output_size)} (limit: #{format_bytes(@output_size_limit)})"
  end

  def calculate_output_size(result)
    case result
    when String
      result.bytesize
    when Array, Hash, Numeric
      result.to_s.bytesize
    else
      result.inspect.bytesize
    end
  rescue StandardError
    # Fallback: assume reasonable size if calculation fails
    1000
  end

  def format_bytes(bytes)
    return "#{bytes} B" if bytes < 1024

    units = %w[KB MB GB TB]
    size = bytes.to_f
    unit_index = 0

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024
      unit_index += 1
    end

    "#{size.round(2)} #{units[unit_index]}"
  end
end

# frozen_string_literal: true

# Semantic version comparison utility for NumberAnalyzer
# Handles version comparison and requirement satisfaction checks
class Numana::VersionComparator
  # Custom error for invalid version formats
  class InvalidVersionError < StandardError; end

  class << self
    # Compare two version strings
    # @param version1 [String] First version (e.g., "1.2.3")
    # @param version2 [String] Second version (e.g., "1.2.4")
    # @return [Integer] -1 if v1 < v2, 0 if equal, 1 if v1 > v2
    def compare(version1, version2)
      validate_version!(version1)
      validate_version!(version2)

      parts1 = normalize_version(version1)
      parts2 = normalize_version(version2)

      compare_version_parts(parts1, parts2)
    end

    # Check if version satisfies requirement
    # @param version [String] Version to check (e.g., "1.2.3")
    # @param requirement [String] Requirement (e.g., "~> 1.2", ">= 1.0")
    # @return [Boolean] true if version satisfies requirement
    def satisfies?(version, requirement)
      return true if requirement.nil? || requirement == '*'

      normalized_requirement = requirement.strip

      case normalized_requirement
      when /^~>\s*(.+)$/
        pessimistic_constraint?(version, Regexp.last_match(1).strip)
      when /^(>=|>|<=|<|==|=)\s*(.+)$/
        comparison_constraint?(version, Regexp.last_match(1), Regexp.last_match(2).strip)
      else
        version == normalized_requirement
      end
    end

    # Parse version requirement into operator and version
    # @param requirement [String] Version requirement
    # @return [Array<String, String>] [operator, version]
    def parse_requirement(requirement)
      normalized_requirement = requirement.strip

      case normalized_requirement
      when /^(~>|>=|>|<=|<|==|=)\s*(.+)$/
        [Regexp.last_match(1), Regexp.last_match(2).strip]
      else
        ['=', normalized_requirement]
      end
    end

    private

    def validate_version!(version)
      return if version.match?(/^\d+(\.\d+)*$/)

      raise InvalidVersionError, "Invalid version format: #{version}"
    end

    def normalize_version(version)
      parts = version.split('.').map(&:to_i)
      # Ensure at least 3 parts for semantic versioning
      parts + ([0] * [3 - parts.size, 0].max)
    end

    def compare_version_parts(parts1, parts2)
      # Make arrays same length
      max_length = [parts1.size, parts2.size].max
      parts1 += [0] * (max_length - parts1.size)
      parts2 += [0] * (max_length - parts2.size)

      parts1.zip(parts2).each do |p1, p2|
        return 1 if p1 > p2
        return -1 if p1 < p2
      end

      0
    end

    def pessimistic_constraint?(version, requirement)
      req_parts = requirement.split('.')
      ver_parts = version.split('.')

      # Version must have at least as many parts as requirement
      return false if ver_parts.size < req_parts.size

      # All parts except last must match exactly
      (0...(req_parts.size - 1)).each do |i|
        return false if req_parts[i] != ver_parts[i]
      end

      # Last part of version must be >= last part of requirement
      ver_parts[req_parts.size - 1].to_i >= req_parts.last.to_i
    end

    def comparison_constraint?(version, operator, requirement)
      comparison = compare(version, requirement)

      case operator
      when '>='
        comparison >= 0
      when '>'
        comparison.positive?
      when '<='
        comparison <= 0
      when '<'
        comparison.negative?
      when '=', '=='
        comparison.zero?
      end
    end
  end
end

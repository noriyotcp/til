# frozen_string_literal: true

require 'spec_helper'
require 'numana/version_comparator'

RSpec.describe Numana::VersionComparator do
  describe '.compare' do
    context 'when comparing major versions' do
      it 'returns 1 when first version is greater' do
        expect(described_class.compare('2.0.0', '1.0.0')).to eq(1)
      end

      it 'returns -1 when first version is smaller' do
        expect(described_class.compare('1.0.0', '2.0.0')).to eq(-1)
      end

      it 'returns 0 when versions are equal' do
        expect(described_class.compare('1.0.0', '1.0.0')).to eq(0)
      end
    end

    context 'when comparing minor versions' do
      it 'returns 1 when first minor version is greater' do
        expect(described_class.compare('1.2.0', '1.1.0')).to eq(1)
      end

      it 'returns -1 when first minor version is smaller' do
        expect(described_class.compare('1.1.0', '1.2.0')).to eq(-1)
      end
    end

    context 'when comparing patch versions' do
      it 'returns 1 when first patch version is greater' do
        expect(described_class.compare('1.0.2', '1.0.1')).to eq(1)
      end

      it 'returns -1 when first patch version is smaller' do
        expect(described_class.compare('1.0.1', '1.0.2')).to eq(-1)
      end
    end

    context 'when handling different version lengths' do
      it 'compares 2-part version with 3-part version' do
        expect(described_class.compare('1.1', '1.1.0')).to eq(0)
        expect(described_class.compare('1.1', '1.0.1')).to eq(1)
        expect(described_class.compare('1.0', '1.0.1')).to eq(-1)
      end

      it 'compares 1-part version with multi-part version' do
        expect(described_class.compare('1', '1.0.0')).to eq(0)
        expect(described_class.compare('2', '1.9.9')).to eq(1)
        expect(described_class.compare('1', '2.0.0')).to eq(-1)
      end

      it 'handles versions with more than 3 parts' do
        expect(described_class.compare('1.2.3.4', '1.2.3.3')).to eq(1)
        expect(described_class.compare('1.2.3.4', '1.2.3.5')).to eq(-1)
        expect(described_class.compare('1.2.3.4', '1.2.3.4')).to eq(0)
      end
    end

    context 'when validating version formats' do
      it 'raises error for invalid version with letters' do
        expect { described_class.compare('1.2.a', '1.0.0') }
          .to raise_error(Numana::VersionComparator::InvalidVersionError)
      end

      it 'raises error for invalid version with special characters' do
        expect { described_class.compare('1.2-beta', '1.0.0') }
          .to raise_error(Numana::VersionComparator::InvalidVersionError)
      end

      it 'raises error for empty version' do
        expect { described_class.compare('', '1.0.0') }
          .to raise_error(Numana::VersionComparator::InvalidVersionError)
      end

      it 'accepts valid numeric versions' do
        expect { described_class.compare('1.2.3', '4.5.6') }.not_to raise_error
        expect { described_class.compare('0', '1') }.not_to raise_error
        expect { described_class.compare('10.20.30', '1.2.3') }.not_to raise_error
      end
    end
  end

  describe '.satisfies?' do
    context 'with nil or wildcard requirements' do
      it 'returns true for nil requirement' do
        expect(described_class.satisfies?('1.2.3', nil)).to be true
      end

      it 'returns true for wildcard requirement' do
        expect(described_class.satisfies?('1.2.3', '*')).to be true
      end
    end

    context 'with pessimistic constraint (~>)' do
      it 'satisfies when patch version is greater or equal' do
        expect(described_class.satisfies?('1.2.3', '~> 1.2.0')).to be true
        expect(described_class.satisfies?('1.2.0', '~> 1.2.0')).to be true
        expect(described_class.satisfies?('1.2.9', '~> 1.2.0')).to be true
      end

      it 'does not satisfy when minor version differs' do
        expect(described_class.satisfies?('1.3.0', '~> 1.2.0')).to be false
        expect(described_class.satisfies?('1.1.9', '~> 1.2.0')).to be false
      end

      it 'does not satisfy when major version differs' do
        expect(described_class.satisfies?('2.0.0', '~> 1.2.0')).to be false
        expect(described_class.satisfies?('0.9.9', '~> 1.2.0')).to be false
      end

      it 'handles two-part pessimistic constraints' do
        expect(described_class.satisfies?('1.3.0', '~> 1.2')).to be true
        expect(described_class.satisfies?('1.2.0', '~> 1.2')).to be true
        expect(described_class.satisfies?('1.9.9', '~> 1.2')).to be true
        expect(described_class.satisfies?('2.0.0', '~> 1.2')).to be false
      end
    end

    context 'with comparison operators' do
      describe '>= operator' do
        it 'satisfies when version is greater or equal' do
          expect(described_class.satisfies?('1.2.3', '>= 1.2.3')).to be true
          expect(described_class.satisfies?('1.2.4', '>= 1.2.3')).to be true
          expect(described_class.satisfies?('1.3.0', '>= 1.2.3')).to be true
        end

        it 'does not satisfy when version is smaller' do
          expect(described_class.satisfies?('1.2.2', '>= 1.2.3')).to be false
          expect(described_class.satisfies?('1.1.9', '>= 1.2.3')).to be false
        end
      end

      describe '> operator' do
        it 'satisfies when version is greater' do
          expect(described_class.satisfies?('1.2.4', '> 1.2.3')).to be true
          expect(described_class.satisfies?('1.3.0', '> 1.2.3')).to be true
        end

        it 'does not satisfy when version is equal or smaller' do
          expect(described_class.satisfies?('1.2.3', '> 1.2.3')).to be false
          expect(described_class.satisfies?('1.2.2', '> 1.2.3')).to be false
        end
      end

      describe '<= operator' do
        it 'satisfies when version is smaller or equal' do
          expect(described_class.satisfies?('1.2.3', '<= 1.2.3')).to be true
          expect(described_class.satisfies?('1.2.2', '<= 1.2.3')).to be true
          expect(described_class.satisfies?('1.1.9', '<= 1.2.3')).to be true
        end

        it 'does not satisfy when version is greater' do
          expect(described_class.satisfies?('1.2.4', '<= 1.2.3')).to be false
          expect(described_class.satisfies?('1.3.0', '<= 1.2.3')).to be false
        end
      end

      describe '< operator' do
        it 'satisfies when version is smaller' do
          expect(described_class.satisfies?('1.2.2', '< 1.2.3')).to be true
          expect(described_class.satisfies?('1.1.9', '< 1.2.3')).to be true
        end

        it 'does not satisfy when version is equal or greater' do
          expect(described_class.satisfies?('1.2.3', '< 1.2.3')).to be false
          expect(described_class.satisfies?('1.2.4', '< 1.2.3')).to be false
        end
      end

      describe '= and == operators' do
        it 'satisfies when versions are exactly equal' do
          expect(described_class.satisfies?('1.2.3', '= 1.2.3')).to be true
          expect(described_class.satisfies?('1.2.3', '== 1.2.3')).to be true
        end

        it 'does not satisfy when versions differ' do
          expect(described_class.satisfies?('1.2.4', '= 1.2.3')).to be false
          expect(described_class.satisfies?('1.2.4', '== 1.2.3')).to be false
        end
      end
    end

    context 'with exact match' do
      it 'satisfies when versions match exactly' do
        expect(described_class.satisfies?('1.2.3', '1.2.3')).to be true
      end

      it 'does not satisfy when versions differ' do
        expect(described_class.satisfies?('1.2.4', '1.2.3')).to be false
      end
    end

    context 'with whitespace in requirements' do
      it 'handles extra whitespace correctly' do
        expect(described_class.satisfies?('1.2.3', '  >= 1.2.0  ')).to be true
        expect(described_class.satisfies?('1.2.3', '~>   1.2.0')).to be true
        expect(described_class.satisfies?('1.2.3', '<  1.3.0   ')).to be true
      end
    end
  end

  describe '.parse_requirement' do
    it 'parses pessimistic constraint' do
      expect(described_class.parse_requirement('~> 1.2.3')).to eq(['~>', '1.2.3'])
    end

    it 'parses comparison operators' do
      expect(described_class.parse_requirement('>= 1.2.3')).to eq(['>=', '1.2.3'])
      expect(described_class.parse_requirement('> 1.2.3')).to eq(['>', '1.2.3'])
      expect(described_class.parse_requirement('<= 1.2.3')).to eq(['<=', '1.2.3'])
      expect(described_class.parse_requirement('< 1.2.3')).to eq(['<', '1.2.3'])
      expect(described_class.parse_requirement('= 1.2.3')).to eq(['=', '1.2.3'])
      expect(described_class.parse_requirement('== 1.2.3')).to eq(['==', '1.2.3'])
    end

    it 'treats exact version as equals' do
      expect(described_class.parse_requirement('1.2.3')).to eq(['=', '1.2.3'])
    end

    it 'handles whitespace in requirements' do
      expect(described_class.parse_requirement('  >= 1.2.3  ')).to eq(['>=', '1.2.3'])
      expect(described_class.parse_requirement('~>   1.2.0')).to eq(['~>', '1.2.0'])
    end
  end
end

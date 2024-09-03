# frozen_string_literal: true

require 'cuprum/rspec/deferred/parameter_validation_examples'

require 'cuprum/collections/rspec/contracts'

module Cuprum::Collections::RSpec::Contracts
  # Contracts for asserting on Command objects.
  #
  # @deprecated 0.5.0 Command contracts are deprecated. Use Deferred::Commands
  #   examples instead.
  module CommandContracts
    include Cuprum::RSpec::Deferred::ParameterValidationExamples

    # :nocov:

    # Contract validating the behavior of an AssignOne command implementation.
    module ShouldBeAnAssignOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, allow_extra_attributes:)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param allow_extra_attributes [Boolean] if false, the command should
      #     fail if given attributes not defined for the entity.
      contract do |**|
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the AssignOne command"` instead.'
      end
    end

    # Contract validating the behavior of a Build command implementation.
    module ShouldBeABuildOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, allow_extra_attributes:)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      #   @param allow_extra_attributes [Boolean] if false, the command should
      #     fail if given attributes not defined for the entity.
      contract do |**|
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the BuildOne command"` instead.'
      end
    end

    # Contract validating the behavior of a DestroyOne command implementation.
    module ShouldBeADestroyOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the DestroyOne command"` instead.'
      end
    end

    # Contract validating the behavior of a FindMany command implementation.
    module ShouldBeAFindManyCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the FindMany command"` instead.'
      end
    end

    # Contract validating the behavior of a FindMatching command implementation.
    module ShouldBeAFindMatchingCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the FindMatching command"` instead.'
      end
    end

    # Contract validating the behavior of a FindOne command implementation.
    module ShouldBeAFindOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the FindOne command"` instead.'
      end
    end

    # Contract validating the behavior of an InsertOne command implementation.
    module ShouldBeAnInsertOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the InsertOne command"` instead.'
      end
    end

    # Contract validating the behavior of an UpdateOne command implementation.
    module ShouldBeAnUpdateOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group)
      #   Adds the contract to the example group.
      #
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the UpdateOne command"` instead.'
      end
    end

    # Contract validating the behavior of a ValidateOne command implementation.
    module ShouldBeAValidateOneCommandContract
      extend RSpec::SleepingKingStudios::Contract

      # @!method apply(example_group, default_contract:)
      #   Adds the contract to the example group.
      #
      #   @param default_contract [Boolean] if true, the command defines a
      #     default contract.
      #   @param example_group [RSpec::Core::ExampleGroup] the example group to
      #     which the contract is applied.
      contract do |**|
        pending \
          'Command contracts are deprecated. Use `include_deferred "should ' \
          'implement the ValidateOne command"` instead.'
      end
    end

    # :nocov:
  end
end

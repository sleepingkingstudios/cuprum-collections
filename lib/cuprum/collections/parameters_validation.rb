# frozen_string_literal: true

require 'forwardable'

require 'sleeping_king_studios/tools/toolbox/mixin'
require 'stannum/contracts/parameters_contract'

require 'cuprum/collections'
require 'cuprum/collections/errors/invalid_parameters'

module Cuprum::Collections
  # The ParametersValidation mixin adds a DSL for defining command parameters.
  #
  # Including ParametersValidation to a command adds a DSL for specifying the
  # arguments, keywords, and block (if any) used to call the command.
  #
  # When the command is called, the given arguments, keywords, and block are
  # compared with the expected parameters. If the parameters do not match, then
  # a failing Cuprum:Result is returned and the command's implementation is not
  # called. If the parameters do match, the the command's implementation is
  # called as normal, and the corresponding result is returned.
  #
  # When a command with validated parameters is subclassed, the command subclass
  # will use the parameters specified for the parent class. However, if the
  # subclass also specifies parameters, then only the parameters for the
  # subclass will be used to determine if the parameters to #call are valid.
  #
  # @example Using the DSL
  #   class ExampleCommand < Cuprum::Command
  #     include Cuprum::Collections::ParametersValidations
  #
  #     # Define the argument named :name at index 0, which must be a String.
  #     argument :name, String
  #
  #     # Define the argument named :description at index 1, which must be
  #     # either a String or nil.
  #     argument :description, String, optional: true
  #
  #     # Define the :quantity keyword, which must satisfy the block. On a
  #     # failed match, an error with the given type will be added to errors.
  #     keyword :quantity, type: 'example.quantity_type' do |qty|
  #       qty.is_a?(Integer) && qty >= 0
  #     end
  #
  #     # Define the :tags keyword, which must be an Array of Strings or nil.
  #     keyword :tags,
  #       Stannum::Constraints::Types::ArrayType.new(item_type: String),
  #       optional: true
  #
  #     private
  #
  #     def process(name, description = nil, quantity:, tags: [])
  #       success(:ok)
  #     end
  #   end
  #
  # @example Calling The Command With Invalid Parameters
  #   command = ExampleCommand.new
  #   result  = command.call
  #
  #   result.success? #=> false
  #   result.error
  #   #=> an instance of Cuprum::Collections::Errors::InvalidParameters
  #
  #   result.error.errors
  #   #=> an instance of Stannum::Errors
  #
  # @example Calling The Command With Valid Parameters
  #   command = ExampleCommand.new
  #   result  = command.call('Stem Bolt', quantity: 1_000, tags: ['cheap'])
  #
  #   result.success? #=> true
  #   result.value    #=> :ok
  #
  # @see ClassMethods
  module ParametersValidation
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    # Defines a DSL for command parameter validations.
    module ClassMethods
      extend Forwardable

      # @!method argument(name, type = nil, index: nil, **options, &block)
      #   Adds an argument constraint for the #call method.
      #
      #   If the index is specified, then the constraint will be added for the
      #   argument at the specified index. If the index is not given, then the
      #   constraint will be applied to the next unconstrained argument. For
      #   example, the first argument constraint will be added for the argument
      #   at index 0, the second constraint for the argument at index 1, and so
      #   on.
      #
      #   @return [Stannum::Contracts::ParametersContract::Builder] the
      #     parameters contract builder.
      #
      #   @overload argument(name, type, index: nil, **options)
      #     Generates an argument constraint based on the given type. If the
      #     type is a constraint, then the given constraint will be copied with
      #     the given options and added for the argument at the index. If the
      #     type is a Class or a Module, then a Stannum::Constraints::Type
      #     constraint will be created with the given type and options and added
      #     for the argument.
      #
      #     @param name [String, Symbol] The name of the argument.
      #     @param type [Class, Module, Stannum::Constraints:Base] The expected
      #       type of the argument.
      #     @param index [Integer, nil] The index of the argument. If not given,
      #       then the next argument will be constrained with the type.
      #     @param options [Hash<Symbol, Object>] Configuration options for the
      #       constraint. Defaults to an empty Hash.
      #
      #     @return [Stannum::Contracts::ParametersContract::Builder] the
      #       parameters contract builder.
      #
      #   @overload argument(name, index: nil, **options, &block
      #     Generates a new Stannum::Constraint using the block.
      #
      #     @param name [String, Symbol] The name of the argument.
      #     @param index [Integer, nil] The index of the argument. If not given,
      #       then the next argument will be constrained with the type.
      #     @param options [Hash<Symbol, Object>] Configuration options for the
      #       constraint. Defaults to an empty Hash.
      #
      #     @yield The definition for the constraint. Each time #matches? is
      #       called for this constraint, the given object will be passed to
      #       this block and the result of the block will be returned.
      #     @yieldparam actual [Object] The object to check against the
      #       constraint.
      #     @yieldreturn [true, false] true if the given object matches the
      #       constraint, otherwise false.
      #
      #     @return [Stannum::Contracts::ParametersContract::Builder] the
      #       parameters contract builder.

      # @!method arguments(name, type)
      #   Sets the variadic arguments constraint for the #call method.
      #
      #   If the parameters includes variadic (or "splatted") arguments, then
      #   each item in the variadic arguments array must match the given type or
      #   constraint. If the type is a constraint, then the given constraint
      #   will be copied with the given options. If the type is a Class or a
      #   Module, then a Stannum::Constraints::Type constraint will be created
      #   with the given type.
      #
      #   @param name [String, Symbol] a human-readable name for the variadic
      #     arguments; used in generating error messages.
      #   @param type [Class, Module, Stannum::Constraints:Base] The expected
      #     type of the variadic arguments items.
      #
      #   @return [Stannum::Contracts::ParametersContract::Builder] the
      #     parameters contract builder.
      #
      #   @raise [RuntimeError] if there is already a variadic arguments
      #     constraint defined for the contract.

      # @!method block(present)
      #   Sets the block parameter constraint for the #call method.
      #
      #   If the expected presence is true, a block must be given as part of the
      #   parameters. If the expected presence is false, a block must not be
      #   given. If the presence is a constraint, then the block must match the
      #   constraint.
      #
      #   @param present [true, false, Stannum::Constraint] The expected
      #     presence of the block.
      #
      #   @return [Stannum::Contracts::ParametersContract::Builder] the
      #     parameters contract builder.
      #
      #   @raise [RuntimeError] if there is already a block constraint defined
      #     for the contract.

      # @!method keyword(name, type = nil, **options, &block)
      #   Adds a keyword constraint for the #call method.
      #
      #   @return [Stannum::Contracts::ParametersContract::Builder] the
      #     parameters contract builder.
      #
      #   @overload keyword(name, type, **options)
      #     Generates a keyword constraint based on the given type. If the type
      #     is a constraint, then the given constraint will be copied with the
      #     given options and added for the given keyword. If the type is a
      #     Class or a Module, then a Stannum::Constraints::Type constraint will
      #     be created with the given type and options and added for the
      #     keyword.
      #
      #     @param keyword [Symbol] The keyword to constrain.
      #     @param type [Class, Module, Stannum::Constraints:Base] The expected
      #       type of the keyword.
      #     @param options [Hash<Symbol, Object>] Configuration options for the
      #       constraint. Defaults to an empty Hash.
      #
      #     @return [Stannum::Contracts::ParametersContract::Builder] the
      #       parameters contract builder.
      #
      #   @overload keyword(name, **options, &block)
      #     Generates a new Stannum::Constraint using the block.
      #
      #     @param keyword [Symbol] The keyword to constrain.
      #     @param options [Hash<Symbol, Object>] Configuration options for the
      #       constraint. Defaults to an empty Hash.
      #
      #     @yield The definition for the constraint. Each time #matches? is
      #       called for this constraint, the given object will be passed to
      #       this block and the result of the block will be returned.
      #     @yieldparam actual [Object] The object to check against the
      #       constraint.
      #     @yieldreturn [true, false] true if the given object matches the
      #       constraint, otherwise false.
      #
      #     @return [Stannum::Contracts::ParametersContract::Builder] the
      #       parameters contract builder.

      # @!method keywords(name, type)
      #   Sets the variadic keywords constraint for the contract.
      #
      #   If the parameters includes variadic (or "splatted") keywords, then
      #   each value in the variadic keywords hash must match the given type or
      #   constraint. If the type is a constraint, then the given constraint
      #   will be copied with the given options. If the type is a Class or a
      #   Module, then a Stannum::Constraints::Type constraint will be created
      #   with the given type.
      #
      #   @param name [String, Symbol] a human-readable name for the variadic
      #     keywords; used in generating error messages.
      #   @param type [Class, Module, Stannum::Constraints:Base] The expected
      #     type of the variadic keywords values.
      #
      #   @return [Stannum::Contracts::ParametersContract::Builder] the
      #     parameters contract builder.
      #
      #   @raise [RuntimeError] if there is already a variadic keywords
      #     constraint defined for the contract.

      def_delegators :parameters_contract_builder,
        :argument,
        :arguments,
        :block,
        :keyword,
        :keywords

      protected

      def parameters_contract
        return @parameters_contract if @parameters_contract

        if superclass < Cuprum::Collections::ParametersValidation
          return superclass.parameters_contract
        end

        nil
      end

      private

      def parameters_contract_builder
        # Calling a builder method ensures that the command class has its own
        # parameters contract.
        @parameters_contract_builder ||=
          Stannum::Contracts::ParametersContract::Builder
            .new(
              @parameters_contract ||=
                Stannum::Contracts::ParametersContract.new
            )
      end
    end

    # Validates the parameters before calling the command implementation.
    #
    # If the given arguments, keywords, and block do not match the specified
    # parameters, #call will immediately return a result with status: :failure
    # and an InvalidParameters error. If the parameters do match, then the
    # command implementation is called as normal.
    #
    # @param arguments [Array] The arguments to validate and pass on to the
    #   implementation.
    # @param keywords [Hash] The keywords to validate and pass on to the
    #   implementation.
    # @param block [Proc, nil] The block, if any, to validate and pass to the
    #   implementation.
    #
    # @return [Cuprum::Result] the failing result with an invalid parameters
    #   error, or the result of calling the command implementation.
    #
    # @see ClassMethods
    # @see Cuprum::Collections::Errors::InvalidParameters
    def call(*arguments, **keywords, &block) # rubocop:disable Metrics/MethodLength
      contract = self.class.send(:parameters_contract)

      return super unless contract

      status, errors = contract.match(
        { arguments: arguments, keywords: keywords, block: block }
      )

      return super if status

      error = Cuprum::Collections::Errors::InvalidParameters.new(
        command: self,
        errors:  errors
      )
      failure(error)
    end
  end
end

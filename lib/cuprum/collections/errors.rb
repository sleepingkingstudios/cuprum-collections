# frozen_string_literal: true

require 'cuprum/collections'

module Cuprum::Collections
  # Namespace for errors, which represent failure states of commands.
  module Errors
    autoload :AbstractFindError, 'cuprum/collections/errors/abstract_find_error'
    autoload :AlreadyExists,     'cuprum/collections/errors/already_exists'
    autoload :ExtraAttributes,   'cuprum/collections/errors/extra_attributes'
    autoload :FailedValidation,  'cuprum/collections/errors/failed_validation'
    autoload :InvalidParameters, 'cuprum/collections/errors/invalid_parameters'
    autoload :InvalidQuery,      'cuprum/collections/errors/invalid_query'
    autoload :MissingDefaultContract,
      'cuprum/collections/errors/missing_default_contract'
    autoload :NotFound,          'cuprum/collections/errors/not_found'
    autoload :NotUnique,         'cuprum/collections/errors/not_unique'
    autoload :UnknownOperator,   'cuprum/collections/errors/unknown_operator'
  end
end

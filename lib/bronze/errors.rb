# frozen_string_literal: true

require 'bronze'

module Bronze
  # Namespace for errors, which represent failure states of commands.
  module Errors
    autoload :AbstractFindError,      'bronze/errors/abstract_find_error'
    autoload :AlreadyExists,          'bronze/errors/already_exists'
    autoload :ExtraAttributes,        'bronze/errors/extra_attributes'
    autoload :FailedValidation,       'bronze/errors/failed_validation'
    autoload :InvalidParameters,      'bronze/errors/invalid_parameters'
    autoload :InvalidQuery,           'bronze/errors/invalid_query'
    autoload :MissingDefaultContract, 'bronze/errors/missing_default_contract'
    autoload :NotFound,               'bronze/errors/not_found'
    autoload :NotUnique,              'bronze/errors/not_unique'
    autoload :UnknownOperator,        'bronze/errors/unknown_operator'
  end
end

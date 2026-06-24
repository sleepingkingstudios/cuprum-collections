# frozen_string_literal: true

require 'bronze/adaptable'

module Bronze::Adaptable
  # Namespace for adaptable command implementations.
  module Commands
    autoload :AbstractAssignOne,
      'bronze/adaptable/commands/abstract_assign_one'
    autoload :AbstractBuildOne,
      'bronze/adaptable/commands/abstract_build_one'
    autoload :AbstractValidateOne,
      'bronze/adaptable/commands/abstract_validate_one'
  end
end

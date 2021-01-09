# frozen_string_literal: true

module Spec
  module ContractHelpers
    def include_contract(contract, *args, **kwargs)
      # :nocov:
      if kwargs.empty?
        instance_exec(*args, &contract)
      else
        instance_exec(*args, **kwargs, &contract)
      end
      # :nocov:
    end
  end
end

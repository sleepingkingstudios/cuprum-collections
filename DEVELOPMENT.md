# Development

## Commands

### ParameterCoercion

```ruby
class ExampleCommand
  argument :name,       String
  argument :attributes, Hash

  coerce :attributes, :hash_with_string_keys

  coerce(:name) { |str| str.strip }
end
```

Preprocess arguments after validation but before #process is called.

## Queries

Standardize caching (or not) of Query results.

Accessors for @limit, @offset, @order
  - Overload methods? Return current value if no parameters?
  - Namespaced accessors? E.g. #query_limit, #query_offset, ... ?

Harmonize #order validation/coercion between Query#order_by and Filter#call
  - Possible values:
    - nil
    - attr_name
    - [attr_name, ...]
    - { attr_name: direction, ... }
    - [attr_name, ..., { attr_name: direction }, ...]
  - Coerce possible values to { attr_name: direction }

Query#merge ?
  - Merges the criteria from other#criteria.
  - Applies the limit, offset, order from other if not nil.

### Operators

Steps to add an operator:

- Update Queries::Operators.
- Update Queries::ParseBlock::Builder.
- Define context(s) in RSpec::QUERYING_CONTEXTS.
- Add test cases in RSpec::QUERYING_CONTRACT.
- Add implementations to Reference::Query::Builder.

### ParseCriteria

Validates and returns an Array of criteria.

### ParseQuery

Extends ParseCriteria, passes Query#criteria to super.

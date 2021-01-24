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

Accessors for @limit, @offset, @order
  - Overload methods? Return current value if no parameters?
  - Namespaced accessors? E.g. #query_limit, #query_offset, ... ?

Accept a Query object as parameter to Query#where.
  - Merges the criteria from other#criteria.
  - Applies the limit, offset, order from other if not nil.

### Parse

Simplify parsing logic
  - Filter.call(where:) accepts a single argument or block.
  - Restrict Query.where() to accept arg, strategy:, &block
  - Refactor Parse.call to accept argument:, strategy:, block:.
    - Refactor ParseStrategy, Parse* commands.

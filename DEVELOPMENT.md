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

### ParseBlock

Define `Errors::InvalidQueryBlock` with `errors: Stannum::Errors`

Potential failure points:
  - The block raises an exception when called
    - `-> { raise }`
    - `errors.add(exception_raised, exception_class:, exception_message:)`
    - invalid query block: exception raised SomeError: some message
  - The block returns a non-Hash object
    - `-> { nil }`
    - `errors.add(block_not_hash, value: actual)`
    - invalid query block: block should yield a Hash, but yielded actual.inspect
  - The block returns a Hash with an invalid hash key.
    - `-> { { '' => nil } }`
    - `errors.add(invalid_hash_keys, keys: [])`
    - invalid query block: hash keys must be non-empty strings or symbols, but received keys.map.inspect
  - The block tries to access an unrecognized operator.
    - `-> { { title: random() } }`
    - `errors[attribute].add(unknown_operator, name:)`
    - invalid query block: unknown operator $name for attribute $attribute

Define `::matches?(arguments:, keywords:, block:)`
  - true if block present and arguments+keywords empty.

### ParseCriteria

Validates and returns criteria.

Define `::matches?(arguments:, keywords:, block:)`
  - true if arguments has 1 item (Array of Arrays), keywords empty, block nil

### ParseNull

Returns empty criteria

Define `::matches?(arguments:, keywords:, block:)`
  - true if block nil and arguments+keywords empty.

### ParseQuery

Strategy pattern for parsing Query#where.

Call takes optional `strategy:` keyword, otherwise determine strategy based on arguments/keywords/block.
  - for each strategy, call `::matches?` and apply strategy if true
  - otherwise UnknownParseStrategy error(arguments:, keywords:, block:)

### QueryBuilder

Replace BlockParser with ParseQuery
  - If ParseQuery.call() fails, raise InvalidQueryError, error.message

Support passing arguments, keywords, strategy: keyword to `#call`.

Add keyword `parse_query: true`; if false, sets `criteria` to `arguments.first`.

### Query

Support passing arguments, keywords, strategy: keyword to `#where`.
  - Passed to QueryBuilder.

### FilterCommand

- Add `parse_query` step
  - Converts block, `where:` keyword to criteria
- Pass criteria to `build_query` step
  - Query.where(criteria, strategy: :criteria)

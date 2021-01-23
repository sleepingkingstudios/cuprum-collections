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

### BlockParser

Refactor to `class ParseBlock < Cuprum::Command`
  - Define `class InvalidQueryError < ArgumentError`
  - Define `initialize(failure_strategy: :result)`
    - If `failure_strategy: :raise`, raises an `InvalidQueryError` on failure
    - If `failure_strategy: :result`, returns a `Cuprum::Result` on failure
  - Handle unknown operators (using `method_missing` ?)

# Development

## Queries

Harmonize #order validation/coercion between Query#order_by and Filter#call
  - Possible values:
    - nil
    - attr_name
    - [attr_name, ...]
    - { attr_name: direction, ... }
    - [attr_name, ..., { attr_name: direction }, ...]
  - Coerce possible values to { attr_name: direction }

### Operators

Steps to add an operator:

- Update Queries::Operators.
- Update Queries::ParseBlock::Builder.
- Define context(s) in RSpec::QUERYING_CONTEXTS.
- Add test cases in RSpec::QUERYING_CONTRACT.
- Add implementations to Basic::QueryBuilder.

### ParseCriteria

Validates and returns an Array of criteria.

### ParseHash

All values use :eq operator.

### ParseQuery

Extends ParseCriteria, passes Query#criteria to super.

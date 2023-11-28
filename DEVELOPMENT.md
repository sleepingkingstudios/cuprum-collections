# Development

## Queries

### Operators

Steps to add an operator:

- Update Queries::Operators.
- Update Queries::ParseBlock::Builder.
- Define context(s) in QueryContracts::WithQueryContexts.
- Add test cases in QueryContracts::ShouldPerformQueries.
- Add implementations to Basic::QueryBuilder.

### ParseCriteria

Validates and returns an Array of criteria.

### ParseHash

All values use :eq operator.

### ParseQuery

Extends ParseCriteria, passes Query#criteria to super.

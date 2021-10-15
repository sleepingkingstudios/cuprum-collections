# Changelog

## 0.1.0

Initial version.

## Collections

Implemented `Basic::Collection` and associated commands:

- `Basic::Comands::AssignOne`
- `Basic::Comands::BuildOne`
- `Basic::Comands::DestroyOne`
- `Basic::Comands::FindMany`
- `Basic::Comands::FindMatching`
- `Basic::Comands::FindOne`
- `Basic::Comands::InsertOne`
- `Basic::Comands::UpdateOne`
- `Basic::Comands::ValidateOne`

Implemented `Basic::Query`

Defined contract for validating collections.

## Commands

Defined contracts for validating collection commands.

## Constraints

Implemented collection constraints:

- `AttributeName`
- `Order::SortDirection`
- `Ordering`
- `QueryHash`

 `AttributeName`, `Ordering`, and `QueryHash` constraints.

## Errors

Implemented collection errors:

- `AlreadyExists`
- `ExtraAttributes`
- `FailedValidation`
- `InvalidParameters`
- `InvalidQuery`
- `MissingDefaultContract`
- `NotFound`
- `UnknownOperator`

## Queries

Implemented abstract `Query`.

Implemented `ParseBlock` strategy.

Defined contract for validating collection queries.

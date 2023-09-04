# Changelog

## 0.3.0

### Collections

Defined standard interface for collections.

- Implemented `Cuprum::Collections::Collection`.
- Collections can now be initialized with any combination of collection name and entity class.

Updated `Cuprum::Collections::Basic::Collection`.

- Implemented `#count` method.
- Implemented `#qualified_name` method.

### Commands

Implemented built-in Commands, which take a `:collection` parameter:

- `Commands::Create`
- `Commands::FindOneMatching`
- `Commands::Update`
- `Commands::Upsert`

### Repositories

Defined standard interface for repositories.

- Implemented `Repository#create`.
- Implemented `Repository#find_or_create`.

## 0.2.0

Implemented `Cuprum::Collections::Repository`.

### Collections

Implemented `Cuprum::Collections::Basic::Repository`.

### Queries

Fixed passing an attributes array as a query ordering.

## 0.1.0

Initial version.

## Collections

Implemented `Basic::Collection` and associated commands:

- `Basic::Commands::AssignOne`
- `Basic::Commands::BuildOne`
- `Basic::Commands::DestroyOne`
- `Basic::Commands::FindMany`
- `Basic::Commands::FindMatching`
- `Basic::Commands::FindOne`
- `Basic::Commands::InsertOne`
- `Basic::Commands::UpdateOne`
- `Basic::Commands::ValidateOne`

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

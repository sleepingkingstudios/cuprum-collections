# Changelog

## 0.3.0

### Associations

Implemented `Cuprum::Collections::Association`, which represents an association between entity types.

- Implemented `Cuprum::Collections::Associations::BelongsTo`.
- Implemented `Cuprum::Collections::Associations::HasMany`.
- Implemented `Cuprum::Collections::Associations::HasOne`.

### Collections

Defined standard interface for collections.

- Implemented `Cuprum::Collections::Collection`.
- Collections can now be initialized with any combination of collection name, entity class, and qualified name.

Updated `Cuprum::Collections::Basic::Collection`.

- Implemented `#count` method.
- Implemented `#qualified_name` method.

Deprecated certain collection methods and corresponding constructor keywords:

- `#collection_name`: Use `#name`.
- `#member_name`: Use `#singular_name`.

### Commands

Implemented built-in Commands, which take a `:collection` parameter:

- `Commands::Create`
- `Commands::FindOneMatching`
- `Commands::Update`
- `Commands::Upsert`

Implemented association Commands, which find or require association entities from a list of entities or keys.

- `Commands::Associations::FindMany`
- `Commands::Associations::RequireMany`

### Relations

Defined `Cuprum::Collections::Relation`, an abstract class representing a group or view of entities.

### Repositories

Defined standard interface for repositories.

- Implemented `Repository#create`.
- Implemented `Repository#find_or_create`.

### Resources

Defined `Cuprum::Collections::Resource`, representing a singular or plural resource of entities.

### RSpec

- **(Breaking Change)** Contracts have been refactored to use `RSpec::SleepingKingStudios::Contract`. Contract names and filenames have changed.

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

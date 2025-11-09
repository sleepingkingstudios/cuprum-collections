# Changelog

## 0.6.0

Removed all deprecated functionality from version 0.5.0 and earlier.

### Repositories

- Implemented `#find`, which finds the matching collection by name, qualified name, or entity class.
- Implemented `#remove`, which removes the collection with the specified qualified name.

## 0.5.1

Added missing `config/locales` directory to the gemspec.

## 0.5.0

Major refactoring of Queries. This update is **not** backwards compatible.

### Collections

Collection commands no longer define the command subclass, e.g. `rockets_collection::Launch`. Instances of the command can still be created using `rockets_collection#launch`.

### Commands

Refactored commands to use more lightweight parameter validation from `SleepingKingStudios::Tools`.

### Queries

Query result filtering now uses composable scopes.

- Implemented `Query#scope`.
- Implemented composable methods `Query#and`, `Query#or`, `Query#not`.

Performing block queries with an implicit receiver is now deprecated. Instead of:

`where { { author: eq('J.R.R. Tolkien) } }`

An explicit receiver must be passed to be block in order to use operators:

`where { |query| { author: query.eq('J.R.R. Tolkien) } }`

### Relations

Extracted `Cuprum::Collections::Relations` concerns.

- Added `#scope` support to `Cuprum::Collections::Resource`.

### RSpec

Migrated shared contract objects to deferred example groups:

- `Cuprum::Collections::RSpec::Deferred::AssociationExamples`
- `Cuprum::Collections::RSpec::Deferred::CollectionExamples`
- `Cuprum::Collections::RSpec::Deferred::CommandExamples`
- `Cuprum::Collections::RSpec::Deferred::Commands::*`
- `Cuprum::Collections::RSpec::Deferred::RelationExamples`
- `Cuprum::Collections::RSpec::Deferred::ResourceExamples`

The corresponding contracts are now deprecated.

### Scopes

Implemented `Cuprum::Collections::Scopes`. A scope object represents a filter that can be used to select a subset of a collection.

`Cuprum::Collections` defines generic scope classes for defining scopes in a collection-independant fashion. Each collection must also implement the filtering behavior for each scope type.

#### Criteria Scopes

Criteria scopes use a list of criteria to filter data. Each criterion has an attribute name, an operator (such as "equals", "greater than" or "not in"), and an expected value.

#### Logical Scopes

Conjunction scopes wrap one or more other scopes with a logical AND operation.

Disjunction scopes wrap one or more other scopes with a logical OR operation.

#### Scope Inversion

Scopes are responsible for defining their own inverse. An inverted scope should match on a collection item if and only if the base scope does not match that item.

### Other Changes

Remove deprecations from previous versions:

- Removed `Cuprum::Collections::Relation::Disambiguation`.
- Removed initializing an `AbstractFindError` subclass with `primary_key_name` and `primary_key_values` keywords.

## 0.4.0

### Associations

Implemented `Cuprum::Collections::Association`, which represents an association between entity types.

- Implemented `Cuprum::Collections::Associations::BelongsTo`.
- Implemented `Cuprum::Collections::Associations::HasMany`.
- Implemented `Cuprum::Collections::Associations::HasOne`.

### Collections

Defined standard interface for collections.

- Implemented `Cuprum::Collections::Collection`.
- Collections can now be initialized with any combination of collection name, entity class, and qualified name.

Deprecated certain collection methods and corresponding constructor keywords:

- `#collection_name`: Use `#name`.
- `#member_name`: Use `#singular_name`.

### Commands

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

## 0.3.0

### Collections

Updated `Cuprum::Collections::Basic::Collection`.

- Implemented `#count` method.
- Implemented `#qualified_name` method.

### Commands

Implemented built-in Commands, which take a `:collection` parameter:

- `Commands::Create`
- `Commands::FindOneMatching`
- `Commands::Update`
- `Commands::Upsert`

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

# Cuprum::Collections

A data abstraction layer based on the Cuprum library.

Cuprum::Collections defines the following objects:

- [Collections](#collections): A standard interface for interacting with a datastore.
- [Commands](#commands): Each collection is comprised of `Cuprum` commands, which implement common collection operations such as inserting or querying data.
- [Queries](#queries): A low-level interface for performing query operations on a datastore.

## About

Cuprum::Collections provides a standard interface for interacting with a datastore, whether the data is in a relational database, a document-based datastore, a directory of files, or simply an array of in-memory objects. It leverages the `Cuprum` and `Stannum` gems to define a set of commands with built-in parameter validation and error handling.

Currently, the Cuprum::Collections gem itself provides the `Basic` collection, which stores and queries data to and from an in-memory `Array` of `Hash`es data structure. Additional datastores are supported via other gems:

- [Cuprum::Rails](https://github.com/sleepingkingstudios/cuprum-rails/): The `Cuprum::Rails::Collection` implement the collection interface for `ActiveRecord` models.

### Why Cuprum::Collections?

The Ruby ecosystem has a wide variety of tools and libraries for managing data and persistence - ORMs like [ActiveRecord](https://rubyonrails.org/) and [Mongoid](https://mongoid.github.io/), object mapping tools like [Ruby Object Mapper](https://rom-rb.org/), and low-level libraries like [Sequel](http://sequel.jeremyevans.net/) and [Mongo](https://docs.mongodb.com/ruby-driver/current/). Why take the time to learn and apply a new tool?

- **Flexibility:** Using a consistent interface allows an application to be flexible in how it persists and queries data. For example, an application could use the same interface to manage both a relational database and a document-based datastore, or use a fast in-memory data store to back its unit tests.
- **Command Pattern:** Leverages the [Cuprum](https://github.com/sleepingkingstudios/cuprum) gem and the [Command pattern](https://en.wikipedia.org/wiki/Command_pattern) to define encapsulated, composable, and reusable components for persisting and querying data. In addition, the [Stannum](https://github.com/sleepingkingstudios/stannum/) gem provides data and parameter validation.
- **Data Mapping:** The `Cuprum::Collections` approach to data is much closer to the [Data Mapper pattern](https://en.wikipedia.org/wiki/Data_mapper_pattern) than the [Active Record pattern](https://en.wikipedia.org/wiki/Active_record_pattern). This isolates the persistence and validation logic from how the data is defined and how it is stored.

### Compatibility

Cuprum::Collections is tested against Ruby (MRI) 2.6 through 2.7.

### Documentation

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2020-2021 Rob Smith

Stannum is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum-collections.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/cuprum-collections/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/cuprum-collections/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Code of Conduct

Please note that the `Cuprum::Collections` project is released with a [Contributor Code of Conduct](https://github.com/sleepingkingstudios/cuprum-collections/blob/master/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

<!-- ## Getting Started  -->

## Reference

<a id="collections"></a>

### Collections

A `Cuprum::Collection` provides an interface for persisting and querying data to and from a data source.

Each collection provides three features:

- A constructor that initializes the collection with the necessary parameters.
- A set of commands that implement persistence and querying operations.
- A `#query` method to directly perform queries on the data.

```ruby
collection = Cuprum::Collections::Basic.new(
  collection_name: 'books',
  data:            book_data,
)

# Add an item to the collection.
steps do
  # Build the book from attributes.
  book = step do
    collection.build_one.call(
      attributes: { id: 10, title: 'Gideon the Ninth', author: 'Tammsyn Muir' }
    )
  end

  # Validate the book using its default validations.
  step { collection.validate_one.call(entity: book) }

  # Insert the validated book to the collection.
  step { collection.insert_one.call(entity: book) }
end

# Find an item by primary key.
book = step { collection.find_one.call(primary_key: 10) }

# Find items matching a filter.
books = step do
  collection.find_matching.call(
    limit: 10,
    order: [:author, { title: :descending }],
    where: lambda do
      published_at: greater_than('1950-01-01')
    end
  )
end
```

Because a collection can represent any sort of data, from a raw Ruby Hash to an ORM record, the term used to indicate "one item in the collection" is an *entity*. Likewise, the class of the items in the collection is the *entity_class*. In our example above, our entities are books, and the entity class is Hash.

<a id="commands"></a>

#### Commands

Structurally, a collection is a set of commands, which are instances of `Cuprum::Command` that implement a persistence or querying operation and wrap that operation with parameter validation and error handling. For more information on `Cuprum` commands, see the [Cuprum gem](github.com/sleepingkingstudios/cuprum).

##### Assign One

The `AssignOne` command takes an attributes hash and an entity, and returns an instance of the entity class whose attributes are equal to the attributes hash merged into original entities attributes. Depending on the collection, `#assign_one` may or may not modify or return the original entity.

```ruby
book       = { 'id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tammsyn Muir' }
attributes = { 'title' => 'Harrow the Ninth', 'published_at' => '2020-08-04' }
result     = collection.assign_one.call(attributes: attributes, entity: entity)

result.value
#=> {
#     'id'           => 10,
#     'title'        => 'Harrow the Ninth',
#     'author'       => 'Tammsyn Muir',
#     'published_at' => '2020-08-04'
#   }
```

If the entity class specifies a set of attributes (such as the defined columns in a relational table), the `#assign_one` command can return a failing result with an `ExtraAttributes` error (see [Errors](#errors), below) if the attributes hash includes one or more attributes that are not defined for that entity class.

##### Build One

The `BuildOne` command takes an attributes hash and returns a new instance of the entity class whose attributes are equal to the given attributes. This does not validate or persist the entity; it is equivalent to calling `entity_class.new` with the attributes.

```ruby
attributes = { 'id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tammsyn Muir' }
result     = collection.build_one.call(attributes: attributes, entity: entity)

result.value
#=> {
#     'id'           => 10,
#     'title'        => 'Gideon the Ninth',
#     'author'       => 'Tammsyn Muir'
#   }
```

If the entity class specifies a set of attributes (such as the defined columns in a relational table), the `#build_one` command can return a failing result with an `ExtraAttributes` error (see [Errors](#errors), below) if the attributes hash includes one or more attributes that are not defined for that entity class.

##### Destroy One

The `DestroyOne` command takes a primary key value and removes the entity with the specified primary key from the collection.

```ruby
result = collection.destroy_one.call(primary_key: 0)

collection.query.where(id: 0).exists?
#=> false
```

If the collection does not include an entity with the specified primary key, the `#destroy_one` command will return a failing result with a `NotFound` error (see [Errors](#errors), below).

##### Find Many

The `FindMany` command takes an array of primary key values and returns the entities with the specified primary keys. The entities are returned in the order of the specified primary keys.

```ruby
result = collection.find_many.call(primary_keys: [0, 1, 2])
result.value
#=> [
#     {
#       'id'           => 0,
#       'title'        => 'The Hobbit',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => nil,
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1937-09-21'
#     },
#     {
#       'id'           => 1,
#       'title'        => 'The Silmarillion',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => nil,
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1977-09-15'
#     },
#     {
#       'id'           => 2,
#       'title'        => 'The Fellowship of the Ring',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => 'The Lord of the Rings',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1954-07-29'
#     }
#   ]
```

The `FindMany` command has several options:

- The `:allow_partial` keyword allows the command to return a passing result if at least one of the entities is found. By default, the command will return a failing result unless an entity is found for each primary key value.
- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the name of the collection and whose value is the returned entities array.

    ```ruby
    result = collection.find_many.call(primary_keys: [0, 1, 2], envelope: true)
    result.value
    #=>  { books: [{ ... }, { ... }, { ... }] }
    ```

- The `:scope` keyword allows you to pass a query to the command. Only entities that match the given scope will be found and returned by `#find_many`.

If the collection does not include an entity with each of the specified primary keys, the `#find_many` command will return a failing result with a `NotFound` error (see [Errors](#errors), below).

##### Find Matching

The `FindMatching` command takes a set of query parameters and queries data from the collection. You can specify filters using the `:where` keyword or by passing a block, sort the results using the `:order` keyword, or return a subset of the results using the `:limit` and `:offset` keywords. For full details on performing queries, see [Queries](#queries), below.

```ruby
result =
  collection
  .find_matching
  .call(order: :published_at, where: { series: 'Earthsea' })
result.value
#=> [
#     {
#       'id'           => 7,
#       'title'        => 'A Wizard of Earthsea',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1968-11-01'
#     },
#     {
#       'id'           => 8,
#       'title'        => 'The Tombs of Atuan',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1970-12-01'
#     },
#     {
#       'id'           => 9,
#       'title'        => 'The Farthest Shore',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1972-09-01'
#     }
#   ]
```

The `FindMatching` command has several options:

- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the name of the collection and whose value is the returned entities array.

    ```ruby
    result = collection.find_matching.call(where: { series: 'Earthsea' }, envelope: true)
    result.value
    #=>  { books: [{ ... }, { ... }, { ... }] }
    ```

- The `:scope` keyword allows you to pass a query to the command. Only entities that match the given scope will be found and returned by `#find_matching`.

##### Find One

The `FindOne` command takes a primary key value and returns the entity with the specified primary key.

```ruby
result = collection.find_one.call(primary_key: 1)
result.value
#=> {
#     'id'           => 1,
#     'title'        => 'The Silmarillion',
#     'author'       => 'J.R.R. Tolkien',
#     'series'       => nil,
#     'category'     => 'Science Fiction and Fantasy',
#     'published_at' => '1977-09-15'
#   }
```

The `FindOne` command has several options:

- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the singular name of the collection and whose value is the returned entity.

    ```ruby
    result = collection.find_one.call(primary_key: 1, envelope: true)
    result.value
    #=>  { book: {} }
    ```

- The `:scope` keyword allows you to pass a query to the command. Only an entity that match the given scope will be found and returned by `#find_one`.

If the collection does not include an entity with the specified primary key, the `#find_one` command will return a failing result with a `NotFound` error (see [Errors](#errors), below).

##### Insert One

The `InsertOne` command takes an entity and inserts that entity into the collection.

```ruby
book       = { 'id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tammsyn Muir' }
result     = collection.insert_one.call(entity: entity)

result.value
#=> {
#     'id'           => 10,
#     'title'        => 'Gideon the Ninth',
#     'author'       => 'Tammsyn Muir'
#   }

collection.query.where(id: 10).exists?
#=> true
```

If the collection already includes an entity with the specified primary key, the `#insert_one` command will return a failing result with an `AlreadyExists` error (see [Errors](#errors), below).

##### Update One

The `UpdateOne` command takes an entity and updates the corresponding entity in the collection.

```ruby
book   = collection.find_one.call(1).value
book   = book.merge('author' => 'John Ronald Reuel Tolkien')
result = collection.update_one(entity: book)

result.value
#=> {
#     'id'           => 1,
#     'title'        => 'The Silmarillion',
#     'author'       => 'J.R.R. Tolkien',
#     'series'       => nil,
#     'category'     => 'Science Fiction and Fantasy',
#     'published_at' => '1977-09-15'
#   }

collection
  .query
  .where(title: 'The Silmarillion', author: 'John Ronald Reuel Tolkien')
  .exists?
#=> true
```

If the collection does not include an entity with the specified entity's primary key, the `#update_one` command will return a failing result with a `NotFound` error (see [Errors](#errors), below).

##### Validate One

The `ValidateOne` command takes an entity and a `Stannum` contract and matches the entity to the contract. Some implementations allow specifying a default contract, either as a parameter on the collection or as a class property on the entity class; if the collection has a default contract, then the `:contract` keyword is optional.

```ruby
contract = Stannum::Contract.new do
  property :title, Stannum::Constraints::Presence.new
end

book   = { 'id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tammsyn Muir' }
result = collection.validate_one.call(contract: contract, entity: book)
result.success?
#=> true
```

If the contract does not match the entity, the `#validate_one` command will return a failing result with a `ValidationFailed` error (see [Errors](#errors), below).

If the collection does not specify a default contract and no `:contract` keyword is provided, the `#validate_one` command will return a failing result with a `MissingDefaultContract` error.

#### Basic Collection

```
require 'cuprum/collections/basic'
```

The `Cuprum::Basic::Collection` provides a reference implementation of a collection. It uses an in-memory `Array` to store `Hash`es with `String` keys. All of the command examples above use a basic collection as an example.

```ruby
collection = Cuprum::Collections::Basic.new(
  collection_name: 'books',
  data:            book_data,
)
```

Initializing a basic collection requires, at a minumum, the following keywords:

- The `:collection_name` parameter sets the name of the collection. It is used to create an envelope for query commands, such as the `FindMany`, `FindMatching` and `FindOne` commands.
- The `:data` parameter initializes the collection with existing data. The data must be either an empty array or an `Array` of `Hash`es with `String` keys.

You can also specify some optional keywords:

- The `:default_contract` parameter sets a default contract for validating collection entities. If no `:contract` keyword is passed to the `ValidateOne` command, it will use the default contract to validate the entity.
- The `:member_name` parameter is used to create an envelope for singular query commands such as the `FindOne` command. If not given, the member name will be generated automatically as a singular form of the collection name.
- The `:primary_key_name` parameter specifies the attribute that serves as the primary key for the collection entities. The default value is `:id`.
- The `:primary_key_type` parameter specifies the type of the primary key attribute. The default value is `Integer`.

<a id="constraints"></a>

### Constraints

`Cuprum::Collections` defines a small number of `Stannum` constraints for validating command parameters.

**Attribute Name**

A `Cuprum::Collections::Constraints::AttributeName` constraint validates that the object is a valid attribute name. Specifically, that the object either a `String` or a `Symbol` and that it is not `#empty?`.

**Ordering**

A `Cuprum::Collections::Constraints::Ordering` constraint validates that the object is a valid sort ordering. An ordering must be one of the following:

- `nil`
- A valid attribute name, e.g. `title` or `:author`
- An array of valid attribute names, e.g. `['title', 'author']` or `[:series, :publisher]`
- A hash of valid attribute names and sort directions, e.g. `{ title: :descending }`
- An array of valid attribute names, with the last item of the array a hash of valid attribute names and sort directions, e.g. `[:author, :series, { published_at: :ascending }]`

**Sort Direction**

A `Cuprum::Collections::Constraints::Order::SortDirection` constraint validates that the object is a valid sort direction. Specifically, that the object is either a `String` or a `Symbol` and that is has a value of `'asc'`, `'ascending'`, `'desc'`, or `'descending'`.

<a id="errors"></a>

### Errors

`Cuprum::Collections` defines a set of errors to be used in failed command results.

**AlreadyExists**

A `Cuprum::Collections::Errors::AlreadyExists` error is used when an entity already exists in the collection with the given primary key, e.g. in an `InsertOne` command.

It has the following properties:

- `#collection_name`: The name of the collection used in the command.
- `#primary_key_name`: The name of the primary key attribute, e.g. `'id'`.
- `#primary_key_values`: The values of the duplicate primary keys, e.g. `[1]`.

**Extra Attributes**

A `Cuprum::Collections::Errors::ExtraAttributes` error is used when attempting to set attributes on an entity that are not defined for that entity class.

It has the following properties:

- `#entity_class`: The class of the entity used in the command.
- `#extra_attributes`: The names of the invalid attributes that the command attempted to set, as an `Array` of `String`s.
- `#valid_attributes`: The names of the valid attributes for the entity class, as an `Array` of `String`s.

**Failed Validation**

A `Cuprum::Collections::Errors::FailedValidation` error is used when an entity fails validation in a command.

It has the following properties:

- `#entity_class`: The class of the entity used in the command.
- `#errors`: The validation error messages, grouped by the error path.

**Invalid Parameters**

A `Cuprum::Collections::Errors::InvalidParameters` error is used when attempting to call a command with invalid parameters for that command.

It has the following properties:

- `#command`: The command that was called.
- `#errors`: The validation errors for the parameters, as an `Array` of error `Hash`es.

**Invalid Query**

A `Cuprum::Collections::Errors::InvalidQuery` error is used when attempting to call a `FindMatching` command with invalid parameters for the query filter.

It has the following properties:

- `#errors`: The validation error from the parsing strategy, as an `Array` of error `Hash`es.
- `#strategy`: The name of the attempted parsing strategy.

**Missing Default Contract**

A `Cuprum::Collections::Errors::MissingDefaultContract`error is used when attempting to call a validation command without a contract and the collection does not define a default contract.

It has the following properties:

- `#entity_class`: The class of the entity used in the command.

**Not Found**

A `Cuprum::Collections::Errors::NotFound` error is used when an entity with the requested primary key does not exist in the collection.

- `#collection_name`: The name of the collection used in the command.
- `#primary_key_name`: The name of the primary key attribute, e.g. `'id'`.
- `#primary_key_values`: The values of the missing primary keys, e.g. `[1]`.

**Unknown Operator**

A `Cuprum::Collections::Errors::UnknownOperator` error is used when attempting to perform a filter operation with an operator that is either invalid or not implemented by the collection.

It has the following properties:

- `#operator`: The name of the unrecognized operator.

<a id="queries"></a>

### Queries

A `Cuprum::Collections::Query` provides a low-level interface for performing query operations on a collection's data.

```ruby
collection = Cuprum::Collections::Basic.new(
  collection_name: 'books',
  data:            book_data,
)
query      = collection.query

query.class
#=> Cuprum::Collections::Basic::Query
query.count
#=> 10
query.limit(3).to_a
#=> [
#     {
#       'id'           => 0,
#       'title'        => 'The Hobbit',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => nil,
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1937-09-21'
#     },
#     {
#       'id'           => 1,
#       'title'        => 'The Silmarillion',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => nil,
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1977-09-15'
#     },
#     {
#       'id'           => 2,
#       'title'        => 'The Fellowship of the Ring',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => 'The Lord of the Rings',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1954-07-29'
#     }
#   ]
```

Each collection defines its own `Query` implementation, but the interface should be identical except for the class of the yielded or returned entities.

#### Query Methods

Every `Cuprum::Collections::Query` implementation defines the following methods.

**#count**

The `#count` method takes no parameters and returns the number of items in the collection that match the given criteria.

```ruby
query.count
#=> 10
```

**#each**

The `#each` method takes a block and yields to the block each item in the collection that matches the given criteria, in the given order.

```ruby
query.each do |book|
  puts book.title if book.series == 'Earthsea'
end
#=> prints "A Wizard of Earthsea", "The Tombs of Atuan", "The Farthest Shore"
```

**#exists**

The `#exists?` method takes no parameters and returns `true` if there are any items in the collection that match the given criteria, or `false` if there are no matching items.

```ruby
query.exists?
#=> true
query.where({ series: 'The Wheel of Time' }).exists?
#=> false
```

**#limit**

The `#limit` method takes a count of items and returns a copy of the query. The copied query has a limit constraint, and will yield or return up to the requested number of items when called with `#each` or `#to_a`.

```ruby
query.limit(3).to_a
#=> [
#     {
#       'id'           => 0,
#       'title'        => 'The Hobbit',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => nil,
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1937-09-21'
#     },
#     {
#       'id'           => 1,
#       'title'        => 'The Silmarillion',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => nil,
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1977-09-15'
#     },
#     {
#       'id'           => 2,
#       'title'        => 'The Fellowship of the Ring',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => 'The Lord of the Rings',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1954-07-29'
#     }
#   ]
```

*Note:* Not all collections provide a guarantee of a default ordering - for consistent results using `#limit` and `#offset`, specify an explicit order for the query.

**#offset**

The `#offset` method takes a count of items and returns a copy of the query. The copied query has an offset constraint, and will skip the requested number of items when called with `#each` or `#to_a`.

```ruby
query.offset(7)
#=> [
#     {
#       'id'           => 7,
#       'title'        => 'A Wizard of Earthsea',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1968-11-01'
#     },
#     {
#       'id'           => 8,
#       'title'        => 'The Tombs of Atuan',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1970-12-01'
#     },
#     {
#       'id'           => 9,
#       'title'        => 'The Farthest Shore',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1972-09-01'
#     }
#   ]
```

*Note:* Not all collections provide a guarantee of a default ordering - for consistent results using `#limit` and `#offset`, specify an explicit order for the query.

**#order**

The `#order` method takes a valid sort ordering and returns a copy of the query. The copied query uses the specified order, and will yield or return items in that order when called with `#each` or `#to_a`. For details on specifying a sort order, see [Query Ordering](#queries-ordering), below.

```ruby
query.where(series: 'The Lord of the Rings').order({ title: 'desc' })
#=> [
#     {
#       'id'           => 3,
#       'title'        => 'The Two Towers',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => 'The Lord of the Rings',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1954-11-11'
#     },
#     {
#       'id'           => 4,
#       'title'        => 'The Return of the King',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => 'The Lord of the Rings',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1955-10-20'
#     },
#     {
#       'id'           => 2,
#       'title'        => 'The Fellowship of the Ring',
#       'author'       => 'J.R.R. Tolkien',
#       'series'       => 'The Lord of the Rings',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1954-07-29'
#     }
#   ]
```

**#reset**

The `#reset` method takes no parameters and returns the query. By default, a `Query` will cache the results when calling `#each` or `#to_a`. The `#reset` method clears this cache and forces the query to perform another query on the underlying data.

```ruby
query.count
#=> 10

book = { id: 10, title: 'Gideon the Ninth', author: 'Tammsyn Muir' }
collection.insert_one.call(entity: book)

query.count
#=> 10
query.reset.count
#=> 11
```

**#to_a**

The `#to_a` method takes no parameters and returns an `Array` containing the itmes in the collection that match the given criteria, in the given order.

```ruby
query.to_a.map { |book| book['title'] }
#=> [
#     'The Hobbit',
#     'The Silmarillion',
#     'The Fellowship of the Ring',
#     'The Two Towers',
#     'The Return of the King',
#     'The Word for World is Forest',
#     'The Ones Who Walk Away From Omelas',
#     'A Wizard of Earthsea',
#     'The Tombs of Atuan',
#     'The Farthest Shore'
#   ]
```

**#where**

The `#where` method takes a Hash argument or a block and returns a copy of the query. The copied query applies the given filters, and will yield or return only items that match the given criteria when called with `#each` or `#to_a`.

```ruby
query.where(series: 'Earthsea').to_a
#=> [
#     {
#       'id'           => 7,
#       'title'        => 'A Wizard of Earthsea',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1968-11-01'
#     },
#     {
#       'id'           => 8,
#       'title'        => 'The Tombs of Atuan',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1970-12-01'
#     },
#     {
#       'id'           => 9,
#       'title'        => 'The Farthest Shore',
#       'author'       => 'Ursula K. LeGuin',
#       'series'       => 'Earthsea',
#       'category'     => 'Science Fiction and Fantasy',
#       'published_at' => '1972-09-01'
#     }
#   ]
```

<a id="queries-ordering"></a>

#### Query Ordering

You can set the sort order of returned or yielded query results by passing a valid ordering to the query. For a `FindMatching` command, pass an `:order` keyword to `#call`. When using a query directly, use the `#order` method.

Any of the following is a valid ordering:

- `nil`
- A valid attribute name, e.g. `title` or `:author`
- An array of valid attribute names, e.g. `['title', 'author']` or `[:series, :publisher]`
- A hash of valid attribute names and sort directions, e.g. `{ title: :descending }`
- An array of valid attribute names, with the last item of the array a hash of valid attribute names and sort directions, e.g. `[:author, :series, { published_at: :ascending }]`

Internally, the sort order is converted to an ordered `Hash` with attribute name keys and sort direction values. The query results will be sorted by the given attributes in the specified order.

For example, a order of `{ author: :asc, title: :descending }` will sort the results by `:author` in ascending order. For each author, the results are then sorted by `:title` in descending order.

<a id="queries-filtering"></a>

#### Query Filtering

You can filter the results returned or yielded by a query by passing a valid criteria object to the query. For a `FindMatching` command, pass a `:where` keyword to `#call`, or use the block form to use the query builder to apply advanced operators. When using a query directly, use the `#where` method.

```ruby
query = collection.query.where({ author: 'Ursula K. LeGuin' })
query.count
#=> 5
query.each.map(&:author).uniq
#=> ['Ursula K. LeGuin']
```

The simplest way to filter results is by passing a `Hash` to `#where`. The keys of the Hash should be the names of the attributes to filter by, and the values the expected value of that attribute. However, passing a Hash directly only supports equality comparisons. To use advanced operators, use the block form:

```ruby
query = collection.query.where do
  {
    author:       'Ursula K. LeGuin',
    series:       equal('Earthsea'),
    published_at: greater_than('1970-01-01')
  }
end
query.count
#=> 2
query.each.map(&:title)
#=> [
#     'The Tombs of Atuan',
#     'The Farthest Shore'
#   ]
```

Instead of passing a `Hash` directly, we pass a block to the `#where` method (or `#call` for a command) that *returns* a `Hash`. This allows us to use a Domain-Specific Language to generate our criteria. In the example above, we are using an exact value for the author - this is automatically converted to an `#equal` criterion, just as it is when passing a Hash. We are also using the `#greater_than` operator to filter our results.

##### Operators

Each query implementation defines the following operators:

**#equal**

The `#equal` operator asserts that the attribute value is equal to the expected value.

```ruby
query = collection.query.where do
  { title: equal('The Hobbit') }
end
query.count
#=> 1
query.each.map(&:title)
#=> ['The Hobbit']
```

**#greater_than**

The `#greater_than` operator asserts that the attribute value is strictly greater than the expected value. It is primarily used with numeric or date/time attributes.

```ruby
query = collection.query.where do
  {
    series:       'The Lord of the Rings',
    published_at: greater_than('1954-11-11')
  }
end
query.count
#=> 1
query.each.map(&:title)
#=> ['The Return of the King']
```

**#greater_than_or_equal_to**

The `#greater_than_or_equal_to` operator asserts that the attribute value is greater than or equal to the expected value. It is primarily used with numeric or date/time attributes.

```ruby
query = collection.query.where do
  {
    series:       'The Lord of the Rings',
    published_at: greater_than_or_equal_to('1954-11-11')
  }
end
query.count
#=> 2
query.each.map(&:title)
#=> ['The Two Towers', 'The Return of the King']
```

**#less_than**

The `#less_than` operator asserts that the attribute value is strictly greater than the expected value. It is primarily used with numeric or date/time attributes.

```ruby
query = collection.query.where do
  {
    series:       'The Lord of the Rings',
    published_at: less_than('1954-11-11')
  }
end
query.count
#=> 1
query.each.map(&:title)
#=> ['The Fellowship of the Ring']
```

**#less_than_or_equal_to**

The `#less_than_or_equal_to` operator asserts that the attribute value is strictly greater than the expected value. It is primarily used with numeric or date/time attributes.

```ruby
query = collection.query.where do
  {
    series:       'The Lord of the Rings',
    published_at: less_than_or_equal_to('1954-11-11')
  }
end
query.count
#=> 2
query.each.map(&:title)
#=> ['The Fellowship of the Ring', 'The Two Towers']
```

**#not_equal**

The `#not_equal` operator asserts that the attribute value is not equal to the expected value. It is the inverse of the `#equal` operator.

```ruby
query = collection.query.where do
  {
    author: 'J.R.R. Tolkien',
    series: not_equal('The Lord of the Rings')
  }
end
query.count
#=> 2
query.each.map(&:title)
#=> ['The Hobbit', 'The Silmarillion']
```

**#not_one_of**

The `#one_of` operator asserts that the attribute value is not equal to any of the expected values. It is the inverse of the `#one_of` operator.

```ruby
query = collection.query.where do
  {
    series: not_one_of(['Earthsea', 'The Lord of the Rings'])
  }
end
query.count
#=> 4
query.each.map(&:title)
#=> [
#     'The Hobbit',
#     'The Silmarillion',
#     'The Word for World is Forest',
#     'The Ones Who Walk Away From Omelas'
#   ]
```

**#one_of**

The `#one_of` operator asserts that the attribute value is equal to one of the expected values.

```ruby
query = collection.query.where do
  {
    series: one_of(['Earthsea', 'The Lord of the Rings'])
  }
end
query.count
#=> 6
query.each.map(&:title)
#=> [
#     'The Fellowship of the Ring',
#     'The Two Towers',
#     'The Return of the King',
#     'A Wizard of Earthsea',
#     'The Tombs of Atuan',
#     'The Farthest Shore'
#   ]
```

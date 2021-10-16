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
- **Data Mapping:** The `Cuprum::Collections` approach to data is much closer to the [Data Mapper pattern](https://en.wikipedia.org/wiki/Data_mapper_pattern) than the [Active Record pattern](https://en.wikipedia.org/wiki/Active_record_pattern), which allows it to avoid some of the pitfalls of the latter approach.

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

*A Note on Terminology:* Because a collection can represent any sort of data, from a raw Ruby Hash to an ORM record, the term used to indicate "one item in the collection" is an *entity*. Likewise, the class of the items in the collection is the *entity_class*. In our example above, our entities are books, and the entity class is Hash.

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

@todo

<a id="errors"></a>

### Errors

@todo

<a id="queries"></a>

### Queries

@todo

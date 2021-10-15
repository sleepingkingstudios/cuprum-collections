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

@todo

<a id="commands"></a>

#### Commands

@todo

<a id="constraints"></a>

### Constraints

@todo

<a id="errors"></a>

### Errors

@todo

<a id="queries"></a>

### Queries

@todo

# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Sample data for validating collection implementations.
  BOOKS_FIXTURES = [
    {
      'id'           => 0,
      'title'        => 'The Hobbit',
      'author'       => 'J.R.R. Tolkien',
      'series'       => nil,
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1937-09-21'
    },
    {
      'id'           => 1,
      'title'        => 'The Silmarillion',
      'author'       => 'J.R.R. Tolkien',
      'series'       => nil,
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1977-09-15'
    },
    {
      'id'           => 2,
      'title'        => 'The Fellowship of the Ring',
      'author'       => 'J.R.R. Tolkien',
      'series'       => 'The Lord of the Rings',
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1954-07-29'
    },
    {
      'id'           => 3,
      'title'        => 'The Two Towers',
      'author'       => 'J.R.R. Tolkien',
      'series'       => 'The Lord of the Rings',
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1954-11-11'
    },
    {
      'id'           => 4,
      'title'        => 'The Return of the King',
      'author'       => 'J.R.R. Tolkien',
      'series'       => 'The Lord of the Rings',
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1955-10-20'
    },
    {
      'id'           => 5,
      'title'        => 'The Word for World is Forest',
      'author'       => 'Ursula K. LeGuin',
      'series'       => nil,
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1972-03-13'
    },
    {
      'id'           => 6,
      'title'        => 'The Ones Who Walk Away From Omelas',
      'author'       => 'Ursula K. LeGuin',
      'series'       => nil,
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1973-10-01'
    },
    {
      'id'           => 7,
      'title'        => 'A Wizard of Earthsea',
      'author'       => 'Ursula K. LeGuin',
      'series'       => 'Earthsea',
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1968-11-01'
    },
    {
      'id'           => 8,
      'title'        => 'The Tombs of Atuan',
      'author'       => 'Ursula K. LeGuin',
      'series'       => 'Earthsea',
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1970-12-01'
    },
    {
      'id'           => 9,
      'title'        => 'The Farthest Shore',
      'author'       => 'Ursula K. LeGuin',
      'series'       => 'Earthsea',
      'category'     => 'Science Fiction and Fantasy',
      'published_at' => '1972-09-01'
    }
  ].map(&:freeze).freeze
end

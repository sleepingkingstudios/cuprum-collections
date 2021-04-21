# frozen_string_literal: true

require 'cuprum/collections/rspec'

module Cuprum::Collections::RSpec
  # Sample data for validating collection implementations.
  BOOKS_FIXTURES = [
    {
      'id'       => 0,
      'title'    => 'The Hobbit',
      'author'   => 'J.R.R. Tolkien',
      'series'   => nil,
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 1,
      'title'    => 'The Silmarillion',
      'author'   => 'J.R.R. Tolkien',
      'series'   => nil,
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 2,
      'title'    => 'The Fellowship of the Ring',
      'author'   => 'J.R.R. Tolkien',
      'series'   => 'The Lord of the Rings',
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 3,
      'title'    => 'The Two Towers',
      'author'   => 'J.R.R. Tolkien',
      'series'   => 'The Lord of the Rings',
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 4,
      'title'    => 'The Return of the King',
      'author'   => 'J.R.R. Tolkien',
      'series'   => 'The Lord of the Rings',
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 5,
      'title'    => 'The Word for World is Forest',
      'author'   => 'Ursula K. LeGuin',
      'series'   => nil,
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 6,
      'title'    => 'The Ones Who Walk Away From Omelas',
      'author'   => 'Ursula K. LeGuin',
      'series'   => nil,
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 7,
      'title'    => 'A Wizard of Earthsea',
      'author'   => 'Ursula K. LeGuin',
      'series'   => 'Earthsea',
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 8,
      'title'    => 'The Tombs of Atuan',
      'author'   => 'Ursula K. LeGuin',
      'series'   => 'Earthsea',
      'category' => 'Science Fiction and Fantasy'
    },
    {
      'id'       => 9,
      'title'    => 'The Farthest Shore',
      'author'   => 'Ursula K. LeGuin',
      'series'   => 'Earthsea',
      'category' => 'Science Fiction and Fantasy'
    }
  ].map(&:freeze).freeze
end

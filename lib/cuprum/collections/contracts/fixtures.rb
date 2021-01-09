# frozen_string_literal: true

require 'cuprum/collections/contracts'

module Cuprum::Collections::Contracts
  # Sample data for validating collection implementations.
  BOOKS_FIXTURES = [
    {
      title:  'The Hobbit',
      author: 'J.R.R. Tolkien',
      series: nil
    },
    {
      title:  'The Silmarillion',
      author: 'J.R.R. Tolkien',
      series: nil
    },
    {
      title:  'The Fellowship of the Ring',
      author: 'J.R.R. Tolkien',
      series: 'The Lord of the Rings'
    },
    {
      title:  'The Two Towers',
      author: 'J.R.R. Tolkien',
      series: 'The Lord of the Rings'
    },
    {
      title:  'The Return of the King',
      author: 'J.R.R. Tolkien',
      series: 'The Lord of the Rings'
    },
    {
      title:  'The Word for World is Forest',
      author: 'Ursula K. LeGuin',
      series: nil
    },
    {
      title:  'The Ones Who Walk Away From Omelas',
      author: 'Ursula K. LeGuin',
      series: nil
    },
    {
      title:  'A Wizard of Earthsea',
      author: 'Ursula K. LeGuin',
      series: 'Earthsea'
    },
    {
      title:  'The Tombs of Atuan',
      author: 'Ursula K. LeGuin',
      series: 'Earthsea'
    },
    {
      title:  'The Farthest Shore',
      author: 'Ursula K. LeGuin',
      series: 'Earthsea'
    }
  ].map(&:freeze).freeze
end

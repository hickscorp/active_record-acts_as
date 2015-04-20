# ActiveRecord::ActsAs

This is a refactor of [`acts_as_relation`](https://github.com/hzamani/active_record-acts_as), adding support to several calls to `acts_as` from a single model.

Simulates multiple-table-inheritance (MTI) for ActiveRecord models.
By default, ActiveRecord only supports single-table inheritance (STI).
MTI gives you the benefits of STI but without having to place dozens of empty fields into a single table.


## Requirements

`AciveRecord ~> 4.1.2` or newest

## Installation

Add this line to your application's Gemfile:

    gem 'active_record-acts_as',  github: 'hickscorp/active_record-acts_as'

And then execute:

    $ bundle

## Contributing

1. Fork it ( https://github.com/hickscorp/active_record-acts_as/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Test changes don't break anything (`rspec`)
4. Add specs for your new feature
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a new Pull Request

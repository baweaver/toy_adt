# ToyAdt

A toy implementation of Algebraic Data Types for use in "Ruby in FantasyLand". As much as possible I'll try and hold to the public API, and may switch into DryRB later depending on a few factors, but this works for an initial release.

Now, as to what this gem does...

## Type: Sorbet-aware structs with pattern matching

Types are based on Sorbet's `T::Struct` with constant properties and Ruby 2.7+ pattern matching awareness built in. It should be noted that all `sum` types use this structure behind the scenes as well.

Let's say we had a coordinate:

```ruby
Coord = ToyAdt.type(x: Integer, y: Integer, z: Integer)

center = Coord.new(x: 0, y: 0, z: 0) # valid
invalid = Coord.new(x: 0, y: 0, z: "INVALID") # invalid: TypeError
```

We can mix Ruby types and Sorbet-aware types (`T::Array[]` and such), and may expand this later to have awareness of DryRB-style types.

We can also add methods to these types:

```ruby
Coord = ToyAdt.type(x: Integer, y: Integer, z: Integer) do
  def translate(x: 0, y: 0, z: 0)
    self.class.new(x: @x + x, y: @y + y, z: @z + z)
  end
end
```

Remember: These types are immutable constants, hence returning a new object.

## Sum: Sum-types with exhaustive matching required

Sum represents sum types, which are composite structures representing similar data, like say a shape:

```ruby
Shape = ToyAdt.sum(
  circle: { radius: Integer, center: Coord },
  square: { top_left: Coord, bottom_right: Coord }
)
```

...and like the type above, we can also add methods here:

```ruby
Shape = ToyAdt.sum(
  circle: { radius: Integer, center: Coord },
  square: { top_left: Coord, bottom_right: Coord }
) do
  def translate(x: 0, y: 0, z: 0)
    case self
    when Shape::Circle
      Shape::Circle.new(radius:, center: center.translate(x:, y:, z:))
    when Shape::Square
      Shape::Square.new(
        top_left: top_left.translate(x:, y:, z:),
        bottom_right: bottom_right.translate(x:, y:, z:)
      )
    else
      T.absurd(self)
    end
  end
end
```

For the moment I'm using `T.absurd` for pattern matching, but this is aware of Ruby 2.7+ pattern matching syntax as well. There's a case to be made for a more restrictive pattern matching syntax which I may evaluate later, but will leave be for now.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'toy_adt'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install toy_adt

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/baweaver/toy_adt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/baweaver/toy_adt/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ToyAdt project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/baweaver/toy_adt/blob/main/CODE_OF_CONDUCT.md).

# :flags: Flagship :ship:

Ship/unship features using flags defined with declarative DSL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flagship'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flagship

## Usage

### Define and use a flagset

```rb
Flagship.define :app do
  enable  :stable_feature
  enable  :experimental_feature, if: ->(context) { context.current_user.staff? }
  disable :deprecate_feature
end

Flagship.set_flagset(:app)
```

### Branch with a flag

```rb
if Flagship.enabled?(:some_feature)
  # Implement the feature here
end
```

### Set context variables

Both of below can be called as `context.foo` from `:if` block.

```rb
# Set a value
Flagship.set_context :foo, 'FOO'

# Set a lambda
Flagship.set_context :foo, ->(context) { 'FOO' }
```

Or you can set a method too.

```rb
Flagship.set_method :current_user, method(:current_user)
```

### Extend flagset

```rb
Flagship.define :common do
  enable :stable_feature
end

Flagship.define :development, extend: :common do
  enable :experimental_feature
end

Flagship.define :production, extend: :common do
  disable :experimental_feature
end

if Rails.env.production?
  Flagset.set_flagset(:production)
else
  Flagset.set_flagset(:development)
end
```

### Override flag with ENV

You can override flags with ENV named `FLAG_***`.

Assuming that there is a flag `:foo`, you can override it with ENV `FLAGSHIP_FOO=1`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuya-takeyama/flagship.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

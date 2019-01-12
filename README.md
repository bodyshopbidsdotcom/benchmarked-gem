# Benchmarked

This gem allows you to benchmark the running time of methods in ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'benchmarked'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install benchmarked
```

Create a notifier in your application
```ruby
class BenchmarkedNotifier
  def self.benchmark_taken(measurement, obj, method_name, args, result)
    # Log measurement to your logging service
  end
end
```
- `measurement`: The result of `Benchmark.measure`
- `obj`: The object that received the `method_name` call
- `method_name`: The name of the method executed on `obj`
- `args`: The arguments passed to the method invocation
- `result`: The return value of the method invocation


Configure `Benchmarked` so that it uses the notifier. If you're using `rails`, this would live in `config/initializers/benchmarked.rb`
```ruby
Benchmarked.configure do |config|
  config.notifier = BenchmarkedNotifier
end
```

## Usage

Add `handle_with_benchmark` after your method definitions so that every call to them triggers a call to `benchmark_taken` on the notifier configured in `Benchmarked`.

For example, let's say that you have this class:
```ruby
class SomeBusinessClass
  def business_method(arg1)
    # perform business logic
  end
  handle_with_benchmark :business_method
end
```

Because `handle_with_benchmark :business_method` is specified, a call like this:
```ruby
SomeBusinessClass.new.business_method
```
Will trigger a call to `BenchmarkedNotifier.benchmark_taken`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bodyshopbidsdotcom/benchmarked-gem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Benchmarked project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/benchmarked/blob/master/CODE_OF_CONDUCT.md).

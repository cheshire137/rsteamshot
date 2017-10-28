# Rsteamshot

Rsteamshot is a Ruby gem for getting the latest screenshots a user has uploaded to their Steam profile, as well as the latest screenshots uploaded for a particular game.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rsteamshot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rsteamshot

## Usage

```ruby
steam_user_name = 'cheshire137'
user = Rsteamshot::User.new(steam_user_name)
screenshots = user.screenshots

# Basic information is fetched for each screenshot initially:
screenshots.each do |screenshot|
  puts screenshot.title
  puts screenshot.details_url
end

newest_screenshot = screenshots.first
newest_screenshot.get_details # Fetch additional details

puts newest_screenshot.full_size_url
puts newest_screenshot.medium_url
puts newest_screenshot.user_name
puts newest_screenshot.user_url
puts newest_screenshot.date
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

[Bug reports](https://github.com/cheshire137/rsteamshot/issues) and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

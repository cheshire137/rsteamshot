# Rsteamshot

[![Build Status](https://travis-ci.org/cheshire137/rsteamshot.svg?branch=master)](https://travis-ci.org/cheshire137/rsteamshot)

Rsteamshot is a Ruby gem for getting the latest screenshots a user has uploaded to their Steam profile, as well as the latest screenshots uploaded for a particular game.

[View source on GitHub](https://github.com/cheshire137/rsteamshot)

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
# Get screenshots uploaded by a Steam user:
steam_user_name = 'cheshire137'
user = Rsteamshot::User.new(steam_user_name, per_page: 10)
order = 'newestfirst' # also: score, oldestfirst
screenshots = user.screenshots(order: order)
screenshots += user.screenshots(order: order, page: 2)

# Find a Steam app by name:
apps_path = 'apps-list.json'
Rsteamshot::App.download_apps_list(apps_path)
apps = Rsteamshot::App.search('witcher 3', apps_path)
app = apps.first

# Filter a user's screenshots to those for a particular app:
alice_screenshots = user.screenshots(app_id: '19680')

# Initialize an app directly if you know its ID:
app_id = '377160'
app = Rsteamshot::App.new(id: app_id, per_page: 10)

# Get screenshots uploaded for a Steam game:
order = 'mostrecent' # also: toprated, trendday, trendweek, trendthreemonths, trendsixmonths,
                     # trendyear
screenshots = app.screenshots(order: order)
screenshots += app.screenshots(order: order, page: 2)

# Search an app's screenshots:
dog_screenshots = app.screenshots(query: 'dog', order: 'trendweek')

# Data available for each screenshot:
screenshots.each do |screenshot|
  screenshot.title
  # => "Lovely sunset in Toussaint"

  screenshot.details_url
  # => "http://steamcommunity.com/sharedfiles/filedetails/?id=737284878"

  screenshot.full_size_url
  # => "https://steamuserimages-a.akamaihd.net/ugc/1621679306978373648/FACBF0285AFB413467E0E76371E8796D8E8C263D/"

  screenshot.medium_url
  # => "https://steamuserimages-a.akamaihd.net/ugc/1621679306978373648/FACBF0285AFB413467E0E76371E8796D8E8C263D/?interpolation=lanczos-none&output-format=jpeg&output-quality=95&fit=inside|1024:576&composite-to%3D%2A%2C%2A%7C1024%3A576&background-color=black"

  screenshot.user_name
  # => "cheshire137"

  screenshot.user_url
  # => "http://steamcommunity.com/id/cheshire137"

  screenshot.date
  # => #<DateTime: 2016-08-03T20:54:00+00:00 ((2457604j,75240s,0n),+0s,2299161j)>

  screenshot.file_size
  # => "0.367 MB"

  screenshot.width
  # => 1920

  screenshot.height
  # => 1080

  screenshot.like_count
  # => 327

  screenshot.comment_count
  # => 71

  # Utility methods:
  screenshot.to_h
  # => {:details_url=>"http://steamcommunity.com/sharedfiles/filedetails/?id=737284878", :title=>...

  screenshot.to_json
  # => "{\n  \"details_url\": \"http://steamcommunity.com/sharedfiles/filedetails/?id=737284878\",
end
```

## Development

After checking out [the repo](https://github.com/cheshire137/rsteamshot), run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

[Bug reports](https://github.com/cheshire137/rsteamshot/issues) and pull requests are welcome. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

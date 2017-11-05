# Change Log

## 0.1.3

- Add ability to get an app from a screenshot via the `Rsteamshot::Screenshot#app` method.
- Specify the path to the Steam apps list file in gem-wide configuration block, instead of passing it into individual methods.
- Add `Rsteamshot::App#find_by_name` to get the best match for an app based on the provided name. For example, passing "oblivion" will return the app named "The Elder Scrolls IV: Oblivion".
- Add `Rsteamshot::Screenshot#file_size_in_bytes` to get an integer value for how large a screenshot is, in bytes. Thanks [@marcqualie](https://github.com/marcqualie)!
- Add `Rsteamshot::App#to_h` and `Rsteamshot::App#to_json` to get hash and JSON representations of apps.
- Remove the need to manually call `Rsteamshot::App#download_apps_list`. It will now automatically be called when `Rsteamshot::App#search` and similar methods are called.

## 0.1.2

Improve the gem description and set the link to its homepage in the gemspec.

## 0.1.1

Minor bump just to remove the restriction from the gemspec that prevented the gem from being published to rubygems.org.

## 0.1.0

List a user's screenshots they have publicly uploaded to Steam. Filter user screenshots by Steam app. Also list screenshots taken in a particular Steam app. Can search an app's screenshots. Can sort screenshots by popularity or upload date.

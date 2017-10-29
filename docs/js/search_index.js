var search_data = {"index":{"searchIndex":["rsteamshot","app","badappsfile","screenshot","screenshotpage","screenshotpaginator","user","download_apps_list()","fetch()","includes_screenshot?()","new()","new()","new()","new()","new()","screenshots()","screenshots()","screenshots()","search()","to_h()","to_json()","readme"],"longSearchIndex":["rsteamshot","rsteamshot::app","rsteamshot::app::badappsfile","rsteamshot::screenshot","rsteamshot::screenshotpage","rsteamshot::screenshotpaginator","rsteamshot::user","rsteamshot::app::download_apps_list()","rsteamshot::screenshotpage#fetch()","rsteamshot::screenshotpage#includes_screenshot?()","rsteamshot::app::new()","rsteamshot::screenshot::new()","rsteamshot::screenshotpage::new()","rsteamshot::screenshotpaginator::new()","rsteamshot::user::new()","rsteamshot::app#screenshots()","rsteamshot::screenshotpaginator#screenshots()","rsteamshot::user#screenshots()","rsteamshot::app::search()","rsteamshot::screenshot#to_h()","rsteamshot::screenshot#to_json()",""],"info":[["Rsteamshot","","Rsteamshot.html","","<p>Contains classes for finding screenshots uploaded by users to Steam.\nScreenshots are from Steam games …\n"],["Rsteamshot::App","","Rsteamshot/App.html","","<p>Represents a Steam app, like a video game. Used to fetch the screenshots\nthat were taken in that app …\n"],["Rsteamshot::App::BadAppsFile","","Rsteamshot/App/BadAppsFile.html","","<p>Exception thrown by Rsteamshot::App#search when the given file is not a\nvalid file containing Steam apps. …\n"],["Rsteamshot::Screenshot","","Rsteamshot/Screenshot.html","","<p>Represents an image that has been uploaded to Steam of a screenshot taken\nin a Steam app.\n"],["Rsteamshot::ScreenshotPage","","Rsteamshot/ScreenshotPage.html","","<p>Represents a page of screenshots on Steam.\n"],["Rsteamshot::ScreenshotPaginator","","Rsteamshot/ScreenshotPaginator.html","","<p>Use to paginate screenshots fetched from Steam in chunks of fewer than 50\nper page.\n"],["Rsteamshot::User","","Rsteamshot/User.html","","<p>Represents a Steam user. Used to fetch the user&#39;s screenshots they have\nuploaded to Steam.\n"],["download_apps_list","Rsteamshot::App","Rsteamshot/App.html#method-c-download_apps_list","(path)","<p>Writes a JSON file at the given location with the latest list of apps on\nSteam.\n<p>path &mdash; a String file path …\n\n"],["fetch","Rsteamshot::ScreenshotPage","Rsteamshot/ScreenshotPage.html#method-i-fetch","(base_url)","<p>Fetch the contents of this page from Steam.\n<p>Returns\n<p>Returns a Mechanize::Page.\n"],["includes_screenshot?","Rsteamshot::ScreenshotPage","Rsteamshot/ScreenshotPage.html#method-i-includes_screenshot-3F","(screenshot_number)","<p>Check if the nth screenshot would be on this page on Steam.\n<p>screenshot_number &mdash; the index of the screenshot …\n\n"],["new","Rsteamshot::App","Rsteamshot/App.html#method-c-new","(attrs = {})","<p>Initialize a Steam app with the given attributes.\n<p>attrs &mdash; the Hash of attributes for this app\n<p>:id &mdash; the String …\n"],["new","Rsteamshot::Screenshot","Rsteamshot/Screenshot.html#method-c-new","(attrs = {})","<p>Initialize a screenshot with the given attributes.\n<p>attrs &mdash; the Hash of attributes for this screenshot\n<p>:title … &mdash; "],["new","Rsteamshot::ScreenshotPage","Rsteamshot/ScreenshotPage.html#method-c-new","(number, steam_per_page)","<p>Construct a new ScreenshotPage with the given page number.\n<p>number &mdash; the page number; Integer\n<p>steam_per_page … &mdash; "],["new","Rsteamshot::ScreenshotPaginator","Rsteamshot/ScreenshotPaginator.html#method-c-new","(process_html, max_per_page)","<p>Construct a new ScreenshotPaginator that will process a page of HTML using\nthe given lambda.\n<p>process_html … &mdash; "],["new","Rsteamshot::User","Rsteamshot/User.html#method-c-new","(user_name)","<p>Initialize a Steam user with the given user name.\n<p>user_name &mdash; a String\n\n"],["screenshots","Rsteamshot::App","Rsteamshot/App.html#method-i-screenshots","(order: nil)","<p>Fetch a list of the newest uploaded screenshots for this app on Steam.\n<p>order &mdash; String specifying which screenshots …\n\n"],["screenshots","Rsteamshot::ScreenshotPaginator","Rsteamshot/ScreenshotPaginator.html#method-i-screenshots","(page: 1, per_page: 10, url:)","<p>Get the specified number of screenshots from the given Steam URL.\n<p>page &mdash; which page of results to fetch; …\n"],["screenshots","Rsteamshot::User","Rsteamshot/User.html#method-i-screenshots","(order: nil, page: 1, per_page: 10)","<p>Fetch a list of the user&#39;s newest uploaded screenshots.\n<p>order &mdash; String specifying which screenshots …\n"],["search","Rsteamshot::App","Rsteamshot/App.html#method-c-search","(raw_query, apps_list_path)","<p>Find Steam apps by name.\n<p>raw_query &mdash; a String search query for an app or game on Steam\n<p>apps_list_path &mdash; a  …\n"],["to_h","Rsteamshot::Screenshot","Rsteamshot/Screenshot.html#method-i-to_h","()","<p>Get a hash representation of this screenshot.\n<p>Returns\n<p>Returns a Hash.\n"],["to_json","Rsteamshot::Screenshot","Rsteamshot/Screenshot.html#method-i-to_json","()","<p>Get a JSON representation of this screenshot.\n<p>Returns\n<p>Returns a String.\n"],["README","","README_md.html","","<p>Rsteamshot\n<p><img src=\"https://travis-ci.org/cheshire137/rsteamshot.svg?branch=master\">\n<p>Rsteamshot is a  …\n"]]}}
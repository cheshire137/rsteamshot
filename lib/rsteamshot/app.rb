module Rsteamshot
  # Public: Represents a Steam app, like a video game. Used to fetch the screenshots
  # that were taken in that app that Steam users have uploaded.
  class App
    # Public: Exception thrown when the configured `apps_list_path` is not a valid file containing
    # Steam apps.
    class BadAppsFile < StandardError; end

    # Public: Exception thrown when there is no file path configured for saving the list of Steam
    # apps, or it is a bad path.
    class BadConfiguration < StandardError; end

    # Public: You can fetch this many screenshots at once.
    MAX_PER_PAGE = 50

    # Public: The API URL to get a list of apps on Steam.
    APPS_LIST_URL = 'http://api.steampowered.com/ISteamApps/GetAppList/v2'

    # Public: How to sort screenshots when they are being retrieved.
    VALID_ORDERS = %w[mostrecent toprated trendday trendweek trendthreemonths
                      trendsixmonths trendyear].freeze

    # Public: Returns the ID of the Steam app as an Integer or String.
    attr_reader :id

    # Public: Returns the String name of the Steam app, or nil.
    attr_reader :name

    # Public: Returns the number of screenshots that will be fetched per page for this app.
    attr_reader :per_page

    # Public: Writes a JSON file at the location specified in `Rsteamshot.configuration` with the
    # latest list of apps on Steam. Will be automatically called by #list.
    #
    # Returns nothing.
    def self.download_apps_list
      path = Rsteamshot.configuration.apps_list_path

      unless path && path.length > 0
        raise BadConfiguration, 'no path configured for JSON apps list from Steam'
      end

      File.open(path, 'w') do |file|
        IO.copy_stream(open(APPS_LIST_URL), file)
      end
    end

    # Public: Force the list of Steam apps to be re-downloaded the next time #list is called.
    def self.reset_list
      @@list = nil
    end

    # Public: Read the JSON file configured in `apps_list_path` and get a list of Steam apps. Will
    # download the latest list of Steam apps to `apps_list_path` if the file does not already exist.
    #
    # Returns an Array of Hashes for all the Steam apps.
    def self.list
      @@list ||= begin
        path = Rsteamshot.configuration.apps_list_path
        unless path
          raise BadAppsFile, 'no path configured for JSON apps list from Steam'
        end

        download_apps_list unless File.file?(path)
        raise BadAppsFile, "#{path} is not a file" unless File.file?(path)

        json = begin
          JSON.parse(File.read(path))
        rescue JSON::ParserError
          raise BadAppsFile, "#{path} is not a valid JSON file"
        end

        applist = json['applist']
        raise BadAppsFile, "#{path} does not have expected JSON format" unless applist

        apps = applist['apps']
        raise BadAppsFile, "#{path} does not have expected JSON format" unless apps

        apps
      end
    end

    # Public: Find Steam apps by name.
    #
    # raw_query - a String search query for an app or game on Steam
    #
    # Returns an Array of Rsteamshot::Apps.
    def self.search(raw_query)
      return [] unless raw_query

      query = raw_query.downcase
      results = []
      list.each do |data|
        next unless data['name']

        if data['name'].downcase.include?(query)
          results << new(id: data['appid'], name: data['name'])
        end
      end

      results
    end

    # Public: Find a Steam app by its name, case insensitive.
    #
    # name - the String name of a game or other app on Steam
    #
    # Returns an Rsteamshot::App or nil.
    def self.find_by_name(name)
      apps = search(name)
      return if apps.length < 1

      exact_match = apps.detect { |app| app.name.downcase == name }
      return exact_match if exact_match

      app = apps.shift
      app = apps.shift while app.name.downcase =~ /\btrailer\b/ && apps.length > 0
      app
    end

    # Public: Find a Steam app by its ID.
    #
    # id - the String or Integer ID of a game or other app on Steam
    #
    # Returns an Rsteamshot::App or nil.
    def self.find_by_id(id)
      id = id.to_i
      app_data = list.detect { |data| data['appid'] == id }
      new(id: app_data['appid'], name: app_data['name']) if app_data
    end

    # Public: Initialize a Steam app with the given attributes.
    #
    # attrs - the Hash of attributes for this app
    #         :id - the String or Integer app ID
    #         :name - the String name of the app
    #         :per_page - how many results to get in each page; defaults to 10; valid range: 1-50;
    #                     Integer
    def initialize(attrs = {})
      attrs.each { |key, value| instance_variable_set("@#{key}", value) }
      @per_page ||= 10
      initialize_paginator
    end

    # Public: Check if this App is equivalent to another object.
    #
    # Returns true if the given object represents the same Steam app.
    def ==(other)
      other.class == self.class && other.id == id && other.name == name
    end

    # Public: Fetch a list of the newest uploaded screenshots for this app on Steam.
    #
    # order - String specifying which screenshots should be retrieved; choose from mostrecent,
    #         toprated, trendday, trendweek, trendthreemonths, trendsixmonths, and trendyear;
    #         defaults to mostrecent
    # page - which page of results to fetch; defaults to 1; Integer
    # query - a String of text for searching screenshots
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(order: nil, page: 1, query: nil)
      return [] unless id

      url = steam_url(order, query, @paginator.per_page)
      @paginator.screenshots(page: page, url: url)
    end

    # Public: Get a hash representation of this app.
    #
    # Returns a Hash.
    def to_h
      result = { id: id }
      result[:name] = name if name
      result
    end

    # Public: Get a JSON representation of this app.
    #
    # Returns a String.
    def to_json
      JSON.pretty_generate(to_h)
    end

    # Public: Set how many screenshots should be fetched at a time for this app.
    #
    # value - an Integer
    #
    # Returns nothing.
    def per_page=(value)
      @per_page = value
      initialize_paginator
    end

    private

    def initialize_paginator
      process_html = ->(html) do
        cards_from(html).map { |card| screenshot_from(card) }
      end
      @paginator = ScreenshotPaginator.new(process_html, max_per_page: MAX_PER_PAGE,
                                           per_page: per_page, steam_per_page: per_page)
    end

    def cards_from(html)
      html.search('.apphub_Card')
    end

    def screenshot_from(card)
      details_url = card['data-modal-content-url']
      medium_url, full_size_url = urls_from(card)
      title = title_from(card)
      user_link = user_link_from(card)
      user_name = if user_link
        user_link.text.strip.gsub(/[[:space:]]\z/, '')
      end
      user_url = if user_link
        user_link['href']
      end
      like_count = like_count_from(card)
      comment_count = comment_count_from(card)
      Screenshot.new(details_url: details_url, title: title, medium_url: medium_url,
                     full_size_url: full_size_url, user_name: user_name,
                     user_url: user_url, like_count: like_count, comment_count: comment_count,
                     app: self)
    end

    def urls_from(card)
      image = card.at('.apphub_CardContentPreviewImage')
      return unless image

      medium_url = image['src']
      uri = URI.parse(medium_url)
      full_size_url = "#{uri.scheme}://#{uri.host}#{uri.path}"

      [medium_url, full_size_url]
    end

    def like_count_from(card)
      card_rating = card.at('.apphub_CardRating')
      return 0 unless card_rating

      text = card_rating.text.strip.gsub(/[[:space:]]\z/, '')
      if text.length > 0
        text.to_i
      else
        0
      end
    end

    def comment_count_from(card)
      comments_el = card.at('.apphub_CardCommentCount')
      return 0 unless comments_el

      text = comments_el.text.strip.gsub(/[[:space:]]\z/, '')
      if text.length > 0
        text.to_i
      else
        0
      end
    end

    def full_size_url_from(medium_url)
      if medium_url =~ /\.resizedimage$/
        size_part = medium_url.split('/').last # e.g., 640x359.resizedimage
        medium_url.split(size_part).first
      end
    end

    def user_link_from(card)
      links = card.search('.apphub_CardContentAuthorBlock .apphub_CardContentAuthorName a')
      links.last
    end

    def title_from(card)
      title_el = card.at('.apphub_CardMetaData .apphub_CardContentTitle')
      return unless title_el

      title = title_el.text.strip.gsub(/[[:space:]]\z/, '')
      title if title.length > 0
    end

    def steam_url(order, query, per_page)
      params = [
        "browsefilter=#{browsefilter_param(order)}",
        "numperpage=#{per_page}"
      ]
      params << "searchText=#{URI.escape(query)}" if query
      "http://steamcommunity.com/app/#{id}/screenshots/?" + params.join('&')
    end

    def browsefilter_param(order)
      if VALID_ORDERS.include?(order)
        order
      else
        VALID_ORDERS.first
      end
    end
  end
end

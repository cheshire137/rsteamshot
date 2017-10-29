module Rsteamshot
  # Public: Represents a Steam app, like a video game. Used to fetch the screenshots
  # that were taken in that app that Steam users have uploaded.
  class App
    # Public: Exception thrown by Rsteamshot::App#search when the given file is not a valid file
    # containing Steam apps.
    class BadAppsFile < StandardError; end

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

    # Public: Writes a JSON file at the given location with the latest list of apps on Steam.
    #
    # path - a String file path
    #
    # Returns nothing.
    def self.download_apps_list(path)
      File.open(path, 'w') do |file|
        IO.copy_stream(open(APPS_LIST_URL), file)
      end
    end

    # Public: Find Steam apps by name.
    #
    # raw_query - a String search query for an app or game on Steam
    # apps_list_path - a String file path to the JSON file produced by #download_apps_list
    #
    # Returns an Array of Rsteamshot::Apps.
    def self.search(raw_query, apps_list_path)
      return [] unless raw_query

      unless apps_list_path
        raise BadAppsFile, 'no path given to JSON apps list from Steam'
      end

      unless File.file?(apps_list_path)
        raise BadAppsFile, "#{apps_list_path} is not a file"
      end

      json = begin
        JSON.parse(File.read(apps_list_path))
      rescue JSON::ParserError
        raise BadAppsFile, "#{apps_list_path} is not a valid JSON file"
      end

      applist = json['applist']
      unless applist
        raise BadAppsFile, "#{apps_list_path} does not have expected JSON format"
      end

      apps = applist['apps']
      unless apps
        raise BadAppsFile, "#{apps_list_path} does not have expected JSON format"
      end

      query = raw_query.downcase
      results = []
      apps.each do |data|
        next unless data['name']

        if data['name'].downcase.include?(query)
          results << new(id: data['appid'], name: data['name'])
        end
      end

      results
    end

    # Public: Initialize a Steam app with the given attributes.
    #
    # attrs - the Hash of attributes for this app
    #         :id - the String or Integer app ID
    #         :name - the String name of the app
    #         :per_page - how many results to get in each page; defaults to 10; valid range: 1-50;
    #                     Integer
    def initialize(attrs = {})
      per_page = attrs.delete(:per_page)

      attrs.each { |key, value| instance_variable_set("@#{key}", value) }

      process_html = ->(html) do
        cards_from(html).map { |card| screenshot_from(card) }
      end
      @paginator = ScreenshotPaginator.new(process_html, max_per_page: MAX_PER_PAGE,
                                           per_page: per_page, steam_per_page: per_page)
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

    private

    def cards_from(html)
      html.search('.apphub_Card')
    end

    def screenshot_from(card)
      details_url = card['data-modal-content-url']
      medium_url, full_size_url = urls_from(card)
      title = title_from(card)
      user_link = user_link_from(card)
      user_name = if user_link
        user_link.text.strip
      end
      user_url = if user_link
        user_link['href']
      end
      like_count = like_count_from(card)
      Screenshot.new(details_url: details_url, title: title, medium_url: medium_url,
                     full_size_url: full_size_url, user_name: user_name,
                     user_url: user_url, like_count: like_count)
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
      return unless card_rating

      card_rating.text.strip.to_i
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

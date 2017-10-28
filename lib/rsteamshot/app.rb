module Rsteamshot
  class App
    class BadAppsFile < StandardError; end
    APPS_LIST_URL = 'http://api.steampowered.com/ISteamApps/GetAppList/v2'

    attr_reader :id, :name

    def self.download_apps_list(path)
      File.open(path, 'w') do |file|
        IO.copy_stream(open(APPS_LIST_URL), file)
      end
    end

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
      unless applist
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

    def initialize(attrs = {})
      attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    def screenshots
      result = []
      return result unless id

      Mechanize.new.get(steam_url) do |page|
        cards = page.search('.apphub_Card')
        result = cards.map { |card| screenshot_from(card) }
      end
      result
    end

    private

    def screenshot_from(card)
      details_url = card['data-modal-content-url']
      medium_url = medium_url_from(card)
      full_size_url = full_size_url_from(medium_url)
      title = title_from(card)
      user_link = user_link_from(card)
      user_name = if user_link
        user_link.text.strip
      end
      user_url = if user_link
        user_link['href']
      end
      Screenshot.new(details_url: details_url, title: title, medium_url: medium_url,
                     full_size_url: full_size_url, user_name: user_name,
                     user_url: user_url)
    end

    def medium_url_from(card)
      image = card.at('.apphub_CardContentPreviewImage')
      return unless image

      uri = URI.parse(image['src'])
      "#{uri.scheme}://#{uri.host}#{uri.path}"
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

    def steam_url
      "http://steamcommunity.com/app/#{id}/screenshots/?p=1&browsefilter=mostrecent"
    end
  end
end

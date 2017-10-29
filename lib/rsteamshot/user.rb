module Rsteamshot
  # Public: Represents a Steam user. Used to fetch the user's screenshots they have
  # uploaded to Steam.
  class User
    # Public: How to sort screenshots when they are being retrieved.
    VALID_ORDERS = %w[newestfirst score oldestfirst].freeze

    # Public: Returns a String user name from a Steam user's public profile.
    attr_reader :user_name

    # Public: Initialize a Steam user with the given user name.
    #
    # user_name - a String
    def initialize(user_name)
      @user_name = user_name
    end

    # Public: Fetch a list of the user's newest uploaded screenshots.
    #
    # order - String specifying which screenshots should be retrieved; choose from newestfirst,
    #         score, and oldestfirst; defaults to newestfirst
    # page - which page of results to fetch; defaults to 1; Integer
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(order: nil, page: 1)
      result = []
      url = steam_url(order, page)
      Mechanize.new.get(url) do |html|
        links = html.search('#image_wall .imageWallRow .profile_media_item')
        result = links.map { |link| screenshot_from(link) }
      end
      result
    end

    private

    def screenshot_from(link)
      details_url = link['href']
      description = link.at('.imgWallHoverDescription')
      title = description ? description.text.strip : nil
      Screenshot.new(title: title, details_url: details_url)
    end

    def steam_url(order, page)
      sort = if VALID_ORDERS.include?(order)
        order
      else
        'newestfirst'
      end
      p = page.to_i
      p = 1 if p < 1
      "http://steamcommunity.com/id/#{user_name}/screenshots/?appid=0&sort=#{sort}&" \
        "browsefilter=myfiles&view=grid&p=#{p}"
    end
  end
end

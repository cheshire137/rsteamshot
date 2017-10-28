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
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(order: nil)
      result = []
      Mechanize.new.get(steam_url(order)) do |page|
        links = page.search('#image_wall .imageWallRow .profile_media_item')
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

    def steam_url(order)
      sort = if VALID_ORDERS.include?(order)
        order
      else
        'newestfirst'
      end
      "http://steamcommunity.com/id/#{user_name}/screenshots/?appid=0&sort=#{sort}&" \
        'browsefilter=myfiles&view=grid'
    end
  end
end

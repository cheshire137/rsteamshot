module Rsteamshot
  # Public: Represents a Steam user. Used to fetch the user's screenshots they have
  # uploaded to Steam.
  class User
    # Public: How to sort screenshots when they are being retrieved.
    VALID_ORDERS = %w[newestfirst score oldestfirst].freeze

    # Public: How many screenshots are shown on a user's profile per page.
    STEAM_PER_PAGE = 50

    # Public: Returns a String user name from a Steam user's public profile.
    attr_reader :user_name

    # Public: Initialize a Steam user with the given user name.
    #
    # user_name - a String
    # per_page - how many screenshots to get in each page; defaults to 10; valid range: 1-50;
    #            Integer
    def initialize(user_name, per_page: 10)
      @user_name = user_name

      process_html = ->(html) do
        links_from(html).map { |link| screenshot_from(link) }
      end
      @paginator = ScreenshotPaginator.new(process_html, max_per_page: STEAM_PER_PAGE,
                                           per_page: per_page, steam_per_page: STEAM_PER_PAGE)
    end

    # Public: Fetch a list of the user's newest uploaded screenshots.
    #
    # order - String specifying which screenshots should be retrieved; choose from newestfirst,
    #         score, and oldestfirst; defaults to newestfirst
    # page - which page of results to fetch; defaults to 1; Integer
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(order: nil, page: 1)
      return [] unless user_name

      @paginator.screenshots(page: page, url: steam_url(order))
    end

    private

    def links_from(html)
      html.search('#image_wall .imageWallRow .profile_media_item')
    end

    def screenshot_from(link)
      details_url = link['href']
      description = link.at('.imgWallHoverDescription')
      title = description ? description.text.strip : nil
      Screenshot.new(title: title, details_url: details_url)
    end

    def steam_url(order)
      "http://steamcommunity.com/id/#{user_name}/screenshots/?appid=0&sort=#{sort_param(order)}&" \
        "browsefilter=myfiles&view=grid"
    end

    def sort_param(order)
      if VALID_ORDERS.include?(order)
        order
      else
        VALID_ORDERS.first
      end
    end
  end
end

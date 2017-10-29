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
    def initialize(user_name)
      @user_name = user_name
      html_processor = ->(html) { process_html(html) }
      @paginator = ScreenshotPaginator.new(html_processor, STEAM_PER_PAGE)
    end

    # Public: Fetch a list of the user's newest uploaded screenshots.
    #
    # order - String specifying which screenshots should be retrieved; choose from newestfirst,
    #         score, and oldestfirst; defaults to newestfirst
    # page - which page of results to fetch; defaults to 1; Integer
    # per_page - how many results to get in each page; defaults to 10; valid range: 1-50; Integer
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(order: nil, page: 1, per_page: 10)
      @paginator.screenshots(page: page, per_page: per_page, url: steam_url(order))
    end

    private

    def process_html(html)
      links = html.search('#image_wall .imageWallRow .profile_media_item')
      links.map { |link| screenshot_from(link) }
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

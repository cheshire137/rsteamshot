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
    # app_id - optional Steam app ID as an Integer or String, to get screenshots from this user for
    #          the specified app; defaults to including all apps
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(order: nil, page: 1, app_id: 0)
      return [] unless user_name

      url = steam_url(order, app_id)
      @paginator.screenshots(page: page, url: url)
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

    def steam_url(order, app_id = 0)
      params = [
        "appid=#{URI.escape(app_id.to_s)}",
        "sort=#{sort_param(order)}",
        'browsefilter=myfiles',
        'view=grid'
      ]
      user_param = URI.escape(user_name)
      "http://steamcommunity.com/id/#{user_param}/screenshots/?" + params.join('&')
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

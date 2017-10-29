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
    # per_page - how many results to fetch; defaults to 10; maximum of
    #            `ScreenshotPaginator::MAX_PER_PAGE`, minimum of 1; Integer
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(order: nil, page: 1, per_page: 10)
      result = []
      per_page = get_per_page(per_page)
      paginator = ScreenshotPaginator.new(page, per_page)
      steam_page, offset = paginator.steam_page_and_offset
      url = steam_url(order, steam_page)
      Mechanize.new.get(url) do |html|
        links = html.search('#image_wall .imageWallRow .profile_media_item')
        links = links.drop(offset).take(per_page)
        result = links.map { |link| screenshot_from(link) }
      end
      result
    end

    private

    def get_per_page(per_page)
      per_page = per_page.to_i
      per_page = 1 if per_page < 1
      per_page = ScreenshotPaginator::MAX_PER_PAGE if per_page > ScreenshotPaginator::MAX_PER_PAGE
      per_page
    end

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

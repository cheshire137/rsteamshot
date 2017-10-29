module Rsteamshot
  # Public: Represents a Steam user. Used to fetch the user's screenshots they have
  # uploaded to Steam.
  class User
    # Public: How to sort screenshots when they are being retrieved.
    VALID_ORDERS = %w[newestfirst score oldestfirst].freeze

    # Public: The most screenshots that can be returned in a page.
    MAX_PER_PAGE = 50

    # Public: Returns a String user name from a Steam user's public profile.
    attr_reader :user_name

    # Public: Initialize a Steam user with the given user name.
    #
    # user_name - a String
    def initialize(user_name)
      @user_name = user_name
      @screenshot_pages = []
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
      result = []

      page = [page.to_i, 1].max
      per_page = get_per_page(per_page)
      offset = (page - 1) * per_page

      screenshots = fetch_all_screenshots(offset, order)
      screenshots.drop(offset).take(per_page)
    end

    private

    def fetch_all_screenshots(offset, order)
      screenshot_page = @screenshot_pages.detect { |page| page.includes_screenshot?(offset) }
      base_url = steam_url(order)

      unless screenshot_page
        next_number = if @screenshot_pages.size < 1
          1
        else
          @screenshot_pages.last.number + 1
        end
        screenshot_page = ScreenshotPage.new(next_number)
        screenshot_page.fetch(base_url) { |html| process_html(html) }
        @screenshot_pages << screenshot_page

        while !screenshot_page.includes_screenshot?(offset)
          screenshot_page = ScreenshotPage.new(screenshot_page.number + 1)
          screenshot_page.fetch(base_url) { |html| process_html(html) }
          @screenshot_pages << screenshot_page
        end
      end

      @screenshot_pages.flat_map(&:screenshots)
    end

    def process_html(html)
      links = html.search('#image_wall .imageWallRow .profile_media_item')
      links.map { |link| screenshot_from(link) }
    end

    def get_per_page(raw_per_page)
      per_page = raw_per_page.to_i
      per_page = 1 if per_page < 1
      per_page = MAX_PER_PAGE if per_page > MAX_PER_PAGE
      per_page
    end

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
        "browsefilter=myfiles&view=grid"
    end
  end
end

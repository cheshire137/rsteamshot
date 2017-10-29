module Rsteamshot
  # Public: Represents a page of screenshots on Steam.
  class ScreenshotPage
    # Public: Returns the Integer number of this page.
    attr_reader :number

    # Public: Returns the Integer count of how many screenshots to fetch per page.
    attr_reader :per_page

    # Public: Returns an Array of the Rsteamshot::Screenshots found on this page.
    attr_reader :screenshots

    # Public: Construct a new ScreenshotPage with the given page number.
    #
    # number - the page number; Integer
    # per_page - how many screenshots are shown on the Steam page
    def initialize(number, per_page)
      @number = number
      @per_page = per_page
    end

    # Public: Check if the nth screenshot would be on this page on Steam.
    #
    # screenshot_number - the index of the screenshot you want to check
    #
    # Returns a Boolean.
    def includes_screenshot?(screenshot_number)
      range.cover?(screenshot_number)
    end

    # Public: Fetch the contents of this page from Steam.
    #
    # Returns a Mechanize::Page.
    def fetch(base_url)
      return if @screenshots # already fetched

      url = with_steam_page_param(base_url)
      Mechanize.new.get(url) do |html|
        @screenshots = yield(html)
      end
    end

    private

    def min_screenshot
      (number - 1) * per_page
    end

    def max_screenshot
      min_screenshot + per_page
    end

    def range
      min_screenshot...max_screenshot
    end

    def with_steam_page_param(base_url)
      joiner = base_url.include?('?') ? '&' : '?'
      "#{base_url}#{joiner}p=#{number}"
    end
  end
end

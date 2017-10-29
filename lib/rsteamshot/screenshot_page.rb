module Rsteamshot
  # Public: Represents a page of screenshots on Steam.
  class ScreenshotPage
    # Public: How many screenshots are shown on a single page of a user's Steam profile.
    STEAM_PER_PAGE = 50

    # Public: Returns the Integer number of this page.
    attr_reader :number

    # Public: Returns an Array of the Rsteamshot::Screenshots found on this page.
    attr_reader :screenshots

    # Public: Construct a new ScreenshotPage with the given page number.
    #
    # number - the page number; Integer
    def initialize(number)
      @number = number
    end

    # Public: Check if the nth screenshot would be on this page on Steam, assuming
    # each Steam page has `STEAM_PER_PAGE` screenshots.
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
      (number - 1) * STEAM_PER_PAGE
    end

    def max_screenshot
      min_screenshot + STEAM_PER_PAGE
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

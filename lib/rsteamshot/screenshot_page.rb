module Rsteamshot
  # Public: Represents a page of screenshots on Steam.
  class ScreenshotPage
    # Public: How many screenshots are shown on a single page of a user's Steam profile.
    STEAM_PER_PAGE = 50

    # Public: Returns the Integer number of this page.
    attr_reader :number

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
      return @html if @html # already fetched

      url = steam_url(base_url)
      Mechanize.new.get(url) { |html| @html = html }
      @html
    end

    private

    def range
      min = (number - 1) * STEAM_PER_PAGE
      max = min + STEAM_PER_PAGE
      min...max
    end

    def steam_url(base_url)
      joiner = base_url.include?('?') ? '&' : '?'
      "#{base_url}#{joiner}p=#{number}"
    end
  end
end

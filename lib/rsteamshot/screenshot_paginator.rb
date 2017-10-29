module Rsteamshot
  # Public: Use to paginate screenshots fetched from Steam in chunks of fewer than
  # 50 per page.
  class ScreenshotPaginator
    # Public: Construct a new ScreenshotPaginator that will process a page of HTML
    # using the given lambda.
    #
    # process_html - a lambda that will take a Mechanize::Page and return a list of
    #                Rsteamshot::Screenshot instances found in that page
    # max_per_page - the most screenshots that can be returned in a page, based on how many
    #                screenshots are shown on the Steam page
    def initialize(process_html, max_per_page)
      @process_html = process_html
      @screenshot_pages = []
      @max_per_page = max_per_page
    end

    # Public: Get the specified number of screenshots from the given Steam URL.
    #
    # page - which page of results to fetch; Integer; defaults to 1
    # per_page - how many screenshots to fetch at a time; Integer; defaults to 10
    # url - URL to a Steam page with screenshots, should not include a page parameter; String
    #
    # Returns an Array of Rsteamshot::Screenshots.
    def screenshots(page: 1, per_page: 10, url:)
      per_page = get_per_page(per_page)
      offset = get_offset(page, per_page)
      fetch_screenshots(offset, url).drop(offset).take(per_page)
    end

    private

    def get_per_page(raw_per_page)
      per_page = raw_per_page.to_i
      per_page = 1 if per_page < 1
      per_page = @max_per_page if per_page > @max_per_page
      per_page
    end

    def get_offset(page, per_page)
      page = [page.to_i, 1].max
      (page - 1) * per_page
    end

    def fetch_screenshots(offset, base_url)
      screenshot_page = @screenshot_pages.detect { |page| page.includes_screenshot?(offset) }
      fetch_necessary_screenshots(offset, base_url) unless screenshot_page
      @screenshot_pages.flat_map(&:screenshots)
    end

    def fetch_necessary_screenshots(offset, base_url)
      screenshot_page = ScreenshotPage.new(next_page_number, @max_per_page)
      screenshot_page.fetch(base_url) { |html| @process_html.(html) }
      @screenshot_pages << screenshot_page

      while !screenshot_page.includes_screenshot?(offset)
        screenshot_page = ScreenshotPage.new(screenshot_page.number + 1, @max_per_page)
        screenshot_page.fetch(base_url) { |html| @process_html.(html) }
        @screenshot_pages << screenshot_page
      end
    end

    def next_page_number
      last_page = @screenshot_pages.last
      last_page ? last_page.number : 1
    end
  end
end

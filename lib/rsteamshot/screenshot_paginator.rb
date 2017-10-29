module Rsteamshot
  class ScreenshotPaginator
    # Public: The most screenshots that can be returned in a page.
    MAX_PER_PAGE = 50

    def initialize(process_html)
      @process_html = process_html
      @screenshot_pages = []
    end

    def screenshots(page:, per_page:, base_url:)
      per_page = get_per_page(per_page)
      offset = get_offset(page, per_page)
      fetch_screenshots(offset, base_url).drop(offset).take(per_page)
    end

    private

    def get_per_page(raw_per_page)
      per_page = raw_per_page.to_i
      per_page = 1 if per_page < 1
      per_page = MAX_PER_PAGE if per_page > MAX_PER_PAGE
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
      screenshot_page = ScreenshotPage.new(next_page_number)
      screenshot_page.fetch(base_url) { |html| @process_html.(html) }
      @screenshot_pages << screenshot_page

      while !screenshot_page.includes_screenshot?(offset)
        screenshot_page = ScreenshotPage.new(screenshot_page.number + 1)
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

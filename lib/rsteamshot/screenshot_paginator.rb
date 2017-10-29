module Rsteamshot
  class ScreenshotPaginator
    # Public: How many screenshots are allowed to be fetched at once. Limited by how many
    # screenshots are shown on a user's profile on Steam.
    MAX_PER_PAGE = 50

    # Public: Returns the Integer page.
    attr_reader :page

    # Public: Returns the Integer of screenshots desired per page.
    attr_reader :per_page

    def initialize(page, per_page)
      @page = page
      @per_page = per_page
    end

    def steam_page_and_offset
      puts "page #{page} / per page #{per_page}"
      return [page, 0] if per_page == MAX_PER_PAGE

      # page 4, per_page 25
      # (4 - 1) * 25 = 75
      # 75 > 50: steam page 2
      # offset 25

      # page 5, per_page 30
      # (5 - 1) * 30 = 120
      # 120 > 50: steam page 3
      # page 1: 30, page 2: 60, page 3: 90, page 4: 120, page 5: 150
      # sp1/o0      sp1/o30     sp2/o10     sp2/o20      sp4/o0
      # offset

      # steam page 1: 1-50
      # steam page 2: 51-100
      # steam page 3: 101-150
      # steam page 4: 151-200

      offset = (page - 1) * per_page
      steam_page = 1

      if offset > MAX_PER_PAGE
        steam_page = (offset.to_f / MAX_PER_PAGE).ceil
        offset = offset % MAX_PER_PAGE
      end

      [steam_page, offset]
    end
  end
end

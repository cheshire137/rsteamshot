module Rsteamshot
  class Screenshot
    attr_reader :title, :details_url, :full_size_url, :medium_url, :user_name,
                :user_url, :date

    def initialize(title, details_url)
      @title = title
      @details_url = details_url
    end

    def get_details
      Mechanize.new.get(details_url) do |page|
        link = page.at('.actualmediactn a')
        @full_size_url = full_size_url_from(link)
        @medium_url = medium_url_from(link)

        author = page.at('.creatorsBlock')
        @user_name = user_name_from(author)
        @user_url = user_url_from(author)

        @date = date_from(page)
      end
    end

    private

    def full_size_url_from(link)
      link.attributes['href']
    end

    def medium_url_from(link)
      img = link.at('img')
      img.attributes['src']
    end

    def user_name_from(author)
      author.at('.friendBlockContent').text.strip
    end

    def user_url_from(author)
      author_link = author.at('.friendBlockLinkOverlay')
      author_link.attributes['href']
    end

    def date_from(page)
      metadata = page.search('.detailsStatsContainerRight .detailsStatRight')
      date_el = metadata[1]
      raw_date_str = date_el.text.strip
      format = if raw_date_str.include?(',')
        '%b %d, %Y @ %l:%M%P'
      else
        '%b %d @ %l:%M%P'
      end
      DateTime.strptime(raw_date_str, format)
    end
  end
end

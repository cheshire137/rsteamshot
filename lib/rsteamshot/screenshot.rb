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
        @full_size_url = link['href'] if link

        @medium_url = medium_url_from(page)

        author = page.at('.creatorsBlock')
        @user_name = user_name_from(author)
        @user_url = user_url_from(author)

        @date = date_from(page)
      end
    end

    private

    def medium_url_from(page)
      img = page.at('img#ActualMedia')
      return unless img

      img['src']
    end

    def user_name_from(author)
      container = author.at('.friendBlockContent')
      return unless container

      all_text = container.text
      online_status = container.at('.friendSmallText')
      return all_text.strip unless online_status

      status_text = online_status.text
      index = all_text.index(status_text)

      user_name_text = if index
        all_text.slice(0, index)
      else
        all_text
      end

      user_name_text.strip
    end

    def user_url_from(author)
      author_link = author.at('.friendBlockLinkOverlay')
      return unless author_link

      author_link['href']
    end

    def date_from(page)
      metadata = page.search('.detailsStatsContainerRight .detailsStatRight')
      date_el = metadata[1]
      return unless date_el

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

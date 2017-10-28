module Rsteamshot
  class Screenshot
    attr_reader :title, :details_url, :full_size_url, :medium_url, :user_name,
                :user_url, :date, :file_size, :width, :height

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

        details_block = details_block_from(page)
        if details_block
          labels_container = details_block.at('.detailsStatsContainerLeft')
          if labels_container
            label_els = labels_container.search('.detailsStatLeft')
            labels = label_els.map { |el| el.text.strip }
          end

          values_container = details_block.at('.detailsStatsContainerRight')
          if values_container
            value_els = values_container.search('.detailsStatRight')
            values = value_els.map { |el| el.text.strip }
          end

          labelled_values = labels.zip(values).to_h
          @file_size = labelled_values['File Size']
          @date = date_from(labelled_values['Posted'])
          @width, @height = dimensions_from(labelled_values['Size'])
        end
      end
    end

    private

    def details_block_from(page)
      details_blocks = page.search('.rightDetailsBlock')
      details_blocks.detect do |details_block|
        labels_container = details_block.at('.detailsStatsContainerLeft')
        !labels_container.nil?
      end
    end

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

    def date_from(raw_date_str)
      format = if raw_date_str.include?(',')
        '%b %d, %Y @ %l:%M%P'
      else
        '%b %d @ %l:%M%P'
      end
      DateTime.strptime(raw_date_str, format)
    end

    def dimensions_from(dimension_str)
      if dimension_str
        dimension_str.split(' x ').map { |str| str.to_i }
      else
        []
      end
    end
  end
end

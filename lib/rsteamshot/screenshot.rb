module Rsteamshot
  # Public: Represents an image that has been uploaded to Steam of a screenshot taken
  # in a Steam app.
  class Screenshot
    # Public: Returns a String of how the user described this screenshot, or nil.
    attr_reader :title

    # Public: Returns String URL to the Steam page that shows details about this screenshot.
    attr_reader :details_url

    # Public: Returns String URL to the full-size image.
    attr_reader :full_size_url

    # Public: Returns String URL to a medium-size version of the image.
    attr_reader :medium_url

    # Public: Returns String name of the Steam user who uploaded the screenshot.
    attr_reader :user_name

    # Public: Returns String URL to the profile of the Steam user who uploaded the screenshot.
    attr_reader :user_url

    # Public: Returns the DateTime when this screenshot was uploaded.
    attr_reader :date

    # Public: Returns a String describing how large the screenshot is, e.g., 0.547 MB.
    attr_reader :file_size

    # Public: Returns Integer pixel width of the screenshot.
    attr_reader :width

    # Public: Returns Integer pixel height of the screenshot.
    attr_reader :height

    # Public: Returns Integer count of how many people have voted for this screenshot.
    attr_reader :like_count

    # Public: Returns Integer count of how many comments people have left on this screenshot.
    attr_reader :comment_count

    # Public: Initialize a screenshot with the given attributes.
    #
    # attrs - the Hash of attributes for this screenshot
    #         :title - how the user described this screenshot
    #         :details_url - URL to the Steam page that shows details about this screenshot
    #         :full_size_url - URL to the full-size image
    #         :medium_url - URL to a medium-size version of the image
    #         :user_name - name of the Steam user who uploaded the screenshot
    #         :user_url - URL to the profile of the Steam user who uploaded the screenshot
    #         :date - the date and time when this screenshot was uploaded
    #         :file_size - describes how large the screenshot is, e.g., 0.547 MB
    #         :width - pixel width of the screenshot
    #         :height - pixel height of the screenshot
    #         :like_count - number of likes this screenshot has on Steam
    #         :comment_count - number of comments this screenshot has received on Steam
    def initialize(attrs = {})
      attrs.each { |key, value| instance_variable_set("@#{key}", value) }

      fetch_details unless has_details?
    end

    # Public: Get a hash representation of this screenshot.
    #
    # Returns a Hash.
    def to_h
      result = { details_url: details_url }
      result[:title] = title if title
      result[:full_size_url] = full_size_url if full_size_url
      result[:medium_url] = medium_url if medium_url
      result[:user_name] = user_name if user_name
      result[:user_url] = user_url if user_url
      result[:date] = date if date
      result[:file_size] = file_size if file_size
      result[:width] = width if width
      result[:height] = height if height
      result[:like_count] = like_count if like_count
      result[:comment_count] = comment_count if comment_count
      result
    end

    # Public: Get a JSON representation of this screenshot.
    #
    # Returns a String.
    def to_json
      JSON.pretty_generate(to_h)
    end

    # Public: A detailed representation of this screenshot.
    #
    # Returns a String.
    def inspect
      self.class.name + '<' + JSON.generate(to_h) + '>'
    end

    # Public: file_size parsed into bytes
    #
    # Returns a Integer
    def file_size_in_bytes
      unit_multiplier = 1000
      size, unit = self.file_size.split(' ')
      bytes = begin
        case unit.downcase
        when 'kb' then size.to_f * unit_multiplier
        when 'mb' then size.to_f * (unit_multiplier ** 2)
        when 'gb' then size.to_f * (unit_multiplier ** 3)
        else size.to_f
        end
      end
      bytes.to_i
    end

    private

    def has_details?
      !full_size_url.nil? && !medium_url.nil?
    end

    def fetch_details
      return unless details_url

      Mechanize.new.get(details_url) do |page|
        link = page.at('.actualmediactn a')
        @full_size_url = link['href'] if link

        @medium_url = medium_url_from(page)
        @like_count = like_count_from(page)
        @comment_count = comment_count_from(page)

        author = page.at('.creatorsBlock')
        @user_name = user_name_from(author)
        @user_url = user_url_from(author)

        details_block = details_block_from(page)
        if details_block
          labels_container = details_block.at('.detailsStatsContainerLeft')
          if labels_container
            label_els = labels_container.search('.detailsStatLeft')
            labels = label_els.map { |el| el.text.strip.gsub(/[[:space:]]\z/, '') }
          end

          values_container = details_block.at('.detailsStatsContainerRight')
          if values_container
            value_els = values_container.search('.detailsStatRight')
            values = value_els.map { |el| el.text.strip.gsub(/[[:space:]]\z/, '') }
          end

          labelled_values = labels.zip(values).to_h
          @file_size = labelled_values['File Size']
          @date = date_from(labelled_values['Posted'])
          @width, @height = dimensions_from(labelled_values['Size'])
        end
      end
    end

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

    def like_count_from(page)
      rate_el = page.at('.rateUpCount')
      return 0 unless rate_el

      text = rate_el.text.strip.gsub(/[[:space:]]\z/, '')
      if text.length > 0
        text.to_i
      else
        0
      end
    end

    def comment_count_from(page)
      header_el = page.at('.commentthread_count_label')
      return 0 unless header_el

      span = header_el.at('span')
      return 0 unless span

      text = span.text.strip.gsub(/[[:space:]]\z/, '')
      if text.length > 0
        text.to_i
      else
        0
      end
    end

    def user_name_from(author)
      container = author.at('.friendBlockContent')
      return unless container

      all_text = container.text
      online_status = container.at('.friendSmallText')
      return all_text.strip.gsub(/[[:space:]]\z/, '') unless online_status

      status_text = online_status.text
      index = all_text.index(status_text)

      user_name_text = if index
        all_text.slice(0, index)
      else
        all_text
      end

      user_name_text.strip.gsub(/[[:space:]]\z/, '')
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

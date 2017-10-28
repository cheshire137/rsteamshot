module Rsteamshot
  class User
    attr_reader :user_name

    def initialize(user_name)
      @user_name = user_name
    end

    def screenshots
      result = []
      Mechanize.new.get(steam_url) do |page|
        links = page.search('#image_wall .imageWallRow .profile_media_item')
        result = links.map { |link| screenshot_from(link) }
      end
      result
    end

    private

    def screenshot_from(link)
      details_url = link['href']
      description = link.at('.imgWallHoverDescription')
      title = description ? description.text.strip : nil
      Screenshot.new(title: title, details_url: details_url)
    end

    def steam_url
      "http://steamcommunity.com/id/#@user_name/screenshots/?appid=0&sort=newestfirst&" \
        'browsefilter=myfiles&view=grid'
    end
  end
end

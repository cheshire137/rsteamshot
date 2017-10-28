module Rsteamshot
  class User
    def initialize(user_name)
      @user_name = user_name
    end

    def screenshots
      Mechanize.new.get(steam_url) do |page|
        links = page.search('#image_wall .imageWallRow .profile_media_item')
        links.map { |link| screenshot_from(link) }
      end
    end

    private

    def screenshot_from(link)
      details_url = link.attributes['href']
      description = link.at('.imgWallHoverDescription')
      title = description ? description.text.strip : nil
      Screenshot.new(title, details_url)
    end

    def steam_url
      "http://steamcommunity.com/id/#@user_name/screenshots/?appid=0&sort=newestfirst&" \
        'browsefilter=myfiles&view=grid'
    end
  end
end

module Rsteamshot
  # Public: Represents a Steam user. Used to fetch the user's screenshots they have
  # uploaded to Steam.
  class User
    attr_reader :user_name

    # Public: Initialize a Steam user with the given user name.
    #
    # user_name - a String
    def initialize(user_name)
      @user_name = user_name
    end

    # Public: Returns a list of the user's newest uploaded screenshots.
    #
    # Returns an Array of Rsteamshot::Screenshots.
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

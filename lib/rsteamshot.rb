require 'json'
require 'mechanize'
require 'open-uri'
require 'rsteamshot/app'
require 'rsteamshot/configuration'
require 'rsteamshot/screenshot'
require 'rsteamshot/screenshot_page'
require 'rsteamshot/screenshot_paginator'
require 'rsteamshot/user'
require 'rsteamshot/version'
require 'uri'

# Public: Contains classes for finding screenshots uploaded by users to Steam. Screenshots
# are from Steam games (apps).
module Rsteamshot
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  # Public: Configure the Rsteamshot gem such as by setting the path to where you have
  # downloaded the list of Steam apps as a JSON file.
  def self.configure
    yield configuration
  end
end

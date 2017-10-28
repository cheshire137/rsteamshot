require 'spec_helper'

RSpec.describe Rsteamshot::User do
  let(:user_name) { 'cheshire137' }
  subject(:user) { described_class.new(user_name) }

  it 'uses given user name' do
    expect(user.user_name).to eq(user_name)
  end

  context '#screenshots' do
    it 'returns the newest screenshots by default' do
      VCR.use_cassette('user_screenshots') do
        result = user.screenshots

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_an_instance_of(Rsteamshot::Screenshot)
          expect(screenshot.details_url).to_not be_nil
          expect(screenshot.full_size_url).to_not be_nil
          expect(screenshot.medium_url).to_not be_nil
          expect(screenshot.user_name).to_not be_nil
          expect(screenshot.user_url).to_not be_nil
        end

        first_screenshot = result.first
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=1183587888')
      end
    end

    it 'returns oldest screenshots when specified' do
      VCR.use_cassette('user_oldest_screenshots') do
        result = user.screenshots(order: 'oldestfirst')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_an_instance_of(Rsteamshot::Screenshot)
          expect(screenshot.details_url).to_not be_nil
          expect(screenshot.full_size_url).to_not be_nil
          expect(screenshot.medium_url).to_not be_nil
          expect(screenshot.user_name).to_not be_nil
          expect(screenshot.user_url).to_not be_nil
        end

        first_screenshot = result.first
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=233987440')
      end
    end

    it 'returns most popular screenshots when specified' do
      VCR.use_cassette('user_popular_screenshots') do
        result = user.screenshots(order: 'score')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_an_instance_of(Rsteamshot::Screenshot)
          expect(screenshot.details_url).to_not be_nil
          expect(screenshot.full_size_url).to_not be_nil
          expect(screenshot.medium_url).to_not be_nil
          expect(screenshot.user_name).to_not be_nil
          expect(screenshot.user_url).to_not be_nil
        end

        first_screenshot = result.first
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=704478551')
      end
    end
  end
end

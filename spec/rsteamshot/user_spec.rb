require 'spec_helper'

RSpec.describe Rsteamshot::User do
  let(:user_name) { 'cheshire137' }
  let(:per_page) { 10 }
  subject(:user) { described_class.new(user_name, per_page: per_page) }

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

    it 'allows filtering by app' do
      VCR.use_cassette('user_app_screenshots') do
        result = user.screenshots(app_id: '19680')

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
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=500640837')
      end
    end

    it 'allows fetching fewer than 50 screenshots per page' do
      page1 = VCR.use_cassette('user_screenshots') do
        user.screenshots(page: 1)
      end
      expect(page1.size).to eq(per_page)
      expect(page1.first.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=1183587888')
      expect(page1.last.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=807798663')

      # Not in VCR block because the second page, at 10 per page, should still be on the
      # Steam page we already fetched, since Steam user pages always have 50 screenshots:
      page2 = user.screenshots(page: 2)
      expect(page2.size).to eq(per_page)
      expect(page2.first.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=807279946')
      expect(page2.last.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=790267576')
    end
  end
end

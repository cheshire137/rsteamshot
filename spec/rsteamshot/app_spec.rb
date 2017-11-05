require 'spec_helper'

RSpec.describe Rsteamshot::App do
  let(:id) { '377160' }
  let(:per_page) { 10 }
  let(:apps_list_path) { File.join('spec', 'fixtures', 'apps-list.json') }
  subject(:app) { described_class.new(id: id, per_page: per_page) }
  before(:each) do
    Rsteamshot.configure do |config|
      config.apps_list_path = apps_list_path
    end
  end

  it 'uses given app ID' do
    expect(app.id).to eq(id)
  end

  context '.download_apps_list' do
    it 'creates a JSON file of the latest Steam apps list' do
      VCR.use_cassette('download_apps_list') do
        described_class.download_apps_list
      end

      expect(File.file?(apps_list_path)).to eq(true)
      json = JSON.parse(File.read(apps_list_path))
      expect(json).to have_key('applist')
      expect(json['applist']).to have_key('apps')
      expect(json['applist']['apps'].size).to be > 0
    end
  end

  context '.search' do
    it 'returns apps whose name matches the given query, case insensitive' do
      apps = described_class.search('witcher 3')

      expect(apps).to_not be_empty
      apps.each do |app|
        expect(app).to be_an_instance_of(Rsteamshot::App)
        expect(app.id).to_not be_nil
        expect(app.name).to_not be_nil
      end
      expect(apps.map(&:name)).to include('The Witcher 3: Wild Hunt')
    end

    it 'raises an exception when no path is given' do
      Rsteamshot.configure do |config|
        config.apps_list_path = nil
      end

      expect {
        described_class.search('witcher 3')
      }.to raise_error(Rsteamshot::App::BadAppsFile,
                       'no path configured for JSON apps list from Steam')
    end

    it 'raises an exception when invalid path is given' do
      Rsteamshot.configure do |config|
        config.apps_list_path = 'some-nonexistent-file.json'
      end

      expect {
        described_class.search('witcher 3')
      }.to raise_error(Rsteamshot::App::BadAppsFile, 'some-nonexistent-file.json is not a file')
    end

    it 'raises an exception when given path is not a JSON file' do
      Rsteamshot.configure do |config|
        config.apps_list_path = 'README.md'
      end

      expect {
        described_class.search('witcher 3')
      }.to raise_error(Rsteamshot::App::BadAppsFile, 'README.md is not a valid JSON file')
    end

    it 'raises an exception when given path does not have applist key' do
      path = 'spec/fixtures/bad-apps-list1.json'
      Rsteamshot.configure do |config|
        config.apps_list_path = path
      end

      expect {
        described_class.search('witcher 3')
      }.to raise_error(Rsteamshot::App::BadAppsFile, "#{path} does not have expected JSON format")
    end

    it 'raises an exception when given path does not have apps key' do
      path = 'spec/fixtures/bad-apps-list2.json'
      Rsteamshot.configure do |config|
        config.apps_list_path = path
      end

      expect {
        described_class.search('witcher 3')
      }.to raise_error(Rsteamshot::App::BadAppsFile, "#{path} does not have expected JSON format")
    end
  end

  context '#screenshots' do
    it 'returns newest screenshots by default' do
      VCR.use_cassette('app_screenshots') do
        result = app.screenshots

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_a_screenshot
        end

        first_screenshot = result.first
        expect(first_screenshot.app).to eq(app)
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=1185280561')
      end
    end

    it 'returns top rated screenshots when specified' do
      VCR.use_cassette('app_toprated_screenshots') do
        result = app.screenshots(order: 'toprated')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_a_screenshot
        end

        first_screenshot = result.first
        expect(first_screenshot.app).to eq(app)
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=572761840')
      end
    end

    it 'returns daily trending screenshots when specified' do
      VCR.use_cassette('app_trendday_screenshots') do
        result = app.screenshots(order: 'trendday')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_a_screenshot
        end

        first_screenshot = result.first
        expect(first_screenshot.app).to eq(app)
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=1184454167')
      end
    end

    it 'returns weekly trending screenshots when specified' do
      VCR.use_cassette('app_trendweek_screenshots') do
        result = app.screenshots(order: 'trendweek')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_a_screenshot
        end

        first_screenshot = result.first
        expect(first_screenshot.app).to eq(app)
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=1183275869')
      end
    end

    it 'returns 3-month trending screenshots when specified' do
      VCR.use_cassette('app_trendthreemonths_screenshots') do
        result = app.screenshots(order: 'trendthreemonths')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_a_screenshot
        end

        first_screenshot = result.first
        expect(first_screenshot.app).to eq(app)
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=972449101')
      end
    end

    it 'returns 6-month trending screenshots when specified' do
      VCR.use_cassette('app_trendsixmonths_screenshots') do
        result = app.screenshots(order: 'trendsixmonths')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_a_screenshot
        end

        first_screenshot = result.first
        expect(first_screenshot.app).to eq(app)
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=924788014')
      end
    end

    it 'returns yearly trending screenshots when specified' do
      VCR.use_cassette('app_trendyear_screenshots') do
        result = app.screenshots(order: 'trendyear')

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_a_screenshot
        end

        first_screenshot = result.first
        expect(first_screenshot.app).to eq(app)
        expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=785354543')
      end
    end

    it 'allows searching screenshots' do
      result = VCR.use_cassette('app_search_screenshots') do
        app.screenshots(order: 'trendyear', query: 'dogmeat')
      end

      expect(result.size).to eq(per_page)
      result.each do |screenshot|
        expect(screenshot).to be_a_screenshot
      end

      first_screenshot = result.first
      expect(first_screenshot.app).to eq(app)
      expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=929999796')
    end

    it 'returns screenshots from the specified page' do
      result = VCR.use_cassette('app_trendyear_screenshots') do
        VCR.use_cassette('app_trendyear_page_2_screenshots') do
          app.screenshots(order: 'trendyear', page: 2)
        end
      end

      expect(result.size).to eq(per_page)
      result.each do |screenshot|
        expect(screenshot).to be_a_screenshot
      end

      first_screenshot = result.first
      expect(first_screenshot.app).to eq(app)
      expect(first_screenshot.details_url).to eq('http://steamcommunity.com/sharedfiles/filedetails/?id=809289069')
    end
  end
end

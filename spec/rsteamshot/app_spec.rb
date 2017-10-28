require 'spec_helper'

RSpec.describe Rsteamshot::App do
  let(:id) { '377160' }
  let(:apps_list_path) { File.join('spec', 'fixtures', 'apps-list.json') }
  subject(:app) { described_class.new(id: id) }

  it 'uses given app ID' do
    expect(app.id).to eq(id)
  end

  context '.download_apps_list' do
    it 'creates a JSON file of the latest Steam apps list' do
      VCR.use_cassette('download_apps_list') do
        described_class.download_apps_list(apps_list_path)
      end

      expect(File.file?(apps_list_path)).to eq(true)
      json = JSON.parse(File.read(apps_list_path))
      expect(json).to have_key('applist')
      expect(json['applist']).to have_key('apps')
      expect(json['applist']['apps'].size).to be > 0
    end
  end

  context '#screenshots' do
    it 'returns screenshots with details URLs' do
      VCR.use_cassette('app_screenshots') do
        result = app.screenshots

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_an_instance_of(Rsteamshot::Screenshot)
          expect(screenshot.details_url).to_not be_nil
          expect(screenshot.medium_url).to_not be_nil
          expect(screenshot.user_name).to_not be_nil
          expect(screenshot.user_url).to_not be_nil
        end
      end
    end
  end
end

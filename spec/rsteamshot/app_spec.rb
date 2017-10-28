require 'spec_helper'

RSpec.describe Rsteamshot::App do
  let(:id) { '377160' }
  subject(:app) { described_class.new(id) }

  it 'uses given app ID' do
    expect(app.id).to eq(id)
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

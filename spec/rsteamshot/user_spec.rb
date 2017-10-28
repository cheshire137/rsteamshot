require 'spec_helper'

RSpec.describe Rsteamshot::User do
  let(:user_name) { 'cheshire137' }
  subject(:user) { described_class.new(user_name) }

  it 'uses given user name' do
    expect(user.user_name).to eq(user_name)
  end

  context '#screenshots' do
    it 'returns screenshots' do
      VCR.use_cassette('user_screenshots') do
        result = user.screenshots

        expect(result).to_not be_empty
        result.each do |screenshot|
          expect(screenshot).to be_an_instance_of(Rsteamshot::Screenshot)
          expect(screenshot.details_url).to_not be_nil
          expect(screenshot.full_size_url).to_not be_nil
          expect(screenshot.medium_url).to_not be_nil
        end
      end
    end
  end
end
